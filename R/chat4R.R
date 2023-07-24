#' Chat4R Function
#'
#' @title Chat4R: Interact with GPT-3.5 (default) using OpenAI API
#' @description This function uses the OpenAI API to interact with the
#'   GPT-3.5 model (default) and generates responses based on user input.
#' @param content A string containing the user's input message.
#' @param api_key A string containing the user's OpenAI API key.
#' @param Model A string specifying the GPT model to use (default: "gpt-3.5-turbo-16k").
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @param simple Logical, if TRUE, only the content of the model's message will be returned.
#' @param fromJSON_parsed Logical, if TRUE, content will be parsed from JSON.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @return A data frame containing the response from the GPT model.
#' @export chat4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#' response <- chat4R("What is the capital of France?")
#' response
#' }

chat4R <- function(content,
                   Model = "gpt-3.5-turbo-16k",
                   temperature = 1,
                   simple=TRUE,
                   fromJSON_parsed=FALSE,
                   api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Define parameters
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "application/json",
                      `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  body <- list(model = Model,
               messages = list(list(role = "user", content = content)),
               temperature = temperature, top_p = top_p, n = n)

  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Extract and return the response content
  if(simple){
   return(data.frame(httr::content(response, "parsed"))$choices.message.content)
  }else{
  if(fromJSON_parsed){
    raw_content <- httr::content(response, "raw")
    char_content <- rawToChar(raw_content)
    parsed_data <- jsonlite::fromJSON(char_content)
    return(parsed_data)
  }else{
    return(data.frame(httr::content(response, "parsed")))
  }
  }
}
