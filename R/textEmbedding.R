#' @title Text Embedding from OpenAI Embeddings API
#' @description This function calls the OpenAI Embeddings API to get the multidimensional vector
#'   via text embedding of the input text. This function uses the 'text-embedding-3-small' model by default,
#'   with options for 'text-embedding-3-large' and legacy 'text-embedding-ada-002'.
#' @param text A string. The input text to get the embedding for. This should be a character string.
#' @param model A string. The embedding model to use. Options: "text-embedding-3-small" (default), 
#'   "text-embedding-3-large", "text-embedding-ada-002" (legacy).
#' @param api_key A string. The API key for the OpenAI API. Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @importFrom httr POST add_headers content status_code
#' @importFrom jsonlite toJSON
#' @return A vector representing the text embeddings.
#' @export textEmbedding
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#' textEmbedding("Hello, world!")
#' textEmbedding("Hello, world!", model = "text-embedding-3-large")
#' }


textEmbedding <- function(text,
                          model = "text-embedding-3-small",
                          api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Validate model parameter and warn about deprecated models
  valid_models <- c("text-embedding-3-small", "text-embedding-3-large", "text-embedding-ada-002")
  if (!model %in% valid_models) {
    stop("Invalid model. Choose from: ", paste(valid_models, collapse = ", "))
  }
  
  # Issue deprecation warning for ada-002 model
  if (model == "text-embedding-ada-002") {
    warning("Model 'text-embedding-ada-002' is deprecated. Consider using 'text-embedding-3-small' or 'text-embedding-3-large' for better performance.", call. = FALSE)
  }

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
    "model" = model
  )

  # Send POST request to the server
  response <- httr::POST(url = url,
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

  # Parse response safely
  content <- httr::content(response, "parsed")

  # Safe access to nested data structure
  if (!is.null(content$data) && length(content$data) > 0 && 
      !is.null(content$data[[1]]$embedding)) {
    # Convert to vector
    v <- unlist(content$data[[1]]$embedding)
    return(v)
  } else {
    stop("Unexpected API response format: data or embedding not found")
  }
}
