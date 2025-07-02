#' chat4Rv2 Function
#'
#' @title chat4Rv2: Interact with gpt-4o-mini (default) using OpenAI API
#' @description This function uses the OpenAI API to interact with the
#'    gpt-4o-mini model (default) and generates responses based on user input.
#'    In this function, currently, "gpt-4o-mini" (default), "gpt-4o", "gpt-4", and "gpt-4-turbo"
#'    can be selected as OpenAI's LLM model.
#' @param content A string containing the user's input message.
#' @param api_key A string containing the user's OpenAI API key.
#'    Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string specifying the GPT model to use (default: "gpt-4o-mini").
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @param max_tokens A numeric value specifying the maximum number of tokens to generate (default is 50).
#' @param simple Logical, if TRUE, only the content of the model's message will be returned.
#' @param fromJSON_parsed Logical, if TRUE, content will be parsed from JSON.
#' @param system_prompt A string containing the system message to set the context.
#'    If provided, it will be added as the first message in the conversation.
#'    Default is an empty string.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @return A data frame containing the response from the GPT model.
#' @export chat4Rv2
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#' # Using chat4Rv2 without system_prompt (default behavior)
#' response <- chat4Rv2(content = "What is the capital of France?")
#' response
#'
#' # Using chat4Rv2 with a system_prompt provided
#' response <- chat4Rv2(content = "What is the capital of France?",
#'                      system_prompt = "You are a helpful assistant.")
#' response
#' }

chat4Rv2 <- function(content,
                     Model = "gpt-4o-mini",
                     temperature = 1,
                     max_tokens = 50,
                     simple = TRUE,
                     fromJSON_parsed = FALSE,
                     system_prompt = "",
                     api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Define parameters
  api_url <- "https://api.openai.com/v1/chat/completions"
  n <- 1
  top_p <- 1

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "application/json",
                               `Authorization` = paste("Bearer", api_key))

  # Construct messages list depending on system_prompt parameter
  if (nzchar(system_prompt)) {
    # Include system message if provided
    messages_list <- list(
      list(role = "system", content = system_prompt),
      list(role = "user", content = content)
    )
  } else {
    # Only include user message if system_prompt is empty
    messages_list <- list(
      list(role = "user", content = content)
    )
  }

  # Define the body of the API request including max_tokens
  body <- list(model = Model,
               messages = messages_list,
               temperature = temperature,
               max_tokens = max_tokens,
               top_p = top_p,
               n = n)

  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json",
                         config = headers)

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

  # Parse response content safely
  resp_parsed <- httr::content(response, "parsed")

  # Extract and return the response content with safe access
  if (simple) {
    # Safe access to nested data structure
    if (!is.null(resp_parsed$choices) && length(resp_parsed$choices) > 0 && 
        !is.null(resp_parsed$choices[[1]]$message) && 
        !is.null(resp_parsed$choices[[1]]$message$content)) {
      return(data.frame(content = resp_parsed$choices[[1]]$message$content))
    } else {
      stop("Unexpected API response format: choices or message content not found")
    }
  } else {
    if (fromJSON_parsed) {
      raw_content <- httr::content(response, "raw")
      char_content <- rawToChar(raw_content)
      parsed_data <- jsonlite::fromJSON(char_content)
      return(parsed_data)
    } else {
      return(data.frame(resp_parsed))
    }
  }
}
