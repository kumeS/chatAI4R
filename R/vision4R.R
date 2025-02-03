#' Vision API Function using OpenAI's Vision API
#'
#' @title vision4R: Analyze an image using OpenAI's Vision API
#' @description This function uses the OpenAI Vision API to analyze an image provided by the user.
#'   The function sends the image along with an optional prompt and system message to the API,
#'   and returns the analysis result. The Vision API endpoint is assumed to be similar in structure
#'   to other OpenAI endpoints, accepting multipart/form-data uploads.
#'
#' @param image_path A string specifying the path to the image file to be analyzed.
#' @param prompt A string containing the analysis prompt for the Vision API (optional).
#'   If left empty (i.e., prompt = ""), a notice will be output to remind the user to provide a prompt.
#' @param Model A string specifying the vision model to use. Currently supported models include "gpt-4-vision".
#' @param temperature A numeric value controlling the randomness of the model's output (default: 1).
#' @param system_set A string containing the system message to set the context for the analysis.
#'   If provided, it will be included in the request. Default is an empty string.
#' @param api_key A string containing the user's OpenAI API key.
#'   Defaults to the value of the environment variable "OPENAI_API_KEY".
#'
#' @importFrom httr POST add_headers upload_file content
#' @importFrom jsonlite fromJSON
#'
#' @return A data frame containing the analysis result from the Vision API.
#' @export vision4R
#'
#' @examples
#' \dontrun{
#'   Sys.setenv(OPENAI_API_KEY = "Your API key")
#'
#'   # Analyze an image with a prompt and system context using a supported model "gpt-4-vision"
#'   result <- vision4R(
#'     image_path = "path/to/your/image.jpg",
#'     prompt = "Describe the scene and identify any objects.",
#'     system_set = "You are an expert image analyst.",
#'     Model = "gpt-4-vision",
#'     temperature = 0.8
#'   )
#'   print(result)
#'
#'   # If prompt is empty, a notice will be output
#'   result <- vision4R(
#'     image_path = "path/to/your/image.jpg",
#'     prompt = "",
#'     Model = "gpt-4-vision"
#'   )
#' }

vision4R <- function(image_path,
                     prompt = "",
                     Model = "gpt-4-vision",
                     temperature = 1,
                     system_set = "",
                     api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Define the vector of allowed models.
  allowed_models <- c("gpt-4-vision")

  # Validate that the Model argument is one of the allowed models.
  if (!any(Model == allowed_models)) {
    stop(paste("Invalid model. The vision4R function only supports the following models:",
               paste(allowed_models, collapse = ", ")))
  }

  # Check if prompt is empty and output a notice if it is.
  if (prompt == "") {
    message("NOTE: The prompt is empty. Please provide a prompt for more accurate analysis.")
  }

  # Define the Vision API endpoint.
  api_url <- "https://api.openai.com/v1/vision/completions"

  # Construct the body for the API request using multipart/form-data.
  body <- list(
    model = Model,
    prompt = prompt,
    temperature = temperature,
    file = httr::upload_file(image_path)
  )

  # Include system_set if provided.
  if (nzchar(system_set)) {
    body$system <- system_set
  }

  # Configure headers for the API request (Authorization header).
  headers <- httr::add_headers(
    `Authorization` = paste("Bearer", api_key)
  )

  # Send the POST request to the OpenAI Vision API.
  response <- httr::POST(
    url = api_url,
    body = body,
    encode = "multipart",
    config = headers
  )

  # Extract and parse the response content.
  parsed_content <- httr::content(response, "parsed")

  # Process and return the result.
  # This example assumes the API response contains a 'choices' element with the analysis result.
  if (!is.null(parsed_content$choices) && length(parsed_content$choices) > 0) {
    return(data.frame(content = parsed_content$choices[[1]]$message$content, stringsAsFactors = FALSE))
  } else {
    return(parsed_content)
  }
}
