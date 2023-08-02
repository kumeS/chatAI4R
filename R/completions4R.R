#' @title completions4R: Generate text using OpenAI completions API (Legacy)
#' @description This function sends a request to the OpenAI completions API (Legacy)
#'   to generate text based on the provided prompt and parameters.
#' @param prompt A string. The initial text that the model responds to.
#' @param api_key A string. The API key for OpenAI. Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string. The model ID to use, such as "text-davinci-003".
#' @param max_tokens Integer. The maximum number of tokens to generate.
#' @param temperature A numeric value to control the randomness of the generated text.
#'   A value close to 0 produces more deterministic output, while a higher value (up to 2) produces more random output.
#' @param simple If TRUE, returns the generated text without newline characters. If FALSE, returns the full response from the API.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @return The generated text or the full response from the API, depending on the value of `simple`.
#' @export completions4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#'
#' prompt <- "Translate the following English text to French: 'Hello, world!'"
#'
#' completions4R(prompt)
#' }


completions4R <- function(prompt,
                          api_key = Sys.getenv("OPENAI_API_KEY"),
                          Model = "text-davinci-003",
                          max_tokens =  50,
                          temperature = 1,
                          simple=TRUE){

  # Define parameters
  api_url <- "https://api.openai.com/v1/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "application/json",
                      `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  body <- list(model = Model,
               prompt = prompt,
               max_tokens = max_tokens,
               temperature = temperature, top_p = top_p, n = n)

  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Extract and return the response content
  if(simple){
   return(gsub("\n", "", httr::content(response, "parsed")$choices[[1]]$text))
  }else{
  return(httr::content(response, "parsed"))
  }

}
