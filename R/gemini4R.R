#' Gemini API Request Function
#'
#' This function sends a request to the Gemini API to generate text or perform interactive chat.
#' It supports both synchronous and streaming modes.
#'
#' @param mode A character string specifying the mode. Valid values are "text", "stream_text", "chat", "stream_chat".
#' @param api_key A character string containing your Gemini API key.
#' @param contents For "text" or "stream_text" modes, a character string with the input text.
#'   For "chat" or "stream_chat" modes, a list of messages. Each message is a list with fields:
#'   \code{role} (e.g., "user" or "model") and \code{text} (message content).
#' @param store_history Logical. If TRUE and in a chat mode, the chat history is stored in the environment
#'   variable "chat_history" as a JSON string.
#' @param max_token Integer. Optional. Maximum number of tokens for the generated output.
#' @param ... Additional options passed to the HTTP request.
#'
#' @return For synchronous modes ("text", "chat"), a parsed JSON object is returned.
#'   For streaming modes ("stream_text", "stream_chat"), a list with \code{full_text} (combined output)
#'   and \code{chunks} (individual text pieces) is returned.
#' @export gemini4R
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#'   # Synchronous text generation:
#'   result <- gemini4R(
#'     mode = "text",
#'     api_key = Sys.getenv("GoogleGemini_API_KEY"),
#'     contents = "Explain how AI works",
#'     max_token = 256
#'   )
#'   print(result)
#'
#'   # Synchronous chat mode with history storage:
#'   chat_history <- list(
#'     list(role = "user", text = "Hello"),
#'     list(role = "model", text = "Great to meet you. What would you like to know?"),
#'     list(role = "user", text = "I have two dogs in my house. How many paws are in my house?")
#'   )
#'   chat_result <- gemini4R(
#'     mode = "chat",
#'     api_key = Sys.getenv("GoogleGemini_API_KEY"),
#'     contents = chat_history,
#'     store_history = TRUE,
#'     max_token = 150
#'   )
#'   print(chat_result)
#'
#'   # Streaming text generation:
#'   stream_result <- gemini4R(
#'     mode = "stream_text",
#'     api_key = Sys.getenv("GoogleGemini_API_KEY"),
#'     contents = "Write a story about a magic backpack.",
#'     max_token = 200
#'   )
#'   print(stream_result$full_text)
#' }

gemini4R <- function(mode,
                     contents,
                     store_history = FALSE,
                     api_key = Sys.getenv("GoogleGemini_API_KEY"),
                     max_token = 200,
                     ...) {

  # Validate mode parameter
  mode <- tolower(mode)
  valid_modes <- c("text", "stream_text", "chat", "stream_chat")
  if (!(mode %in% valid_modes)) {
    stop("Invalid mode specified. Choose one of: ", paste(valid_modes, collapse = ", "))
  }

  # Determine endpoint based on mode
  if (mode == "text") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=", api_key)
  } else if (mode == "stream_text") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?alt=sse&key=", api_key)
  } else if (mode == "chat") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=", api_key)
  } else if (mode == "stream_chat") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?alt=sse&key=", api_key)
  }

  # Build the request body based on mode and contents
  if (mode %in% c("text", "stream_text")) {
    # If contents is not a list, assume it's a character string.
    if (!is.list(contents)) {
      request_body <- list(
        contents = list(
          list(parts = list(list(text = contents)))
        )
      )
    } else {
      # If provided as a list, assume it's already formatted correctly.
      request_body <- list(contents = contents)
    }
  } else if (mode %in% c("chat", "stream_chat")) {
    # For chat mode, expect contents to be a list of messages with role and text.
    # Convert each message to the required format.
    request_body <- list(
      contents = lapply(contents, function(msg) {
        list(
          role = msg$role,
          parts = list(list(text = msg$text))
        )
      })
    )
  }

  # Add max_token setting to request body if provided
  if (!is.null(max_token)) {
    request_body$max_output_tokens <- max_token
  }

  # Convert the request body to JSON string
  json_body <- jsonlite::toJSON(request_body, auto_unbox = TRUE)

  # Synchronous modes ("text" and "chat")
  if (mode %in% c("text", "chat")) {
    response <- httr::POST(url = endpoint, body = json_body, encode = "json",
                           httr::add_headers("Content-Type" = "application/json"), ...)

    # Check for HTTP errors
    if (httr::http_error(response)) {
      stop("HTTP error: ", httr::status_code(response))
    }

    # Parse the response content
    res_content <- httr::content(response, as = "text", encoding = "UTF-8")
    parsed_response <- jsonlite::fromJSON(res_content, simplifyVector = FALSE)

    # If in chat mode and history storage is requested, update the environment variable
    if (mode == "chat" && store_history) {
      prev_history <- Sys.getenv("chat_history")
      if (nzchar(prev_history)) {
        prev_history_list <- jsonlite::fromJSON(prev_history, simplifyVector = FALSE)
      } else {
        prev_history_list <- list()
      }
      # Combine previous history, current request, and response
      new_history <- c(prev_history_list, request_body$contents, parsed_response)
      Sys.setenv(chat_history = jsonlite::toJSON(new_history, auto_unbox = TRUE))
    }

    return(parsed_response)
  }

  # Streaming modes ("stream_text" and "stream_chat")
  if (mode %in% c("stream_text", "stream_chat")) {
    # Create a new curl handle and set necessary options
    h <- curl::new_handle()
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    curl::handle_setopt(h, post = TRUE, postfields = json_body)

    # Initialize a vector to accumulate streamed text pieces
    accumulated_output <- character()

    # Callback function to process incoming stream chunks
    callback <- function(data, ...) {
      # Convert raw data to character
      chunk <- rawToChar(data)
      # Split chunk into individual lines (SSE events)
      lines <- strsplit(chunk, "\n")[[1]]
      for (line in lines) {
        line <- trimws(line)
        if (nchar(line) == 0) next
        # Process only lines starting with "data:"
        if (startsWith(line, "data:")) {
          # Remove the "data:" prefix
          data_line <- sub("^data:\\s*", "", line)
          # Check for termination signal
          if (data_line == "[DONE]") {
            next
          }
          # Attempt to parse the JSON data
          parsed_chunk <- tryCatch({
            jsonlite::fromJSON(data_line, simplifyVector = FALSE)
          }, error = function(e) {
            warning("Failed to parse JSON chunk: ", data_line)
            NULL
          })
          if (!is.null(parsed_chunk)) {
            # Extract text depending on the structure
            if (!is.null(parsed_chunk$text)) {
              accumulated_output <<- c(accumulated_output, parsed_chunk$text)
            } else if (!is.null(parsed_chunk$candidates)) {
              candidate_texts <- sapply(parsed_chunk$candidates, function(x) x$output)
              accumulated_output <<- c(accumulated_output, candidate_texts)
            }
            # For streaming chat mode, update chat_history if requested
            if (mode == "stream_chat" && store_history) {
              prev_history <- Sys.getenv("chat_history")
              if (nzchar(prev_history)) {
                prev_history_list <- jsonlite::fromJSON(prev_history, simplifyVector = FALSE)
              } else {
                prev_history_list <- list()
              }
              new_history <- c(prev_history_list, list(parsed_chunk))
              Sys.setenv(chat_history = jsonlite::toJSON(new_history, auto_unbox = TRUE))
            }
          }
        }
      }
      # Return the number of bytes processed
      return(length(data))
    }

    # Execute the streaming request
    curl::curl_fetch_stream(url = endpoint, fun = callback, handle = h)

    # Combine all accumulated text chunks into one full text
    final_output <- paste(accumulated_output, collapse = " ")
    return(list(full_text = final_output, chunks = accumulated_output))
  }
}
