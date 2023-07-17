#' Generate Image Variations using OpenAI
#'
#' This function generates variations of a given image using OpenAI's image API.
#' It uses OpenAI's image API to generate a specified number of variations for a provided image.
#'
#' @title Generate Image Variations using OpenAI
#' @description Generates variations of a given image using the OpenAI API.
#' It generates n number of variations of a provided image.
#' The output can either be a list of URLs pointing to the generated images or the images themselves in base64 encoded JSON format.
#'
#' @param image A string. This is the path to the image file to be used as the basis for the variations.
#' Must be a valid PNG file, less than 4MB, and square.
#' @param n An integer. This is the number of image variations to generate.
#' Must be between 1 and 10. The default is 3.
#' @param size A string. This is the size of the generated images.
#' Must be one of 256x256, 512x512, or 1024x1024.
#' @param response_format A string. This is the format in which the generated images are returned.
#' Must be one of "url" or "b64_json". The default is "url".
#' @param Output_image A boolean. If TRUE, the output will be images themselves.
#' If FALSE, the output will be URLs pointing to the images. The default is TRUE.
#' @param api_key A string. This is your OpenAI API key. By default, it uses the key stored in the OPENAI_API_KEY environment variable.
#'
#' @importFrom httr POST add_headers content
#' @importFrom assertthat assert_that is.count is.string is.flag
#' @importFrom purrr map
#' @importFrom EBImage readImage
#'
#' @return A list. This list contains either URLs pointing to the generated images
#' or the images themselves in base64 encoded JSON format, depending on the `Output_image` parameter.
#'
#' @export generateImageVariation4R
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Define the path to the image
#' image_path = "path_to_your_image.png"
#'
#' # Generate image variations
#' res <- generateImageVariation4R(image = image_path, n = 3, size = "256x256",
#' response_format = "url", Output_image = TRUE)
#'
#' # Display the generated image variations
#' Display(res)
#' }

generateImageVariation4R <- function(image,
                        n = 3,
                        size = "256x256",
                        response_format = "url",
                        Output_image = TRUE,
                        api_key = Sys.getenv("OPENAI_API_KEY")){
  # Asserting input types and values
  assertthat::assert_that(file.exists(image))
  assertthat::assert_that(assertthat::is.count(n), n >= 1, n <= 10)
  assertthat::assert_that(assertthat::is.string(size), size %in% c("256x256", "512x512", "1024x1024"))
  assertthat::assert_that(assertthat::is.string(response_format), response_format %in% c("url", "b64_json"))
  assertthat::assert_that(assertthat::is.flag(Output_image))
  assertthat::assert_that(assertthat::is.string(api_key), nchar(api_key) > 0)

  # Define parameters
  api_url <- "https://api.openai.com/v1/images/variations"

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "multipart/form-data",
                               `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  body <- list(image = httr::upload_file(image), n = n, size = size, response_format = response_format)

  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = body,
                         encode = "multipart", config = headers)

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
