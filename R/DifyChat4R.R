#' DifyChat4R Function (Blocking Mode Only)
#'
#' @description
#' This function sends a chat query to the Dify API using blocking mode.
#' It allows switching between the "chat-messages" and "completion-messages" endpoints.
#' It returns the complete parsed JSON response from the API.
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
#' @param response_mode A character string specifying the response mode. Default is "blocking".
#' @param endpoint A character string specifying which endpoint to use.
#'        Valid values are "chat-messages" and "completion-messages". Default is "chat-messages".
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
#'   # Use the chat-messages endpoint
#'   response_chat <- DifyChat4R(
#'     query = "Hello world via chat!",
#'     endpoint = "chat-messages"
#'   )
#'   print(response_chat)
#'
#'   # Use the completion-messages endpoint
#'   response_completion <- DifyChat4R(
#'     query = "Hello world via completion!",
#'     endpoint = "completion-messages"
#'   )
#'   print(response_completion)
#' }
#'


DifyChat4R <- function(query,
                        user = "abc-123",
                        api_key = Sys.getenv("DIFY_API_KEY"),
                        conversation_id = "",
                        files = NULL,
                        response_mode = "blocking",
                        endpoint = "chat-messages") {

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

  # Validate the endpoint parameter
  if (!endpoint %in% c("chat-messages", "completion-messages")) {
    stop("Invalid endpoint. Please use 'chat-messages' or 'completion-messages'.", call. = FALSE)
  }

  # Set the API endpoint based on the chosen endpoint
  api_url <- paste0("https://api.dify.ai/v1/", endpoint)

  # Set the API headers
  headers <- httr::add_headers(
    `Authorization` = paste("Bearer", api_key),
    `Content-Type`  = "application/json"
  )

  # Create the request body
  body <- list(
    inputs = list(),
    query = query,
    response_mode = response_mode,
    conversation_id = conversation_id,
    user = user
  )

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


