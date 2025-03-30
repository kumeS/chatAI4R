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
#' @import httr jsonlite
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

  # Validate the endpoint parameter
  if (!endpoint %in% c("chat-messages", "completion-messages")) {
    stop("Invalid endpoint. Please use 'chat-messages' or 'completion-messages'.")
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

  # Parse and return the JSON response as a list
  parsed <- httr::content(response, as = "parsed", encoding = "UTF-8")
  return(parsed)
}


