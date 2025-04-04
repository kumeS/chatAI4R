#' Gemini API Google Search Grounding Request Function
#'
#' This function sends a request to the Gemini API with Google Search grounding enabled.
#' Grounding improves the factuality of the answer by incorporating the latest web search results.
#'
#' @param mode A character string specifying the mode. Valid values are "text", "stream_text", "chat", "stream_chat".
#' @param contents For "text" or "stream_text" modes, a character string with the input text.
#'   For "chat" or "stream_chat" modes, a list of messages. Each message is a list with fields:
#'   \code{role} (e.g., "user" or "model") and \code{text} (the message content).
#' @param store_history Logical. If TRUE in chat mode, the chat history is stored in the environment
#'   variable "chat_history" as a JSON string.
#' @param dynamic_threshold A numeric value [0,1] specifying the dynamic retrieval threshold.
#'   The default is 1, meaning grounding is always applied.
#' @param api_key A character string containing your Gemini API key.
#' @param ... Additional options passed to the HTTP request.
#'
#' @return For synchronous modes ("text", "chat"), a parsed JSON object is returned.
#'   For streaming modes ("stream_text", "stream_chat"), a list with \code{full_text} (combined output)
#'   and \code{chunks} (individual text pieces) is returned.
#'
#' @export geminiGrounding4R
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#'   # Synchronous text generation with grounding:
#'   result <- geminiGrounding4R(
#'     mode = "text",
#'     contents = "What is the current Google stock price?",
#'     store_history = FALSE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(result)
#'
#'   # Chat mode with history storage:
#'   chat_history <- list(
#'     list(role = "user", text = "Hello"),
#'     list(role = "model", text = "Hi there! How can I help you?")
#'   )
#'   chat_result <- geminiGrounding4R(
#'     mode = "chat",
#'     contents = chat_history,
#'     store_history = TRUE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(chat_result)
#'
#'   # Streaming text generation:
#'   stream_result <- geminiGrounding4R(
#'     mode = "stream_text",
#'     contents = "Tell me a story about a magic backpack.",
#'     store_history = FALSE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(stream_result$full_text)
#' }

geminiGrounding4R <- function(mode, contents, store_history = FALSE, dynamic_threshold = 1, api_key, ...) {
  # Validate the mode parameter
  mode <- tolower(mode)
  valid_modes <- c("text", "stream_text", "chat", "stream_chat")
  if (!(mode %in% valid_modes)) {
    stop("Invalid mode specified. Choose one of: ", paste(valid_modes, collapse = ", "))
  }

  # Determine the endpoint based on the mode.
  # This example uses a Gemini 1.5 Pro model that supports grounding.
  if (mode == "text") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:generateContent?key=", api_key)
  } else if (mode == "stream_text") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:streamGenerateContent?alt=sse&key=", api_key)
  } else if (mode == "chat") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:generateContent?key=", api_key)
  } else if (mode == "stream_chat") {
    endpoint <- paste0("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:streamGenerateContent?alt=sse&key=", api_key)
  }

  # Build the request body. Add the tool setting for Google Search grounding.
  grounding_tool <- list(
    google_search_retrieval = list(
      dynamic_retrieval_config = list(
        mode = "MODE_DYNAMIC",
        dynamic_threshold = dynamic_threshold
      )
    )
  )

  if (mode %in% c("text", "stream_text")) {
    if (!is.list(contents)) {
      request_body <- list(
        contents = list(
          list(parts = list(list(text = contents)))
        ),
        tools = list(grounding_tool)
      )
    } else {
      request_body <- list(
        contents = contents,
        tools = list(grounding_tool)
      )
    }
  } else if (mode %in% c("chat", "stream_chat")) {
    request_body <- list(
      contents = lapply(contents, function(msg) {
        list(
          role = msg$role,
          parts = list(list(text = msg$text))
        )
      }),
      tools = list(grounding_tool)
    )
  }

  # Convert the request body to a JSON string
  json_body <- toJSON(request_body, auto_unbox = TRUE)

  # Synchronous modes ("text" and "chat")
  if (mode %in% c("text", "chat")) {
    response <- POST(
      url = endpoint,
      body = json_body,
      encode = "json",
      add_headers("Content-Type" = "application/json"),
      ...
    )

    # Check for HTTP errors
    if (http_error(response)) {
      stop("HTTP error: ", status_code(response))
    }

    res_content <- content(response, as = "text", encoding = "UTF-8")
    parsed_response <- fromJSON(res_content, simplifyVector = FALSE)

    # For chat mode with history storage, update the environment variable
    if (mode == "chat" && store_history) {
      prev_history <- Sys.getenv("chat_history")
      if (nzchar(prev_history)) {
        prev_history_list <- fromJSON(prev_history, simplifyVector = FALSE)
      } else {
        prev_history_list <- list()
      }
      new_history <- c(prev_history_list, request_body$contents, parsed_response)
      Sys.setenv(chat_history = toJSON(new_history, auto_unbox = TRUE))
    }

    return(parsed_response)
  }

  # Streaming modes ("stream_text" and "stream_chat")
  if (mode %in% c("stream_text", "stream_chat")) {
    h <- new_handle()
    handle_setheaders(h, "Content-Type" = "application/json")
    handle_setopt(h, post = TRUE, postfields = json_body)

    accumulated_output <- character()

    callback <- function(data, ...) {
      chunk <- rawToChar(data)
      lines <- strsplit(chunk, "\n")[[1]]
      for (line in lines) {
        line <- trimws(line)
        if (nchar(line) == 0) next
        if (startsWith(line, "data:")) {
          data_line <- sub("^data:\\s*", "", line)
          if (data_line == "[DONE]") next
          parsed_chunk <- tryCatch({
            fromJSON(data_line, simplifyVector = FALSE)
          }, error = function(e) {
            warning("Failed to parse JSON chunk: ", data_line)
            NULL
          })
          if (!is.null(parsed_chunk)) {
            if (!is.null(parsed_chunk$text)) {
              accumulated_output <<- c(accumulated_output, parsed_chunk$text)
            } else if (!is.null(parsed_chunk$candidates)) {
              candidate_texts <- sapply(parsed_chunk$candidates, function(x) x$output)
              accumulated_output <<- c(accumulated_output, candidate_texts)
            }
            if (mode == "stream_chat" && store_history) {
              prev_history <- Sys.getenv("chat_history")
              if (nzchar(prev_history)) {
                prev_history_list <- fromJSON(prev_history, simplifyVector = FALSE)
              } else {
                prev_history_list <- list()
              }
              new_history <- c(prev_history_list, list(parsed_chunk))
              Sys.setenv(chat_history = toJSON(new_history, auto_unbox = TRUE))
            }
          }
        }
      }
      return(length(data))
    }

    curl_fetch_stream(url = endpoint, fun = callback, handle = h)
    final_output <- paste(accumulated_output, collapse = " ")
    return(list(full_text = final_output, chunks = accumulated_output))
  }
}
