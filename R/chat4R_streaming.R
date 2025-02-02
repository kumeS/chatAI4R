#' Chat4R Function with Streaming
#'
#' @title chat4R_streaming: Interact with GPT-4o (default) with streaming using OpenAI API
#' @description This function uses the OpenAI API to interact with the
#'    GPT-4o model (default) and generates responses based on user input with
#'    streaming data back to R
#'    In this function, currently, "gpt-4o-mini", "gpt-4o", and "gpt-4-turbo"
#'    can be selected as OpenAI's LLM model.
#' @param content A string containing the user's input message.
#' @param api_key A string containing the user's OpenAI API key.
#'    Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string specifying the GPT model to use (default: "GPT-4o").
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON fromJSON
#' @return A data frame containing the response from the GPT model.
#' @export chat4R_streaming
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#' response <- chat4R_streaming(content = "What is the capital of France?")
#' response
#' }

chat4R_streaming <- function(content,
                             Model = "gpt-4o-mini",
                             temperature = 1,
                             api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Define parameters
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- c(`Content-Type` = "application/json",
                `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  body <- list(model = Model,
               messages = list(list(role = "user", content = content)),
               temperature = temperature, top_p = top_p, n = n,
               stream = TRUE)

# Function to process streaming data
streaming_callback <- function(data) {

  #print(data)
  # Convert raw data to character
  message <- rawToChar(data)
  #print(message)

  # Split message into lines
  lines <- unlist(strsplit(message, "\n"))
  #print(lines)

  for (line in lines) {
    if(line == "data: [DONE]"){}else{
    if(line != ""){
      # Remove the "data: " prefix
      json_line <- sub("data: ", "", line)
      #print(json_line)
      json <- fromJSON(json_line)$choices$delta$content
      cat(json)
    }}}
}

# Perform the request with streaming using httr::write_stream
response <- httr::POST(
  url = api_url,
  body = body,
  encode = "json",
  httr::add_headers(.headers = headers),
  httr::write_stream(streaming_callback)
)

# Check response status
#print(response)

}
