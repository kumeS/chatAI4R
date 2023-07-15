#' Edit or Extend Images with OpenAI API
#'
#' This function takes in an image file and a text prompt, and makes a request to OpenAI's API
#' to create edited or extended images based on the prompt. It can return either URLs of the generated images
#' or the images themselves, depending on the value of the `Output_image` argument.
#'
#' @title Edit or Extend Images with OpenAI API
#' @description Generates new images by applying text prompts to original images, using OpenAI's API.
#'
#' @param image A string. The file path to the image to edit. Must be a valid PNG file.
#' @param mask An optional string. An additional image file path whose fully transparent areas indicate where image should be edited.
#' @param prompt A string. A text description of the desired images. The maximum length is 1000 characters.
#' @param n An integer. Defaults to 3. The number of images to generate. Must be between 1 and 10.
#' @param size A string. Defaults to "256x256". The size of the generated images. Must be one of "256x256", "512x512", or "1024x1024".
#' @param response_format A string. Defaults to "url". The format in which the generated images are returned. Must be one of "url" or "b64_json".
#' @param Output_image A boolean. Defaults to TRUE. If TRUE, the function returns the generated images. If FALSE, it returns the URLs of the images.
#' @param api_key A string. The OpenAI API key. Defaults to the value of the "OPENAI_API_KEY" environment variable.
#'
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @importFrom httr POST add_headers content upload_file
#' @importFrom jsonlite toJSON
#' @importFrom purrr map
#' @importFrom EBImage readImage
#'
#' @return If `Output_image` is TRUE, returns a list of EBImage objects representing the generated images.
#'         If `Output_image` is FALSE, returns a vector of URLs pointing to the generated images.
#'
#' @export
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Make sure to set your API key first
#' Sys.setenv("OPENAI_API_KEY" = "your_openai_api_key")
#'
#' # Define a file path and a prompt
#' image <- "path_to_your_image.png"
#' prompt <- "Make the image look like it's sunset."
#'
#' # Generate 3 images
#' result <- editImage4R(image = image, prompt = prompt, n = 3)
#' }

editImage4R <- function(image,
                        mask = "",
                        prompt,
                        n = 3,
                        size = "256x256",
                        response_format = "url",
                        Output_image = TRUE,
                        api_key = Sys.getenv("OPENAI_API_KEY")){

  # Asserting input types and values
  assertthat::assert_that(file.exists(image))
  assertthat::assert_that(file.exists(mask))
  assertthat::assert_that(assertthat::is.string(prompt))
  assertthat::assert_that(assertthat::is.count(n), n >= 1, n <= 10)
  assertthat::assert_that(assertthat::is.string(size), size %in% c("256x256", "512x512", "1024x1024"))
  assertthat::assert_that(assertthat::is.string(response_format), response_format %in% c("url", "b64_json"))
  assertthat::assert_that(assertthat::is.flag(Output_image))
  assertthat::assert_that(assertthat::is.string(api_key), nchar(api_key) > 0)

  # Define parameters
  api_url <- "https://api.openai.com/v1/images/edits"

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "multipart/form-data",
                               `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  if(mask != ""){
    body <- list(image = httr::upload_file(image), mask = httr::upload_file(mask), prompt = prompt, n = n, size = size, response_format = response_format)
  }else{
    body <- list(image = httr::upload_file(image), prompt = prompt, n = n, size = size, response_format = response_format)
  }

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
