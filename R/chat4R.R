#' Chat4R Function
#'
#' @title Chat4R: Interact with gpt-3.5-turbo-16k (default) using OpenAI API
#' @description This function uses the OpenAI API to interact with the GPT-3.5-turbo model (default)
#' and generates responses based on user input.
#' @param content A character string containing the user's input message.
#' @param api_key A character string containing the user's OpenAI API key.
#' @param Model A character string specifying the GPT model to use (default: "gpt-3.5-turbo").
#' @param temperature Numeric value controlling the randomness of the model's output (default: 1).
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @return A data frame containing the response from the chatGPT model.
#' @export chat4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' api_key <- "your_api_key_here"
#' response <- chat4R("What is the capital of France?", api_key)
#'
#' #Check the result
#' response
#' }
#'

chat4R <- function(content, api_key,
                   Model = "gpt-3.5-turbo-16k",
                   temperature = 1) {

  # Set parameters
  # See detail: https://platform.openai.com/docs/guides/chat
  api_url <- "https://api.openai.com/v1/chat/completions"
  api_key <- api_key
  n <- 1
  top_p <- 1

  # Create headers
  headers <-
    httr::add_headers(`Content-Type` = "application/json",
                      `Authorization` = paste("Bearer", api_key))

  # Create arguments
  body <-
    list(model = Model,
         messages = list(list(role = "user", content = content)),
         temperature = temperature, top_p = top_p, n = n)

  # Send POST request to the server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Extract content from the request
  return(data.frame(httr::content(response, "parsed")))
}


