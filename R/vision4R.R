#' Vision API Function using OpenAI's Vision API
#'
#' @description This function sends a local image along with a text prompt to OpenAI's GPT-4 Vision API.
#'   The function encodes the image in Base64 format and constructs a JSON payload where the user's
#'   message contains both text and an image URL (data URI). This structure mimics the provided Python code.
#'
#' @param image_path A string specifying the path to the image file. The image format should be png or jpeg.
#' @param user_prompt A string containing the text prompt. Default: "What is in this image?".
#' @param Model The model to use. Defaults to "gpt-4-turbo". Allowed values: "gpt-4-turbo", "gpt-4o-mini".
#' @param temperature A numeric value controlling the randomness of the output (default: 1).
#' @param api_key Your OpenAI API key. Default: environment variable `OPENAI_API_KEY`.
#'
#' @importFrom base64enc base64encode
#' @importFrom jsonlite toJSON
#' @importFrom httr POST add_headers content status_code
#' @author Satoshi Kume
#' @export vision4R
#'
#' @return A data frame containing the model's response.
#' @examples
#' \dontrun{
#'   # Example usage of the function
#'   api_key <- "YOUR_OPENAI_API_KEY"
#'   file_path <- "path/to/your/text_file.txt"
#'   vision4R(image_path = file_path, api_key = api_key)
#' }
#'

vision4R <- function(image_path,
                     user_prompt = "What is depicted in this image?",
                     Model = "gpt-4o-mini",
                     temperature = 1,
                     api_key = Sys.getenv("OPENAI_API_KEY")) {

  # Validate if API key is available
  if (api_key == "") {
    stop("Error: API key is missing. Please set the 'OPENAI_API_KEY' environment variable or pass it as an argument.")
  }

  # Validate model selection
  allowed_models <- c("gpt-4o-mini", "gpt-4o")
  if (!Model %in% allowed_models) {
    stop("Invalid model. The vision4R function only supports the following models: ",
         paste(allowed_models, collapse = ", "))
  }

  # Encode the image in Base64 format
  base64_image <- base64enc::base64encode(image_path)
  mime_type <- ifelse(grepl("\\.png$", image_path, ignore.case = TRUE), "image/png", "image/jpeg")
  data_uri <- paste0("data:", mime_type, ";base64,", base64_image)

  # Construct JSON payload with a single message having a content list of two elements
  body <- list(
    model = Model,
    messages = list(
      list(
        role = "user",
        content = list(
          list(
            type = "text",
            text = user_prompt
          ),
          list(
            type = "image_url",
            image_url = list(
              url = data_uri
            )
          )
        )
      )
    ),
    temperature = temperature
  )

  # Convert payload to JSON
  json_payload <- jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE)

  # Send POST request to OpenAI Vision API
  response <- httr::POST(
    url = "https://api.openai.com/v1/chat/completions",
    body = json_payload,
    encode = "json",
    httr::add_headers(
      `Authorization` = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    )
  )

  # Check the response status
  if (httr::status_code(response) != 200) {
    stop("Error: Failed to retrieve a response from OpenAI API. Status code: ",
         httr::status_code(response))
  }

  # Parse the response content
  parsed_content <- httr::content(response, as = "parsed", type = "application/json")
  #parsed_content$choices[[1]]$message$content

  # Return the result
  if (!is.null(parsed_content$choices) && length(parsed_content$choices) > 0) {
    return(data.frame(content = parsed_content$choices[[1]]$message$content,
                      stringsAsFactors = FALSE))
  } else {
    stop("Error: Unexpected response format or no results returned.")
  }
}
