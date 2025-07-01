#' Chat History for R
#'
#' @title chat4R_history: Use chat history for interacting with GPT.
#' @description This function use the chat history with the the specified GPT model, and chat the AI model.
#' @param history A list of message objects.
#'   Each object should have a 'role' that can be 'system', 'user', or 'assistant',
#'   and 'content' which is the content of the message from that role.
#' @param api_key A string. Input your OpenAI API key. Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string. The model to use for the chat completion. Default is "gpt-4o-mini".
#' @param temperature The temperature to use for the chat completion. Default is 1.
#' @importFrom httr add_headers POST content
#' @importFrom jsonlite toJSON
#' @return A data frame containing the parsed response from the Web API server.
#' @export chat4R_history
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#'
#' history <- list(list('role' = 'system', 'content' = 'You are a helpful assistant.'),
#'                 list('role' = 'user', 'content' = 'Who won the world series in 2020?'))
#'
#' chat4R_history(history)
#' }
#'


chat4R_history <- function(history,
                           api_key = Sys.getenv("OPENAI_API_KEY"),
                           Model = "gpt-4o-mini",
                           temperature = 1) {

  # Setting parameters
  # See detail: https://platform.openai.com/docs/guides/chat
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Creating headers
  headers <-
    httr::add_headers(`Content-Type` = "application/json",
                      `Authorization` = paste("Bearer", api_key))

  # Using the history variable to create arguments
  body <-
    list(model = Model,
         messages = history,
         temperature = temperature, top_p = top_p, n = n)

  # Sending a request to the server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Check HTTP status code first
  if (httr::status_code(response) != 200) {
    error_content <- httr::content(response, "parsed")
    error_msg <- if (!is.null(error_content$error$message)) {
      error_content$error$message
    } else {
      paste("HTTP", httr::status_code(response), "error")
    }
    stop("API Error (", httr::status_code(response), "): ", error_msg)
  }

  # Parse response content safely
  resp_parsed <- httr::content(response, "parsed")

  # Safe access to nested data structure
  if (!is.null(resp_parsed$choices) && length(resp_parsed$choices) > 0 && 
      !is.null(resp_parsed$choices[[1]]$message) && 
      !is.null(resp_parsed$choices[[1]]$message$content)) {
    return(data.frame(content = resp_parsed$choices[[1]]$message$content))
  } else {
    stop("Unexpected API response format: choices or message content not found")
  }
}



