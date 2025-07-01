#' Chat4R Function with Streaming and System Context
#'
#' @title chat4R_streaming: Interact with GPT-4o (default) with streaming using OpenAI API and set system context
#' @description This function uses the OpenAI API to interact with the GPT-4o model (default)
#'   and generates responses based on user input with streaming data back to R.
#'   In this function, currently, "gpt-4o-mini", "gpt-4o", and "gpt-4-turbo" can be selected as OpenAI's LLM model.
#'   Additionally, a system message can be provided to set the context.
#'
#' @param content A string containing the user's input message.
#' @param api_key A string containing the user's OpenAI API key.
#'   Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string specifying the GPT model to use (default: "gpt-4o-mini").
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @param system_set A string containing the system message to set the context.
#'   If provided, it will be added as the first message in the conversation.
#'   Default is an empty string.
#' @importFrom httr POST add_headers content write_stream
#' @importFrom jsonlite toJSON fromJSON
#' @return A data frame containing the response from the GPT model (streamed to the console).
#' @export chat4R_streaming
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   Sys.setenv(OPENAI_API_KEY = "Your API key")
#'
#'   # Without system_set
#'   chat4R_streaming(content = "What is the capital of France?")
#'
#'   # With system_set provided
#'   chat4R_streaming(
#'     content = "What is the capital of France?",
#'     system_set = "You are a helpful assistant."
#'   )
#' }

chat4R_streaming <- function(content,
                             Model = "gpt-4o-mini",
                             temperature = 1,
                             system_set = "",
                             api_key = Sys.getenv("OPENAI_API_KEY")) {
  # Define API parameters
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- c(
    `Content-Type` = "application/json",
    `Authorization` = paste("Bearer", api_key)
  )

  # Construct messages list depending on system_set parameter
  if (nzchar(system_set)) {
    messages_list <- list(
      list(role = "system", content = system_set),
      list(role = "user", content = content)
    )
  } else {
    messages_list <- list(
      list(role = "user", content = content)
    )
  }

  # Define the body of the API request with streaming enabled
  body <- list(
    model = Model,
    messages = messages_list,
    temperature = temperature,
    top_p = top_p,
    n = n,
    stream = TRUE
  )

  # Create an environment to store the accumulated text
  result_env <- new.env()
  result_env$full_text <- ""

  # Function to process streaming data and accumulate text
  streaming_callback <- function(data) {
    # Convert raw data to character
    message <- rawToChar(data)
    # Split the message into individual lines
    lines <- unlist(strsplit(message, "\n"))
    for (line in lines) {
      if (line == "data: [DONE]") {
        next
      } else {
        if (line != "") {
          # Remove the "data: " prefix
          json_line <- sub("data: ", "", line)
          # Attempt to parse JSON safely
          parsed <- tryCatch(
            jsonlite::fromJSON(json_line, simplifyVector = FALSE),
            error = function(e) NULL
          )
          if (is.null(parsed)) next
          # Ensure parsed is a list and contains the expected structure
          if (is.list(parsed) && !is.null(parsed$choices) && length(parsed$choices) > 0) {
            delta <- parsed$choices[[1]]$delta
            if (is.list(delta) && !is.null(delta$content)) {
              # Append the new content to the stored full text
              result_env$full_text <- paste0(result_env$full_text, delta$content)
              # Also output to console
              cat(delta$content)
            }
          }
        }
      }
    }
  }

  # Perform the POST request with streaming enabled using httr::write_stream
  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    httr::add_headers(.headers = headers),
    httr::write_stream(streaming_callback)
  )

  # Check HTTP status code after streaming
  if (httr::status_code(response) != 200) {
    error_content <- httr::content(response, "parsed")
    error_msg <- if (!is.null(error_content$error$message)) {
      error_content$error$message
    } else {
      paste("HTTP", httr::status_code(response), "error")
    }
    stop("API Error (", httr::status_code(response), "): ", error_msg)
  }

  # After streaming completes, return the accumulated text
  return(result_env$full_text)
  #cat(result_env$full_text)
}
