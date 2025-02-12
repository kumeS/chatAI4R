#' Chat4R Function
#'
#' @title Chat4R: Interact with gpt-4o-mini (default) using OpenAI API
#' @description This function uses the OpenAI API to interact with the
#'    gpt-4o-mini model (default) and generates responses based on user input.
#'    In this function, currently, "gpt-4o-mini", "gpt-4o", "gpt-4",
#'    "gpt-4-turbo" and "gpt-3.5-turbo"
#'    can be selected as OpenAI's LLM model.
#' @param content A string containing the user's input message.
#' @param api_key A string containing the user's OpenAI API key.
#'    Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string specifying the GPT model to use (default: "gpt-4o-mini").
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @param simple Logical, if TRUE, only the content of the model's message will be returned.
#' @param fromJSON_parsed Logical, if TRUE, content will be parsed from JSON.
#' @param check Logical, if TRUE, prints detailed error information (message, type, param, code) if the API response includes an error.
#'    If there is no error, "No error" is printed.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON fromJSON
#' @return A data frame or list containing the response from the GPT model, depending on arguments.
#' @export chat4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#' chat4R(content = "What is the capital of France?", check = TRUE)
#'
#' }

chat4R <- function(content,
                   Model = "gpt-4o-mini",
                   temperature = 1,
                   simple = TRUE,
                   fromJSON_parsed = FALSE,
                   check = FALSE,
                   api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Define parameters
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- httr::add_headers(
    `Content-Type` = "application/json",
    `Authorization` = paste("Bearer", api_key)
  )

  # Define the body of the API request
  body <- list(
    model = Model,
    messages = list(list(role = "user", content = content)),
    temperature = temperature,
    top_p = top_p,
    n = n
  )

  # Send a POST request to the OpenAI server
  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )

  # Optionally check and display error information
  if (check) {
    resp_parsed <- httr::content(response, "parsed")

    # If no 'error' object is present, print "No error"
    if (is.null(resp_parsed$error)) {
      message("Status: No error")
    } else {
      message("Status: Error")
      message("Error message: ", resp_parsed$error$message)
      message("Error type: ", resp_parsed$error$type)
      message("Error param: ", resp_parsed$error$param)
      message("Error code: ", resp_parsed$error$code)
    }
  }

  # Extract and return the response content in the requested format
  if (simple) {
    return(data.frame(content = httr::content(response, "parsed")$choices[[1]]$message$content))
  } else {
    if (fromJSON_parsed) {
      raw_content <- httr::content(response, "raw")
      char_content <- rawToChar(raw_content)
      parsed_data <- jsonlite::fromJSON(char_content)
      return(parsed_data)
    } else {
      return(data.frame(httr::content(response, "parsed")))
    }
  }
}
