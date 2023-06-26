#' @title Text Embedding from OpenAI API
#' @description This function calls the OpenAI API to get the text embedding of the input text.
#' @param text The input text to get the embedding for. This should be a character string.
#' @param api_key The API key for the OpenAI API. This should be a character string.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @return A character string representing the text embedding from the OpenAI API.
#' @export textEmbedding
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' 　Sys.setenv(OPENAI_API_KEY = "Your API key")
#'   textEmbedding("Hello, world!")
#' }


textEmbedding <- function(text,
                          api_key = Sys.getenv("OPENAI_API_KEY")) {

  #API endpoint
  url <- "https://api.openai.com/v1/embeddings"

  # Header information (set API key)
  headers <- httr::add_headers(
    `Content-Type` = "application/json",
    `Authorization` = paste("Bearer", api_key)
  )

  # Request body (set text data)
  body <- list(
    "input" = text,
    "model" = "text-embedding-ada-002"
  )

  # Send POST request to the server
  response <- httr::POST(url = url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Parse response
  content <- httr::content(response, "parsed")

  #convert to vector
  v <- unlist(content$data[[1]]$embedding)

  # Return vector
  return(v)
}
