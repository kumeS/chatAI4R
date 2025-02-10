#' Send Text File Content to OpenAI API and Retrieve Response
#'
#' This function reads the content of a specified text file, sends it to the OpenAI API
#' using the provided API key, and retrieves the generated response from the GPT model.
#'
#' @param file_path A string representing the path to the text or csv file to be read and sent to the API.
#' @param api_key A string containing the OpenAI API key. Defaults to the "OPENAI_API_KEY" environment variable.
#' @param model A string specifying the OpenAI model to be used (default is "gpt-4o-mini").
#' @param system_prompt Optional. A system-level instruction that can be used to guide the model's behavior
#' (default is "You are a helpful assistant to analyze your input.").
#' @param max_tokens A numeric value specifying the maximum number of tokens to generate (default is 50).
#'
#' @return A character string containing the response from the OpenAI API.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @author Satoshi Kume
#' @export textFileInput4ai
#' @examples
#' \dontrun{
#'   # Example usage of the function
#'   api_key <- "YOUR_OPENAI_API_KEY"
#'   file_path <- "path/to/your/text_file.txt"
#'   response <- textFileInput4ai(file_path, api_key = api_key, max_tokens = 50)
#'   cat(response)
#' }

textFileInput4ai <- function(file_path,
                             model = "gpt-4o-mini",
                             system_prompt = "You are a helpful assistant to analyze your input.",
                             max_tokens = 50,
                             api_key = Sys.getenv("OPENAI_API_KEY") ) {
  # Read the text content from the specified file
  text_content <- paste(readLines(file_path, warn = FALSE), collapse = "\n")

  # Define the OpenAI API endpoint URL
  url <- "https://api.openai.com/v1/chat/completions"

  # Define the request headers including the API key for authorization
  headers <- c(
    "Content-Type" = "application/json",
    "Authorization" = paste("Bearer", api_key)
  )

  # Create the JSON-formatted request body with the model, system prompt, file content, and max_tokens
  body <- jsonlite::toJSON(list(
    model = model,
    messages = list(
      list(role = "system", content = system_prompt),
      list(role = "user", content = text_content)
    ),
    max_tokens = max_tokens
  ), auto_unbox = TRUE)

  # Send a POST request to the OpenAI API with the specified headers and body
  response <- httr::POST(url, httr::add_headers(.headers = headers), body = body, encode = "json")

  # Parse the response content from the API
  result <- httr::content(response, "parsed", encoding = "UTF-8")

  # If the API returned valid choices, return the generated text; otherwise, throw an error
  if (!is.null(result$choices) && length(result$choices) > 0) {
    return(result$choices[[1]]$message$content)
  } else {
    stop("No response from OpenAI API. Check your API key and input data.")
  }
}
