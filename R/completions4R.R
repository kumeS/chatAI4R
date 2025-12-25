#' @title completions4R: Generate text using OpenAI completions API (Legacy - DEPRECATED)
#' @description **[WARNING] DEPRECATED AND SCHEDULED FOR REMOVAL**: This function uses the legacy OpenAI completions API 
#'   which is being phased out by OpenAI. **This function will be removed in a future version.**
#'   
#'   **MIGRATION REQUIRED**: Please migrate to chat4R() for all new implementations.
#'   The chat4R() function uses the modern OpenAI Chat Completions API and provides better performance,
#'   more features, and continued support.
#'   
#'   **Migration Example**:
#'   ```r
#'   # Old (deprecated):
#'   result <- completions4R("Your prompt here")
#'   
#'   # New (recommended):
#'   result <- chat4R("Your prompt here")
#'   text_content <- result$content
#'   ```
#'   
#'   This function sends a request to the OpenAI completions API to generate text based on the provided prompt and parameters.
#' @param prompt A string. The initial text that the model responds to.
#' @param api_key A string. The API key for OpenAI. Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param Model A string. The model ID to use, such as "davinci-002" or "gpt-3.5-turbo-instruct".
#' @param max_tokens Integer. The maximum number of tokens to generate.
#' @param temperature A numeric value to control the randomness of the generated text.
#'   A value close to 0 produces more deterministic output, while a higher value (up to 2) produces more random output.
#' @param simple If TRUE, returns the generated text without newline characters. If FALSE, returns the full response from the API.
#' @importFrom httr POST add_headers content status_code
#' @importFrom jsonlite toJSON
#' @return The generated text or the full response from the API, depending on the value of `simple`.
#' @export completions4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # DEPRECATED: Use chat4R() instead for new code
#' Sys.setenv(OPENAI_API_KEY = "Your API key")
#'
#' prompt <- "Translate the following English text to French: 'Hello, world!'"
#'
#' completions4R(prompt)
#' }


completions4R <- function(prompt,
                          api_key = Sys.getenv("OPENAI_API_KEY"),
                          Model = "gpt-3.5-turbo-instruct",
                          max_tokens = 50,
                          temperature = 1,
                          simple = TRUE){

  # Issue strong deprecation warning
  warning("CRITICAL: completions4R() is DEPRECATED and scheduled for removal. The OpenAI completions API is being phased out. Please migrate to chat4R() immediately. See ?completions4R for migration examples.", call. = FALSE)

  # Validate model parameter
  valid_models <- c("gpt-3.5-turbo-instruct", "davinci-002", "babbage-002")
  if (!Model %in% valid_models) {
    warning("Model '", Model, "' may not be supported. Recommended models: ", paste(valid_models, collapse = ", "))
  }

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
  resp_parsed <- httr::content(response, "parsed")

  # Extract and return the response content with safe access
  if(simple){
    # Safe access to nested data structure
    if (!is.null(resp_parsed$choices) && length(resp_parsed$choices) > 0 && 
        !is.null(resp_parsed$choices[[1]]$text)) {
      return(gsub("\n", "", resp_parsed$choices[[1]]$text))
    } else {
      stop("Unexpected API response format: choices or text not found")
    }
  } else {
    return(resp_parsed)
  }

}
