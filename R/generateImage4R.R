#' Generate Text to Images Using OpenAI API
#'
#' @title Generate Text to Images Using OpenAI API
#' @description This function generates images from text input using OpenAI API.
#' @param content A character string, the content to generate images.
#' @param n A count, the number of images to generate. Must be between 1 and 10.
#' @param size A character string, the size of the images. Must be one of "256x256", "512x512", "1024x1024".
#' @param response_format A character string, the format of the response from the API. Must be one of "url", "b64_json".
#' @param Output_image A flag, whether to output the images.
#' @param SaveImg A flag, whether to save the images.
#' @param api_key A character string, the API key for OpenAI.
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @importFrom httr add_headers POST content
#' @importFrom jsonlite toJSON
#' @importFrom purrr map
#' @importFrom EBImage readImage
#' @return If Output_image is TRUE, returns a list of images; if Output_image is FALSE, returns a character vector of URLs.
#' @export generateImage4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Generate images
#' results <- generateImage4R(content = "Japanese gal girl", n = 3)
#' # Display the generated images
#' Display(results)
#' }


generateImage4R <- function(content,
                            n = 3,
                            size = "256x256",
                            response_format = "url",
                            Output_image = TRUE,
                            SaveImg = FALSE,
                            api_key = Sys.getenv("OPENAI_API_KEY")){
  # Asserting input types and values
  assertthat::assert_that(assertthat::is.string(content), nchar(content) > 0)
  assertthat::assert_that(assertthat::is.count(n), n >= 1, n <= 10)
  assertthat::assert_that(assertthat::is.string(size), size %in% c("256x256", "512x512", "1024x1024"))
  assertthat::assert_that(assertthat::is.string(response_format), response_format %in% c("url", "b64_json"))
  assertthat::assert_that(assertthat::is.flag(Output_image))
  assertthat::assert_that(assertthat::is.flag(SaveImg))
  assertthat::assert_that(assertthat::is.string(api_key), nchar(api_key) > 0)

  # If content is empty, stop execution
  if(content == "") {
    warning("No input provided.")
    stop()
  }

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
    if(SaveImg){ saveRDS(result, file = paste0("CreatedImg_", formatC(length(dir(pattern = "[.]Rds"))+1, flag = "0", width = 3), ".Rds")) }
    return(result)
  } else {
    return(extract.url)
  }
}
