#' Generate Images from Text
#'
#' @title Generate Images from Text
#' @description This function generates images from text using the OpenAI API.
#' @param content A character string describing the image to be generated.
#' @param n Integer specifying the number of images to generate. Must be between 1 and 10.
#' @param size A character string specifying the size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
#' @param response_format A character string specifying the format in which the generated images are returned. Must be one of "url" or "b64_json".
#' @param Output_image Logical indicating whether to return the images or their URLs. If TRUE, the images are returned.
#' @param api_key A character string specifying the OpenAI API key. If not provided, the function will attempt to read it from the system environment.
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @importFrom httr add_headers POST content
#' @importFrom jsonlite toJSON
#' @importFrom purrr map
#' @importFrom EBImage readImage
#' @return A list of images or their URLs, depending on the value of Output_image.
#' @export generateImage4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' generateImage4R(content = "Japanese gal girl", n = 3, size = "256x256",
#'                 response_format = "url", Output_image = TRUE,
#'                 api_key = Sys.getenv("OPENAI_API_KEY"))
#' }

generateImage4R <- function(content,
                            n = 3,
                            size = "256x256",
                            response_format = "url",
                            Output_image = TRUE,
                            api_key = Sys.getenv("OPENAI_API_KEY")){
  # Asserting input types and values
  assertthat::assert_that(is.string(content))
  assertthat::assert_that(is.count(n), n >= 1, n <= 10)
  assertthat::assert_that(is.string(size), size %in% c("256x256", "512x512", "1024x1024"))
  assertthat::assert_that(is.string(response_format), response_format %in% c("url", "b64_json"))
  assertthat::assert_that(is.flag(Output_image))
  assertthat::assert_that(is.string(api_key), nchar(api_key) > 0)

  # Define parameters
  api_url <- "https://api.openai.com/v1/images/generations"

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "application/json",
                               `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  body <- list(prompt = content, n = n, size = size, response_format = response_format)

  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Extract URL
  extract.url <- unlist(httr::content(response, "parsed")$data)
  attr(extract.url, "names") <- NULL

  # Extract and return the response content
  if(Output_image){
    result <- purrr::map(extract.url, ~EBImage::readImage(files = .x, type = "png"))
    return(result)
  } else {
    return(extract.url)
  }
}


