#' DifyChat4R Function (Completion Messages Only)
#'
#' @description
#' This function sends a query to the Dify API using the completion-messages endpoint in blocking mode.
#' It provides a simple interface for interacting with Dify AI applications.
#' The function uses the stable blocking response mode to avoid streaming parsing issues.
#'
#' @param query A character string representing the user's input query.
#' @param user A character string representing the user identifier. Default is "abc-123".
#' @param api_key A character string for the Dify API secret key.
#'        Defaults to the value of the environment variable "DIFY_API_KEY".
#' @param conversation_id A character string representing the conversation ID. Default is an empty string.
#' @param files A list of lists representing file information to be sent with the query. Default is NULL.
#'        Each file should be a list containing at least the keys:
#'          - type (e.g., "image")
#'          - transfer_method (e.g., "remote_url")
#'          - url (the file URL)
#'
#' @return A list containing the parsed JSON response from the Dify API.
#'
#' @importFrom httr POST add_headers content status_code
#' @importFrom jsonlite toJSON
#' @export DifyChat4R
#'
#' @examples
#' \dontrun{
#'   # Set your Dify API key in the environment or pass it directly
#'   Sys.setenv(DIFY_API_KEY = "YOUR-DIFY-SECRET-KEY")
#'
#'   # Basic usage
#'   response <- DifyChat4R(query = "Hello world!")
#'   print(response)
#'
#'   # With conversation context
#'   response <- DifyChat4R(
#'     query = "How are you?",
#'     conversation_id = "conv-123",
#'     user = "user-456"
#'   )
#'   print(response)
#' }
#'

DifyChat4R <- function(query,
                        user = "abc-123",
                        api_key = Sys.getenv("DIFY_API_KEY"),
                        conversation_id = "",
                        files = NULL) {

  # Input validation
  if (!is.character(query) || length(query) != 1 || nchar(query) == 0) {
    stop("query must be a non-empty character string", call. = FALSE)
  }
  
  if (!is.character(api_key) || length(api_key) != 1 || nchar(api_key) == 0) {
    stop("api_key must be a non-empty character string. Set DIFY_API_KEY environment variable.", call. = FALSE)
  }
  
  if (!is.character(user) || length(user) != 1) {
    stop("user must be a character string", call. = FALSE)
  }

  # Set the API endpoint (completion-messages only)
  api_url <- "https://api.dify.ai/v1/completion-messages"

  # Set the API headers
  headers <- httr::add_headers(
    `Authorization` = paste("Bearer", api_key),
    `Content-Type`  = "application/json"
  )

  # Create the request body for completion-messages
  body <- list(
    inputs = list(query = query),
    response_mode = "blocking",  # Fixed to blocking mode to avoid streaming issues
    user = user
  )
  
  # Add conversation_id only if not empty
  if (conversation_id != "") {
    body$conversation_id <- conversation_id
  }

  # Include files if provided
  if (!is.null(files)) {
    body$files <- files
  }

  # Send the POST request to the Dify API
  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )

  # Validate HTTP status code before parsing response
  status_code <- httr::status_code(response)
  if (status_code != 200) {
    error_content <- tryCatch(httr::content(response, "parsed"), error = function(e) NULL)
    
    # Extract error message with safe handling
    error_msg <- if (!is.null(error_content) && !is.null(error_content$message)) {
      error_content$message
    } else if (!is.null(error_content) && !is.null(error_content$error)) {
      error_content$error
    } else {
      paste("Dify API error with status code", status_code)
    }
    
    stop("Dify API Error (", status_code, "): ", error_msg, call. = FALSE)
  }

  # Parse and return the JSON response as a list with safe error handling
  parsed <- tryCatch({
    httr::content(response, as = "parsed", encoding = "UTF-8")
  }, error = function(e) {
    stop("Failed to parse Dify API response: ", e$message, call. = FALSE)
  })
  
  # Validate that we received a valid response structure
  if (is.null(parsed)) {
    stop("Dify API returned empty response", call. = FALSE)
  }
  
  return(parsed)
}


