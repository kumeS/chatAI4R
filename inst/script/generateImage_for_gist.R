
#install
pack <- c("assertthat", "httr", "jsonlite", "purrr", "abind", "png", "BiocManager")
install.packages(pack[!(pack %in% unique(rownames(installed.packages())))])

#load
for(n in 1:length(pack)){ eval(parse(text = paste0("library(", pack[n], ")"))) }; rm("n", "pack")

#install
pack <- c("EBImage")
BiocManager::installed(pack[!(pack %in% unique(rownames(installed.packages())))])

#load
for(n in 1:length(pack)){ eval(parse(text = paste0("library(", pack[n], ")"))) }; rm("n", "pack")

#' Generate Images Using OpenAI API
#'
#' @title Generate Images Using OpenAI API
#' @description This function generates images using OpenAI API.
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
#' results <- generateImage4R(content = "Japanese gal girl", n = 3, size = "256x256", response_format = "url", Output_image = TRUE, SaveImg = TRUE, api_key = Sys.getenv("OPENAI_API_KEY"))
#' # Display the generated images
#' Display(results)
#' }

generateImage4R <- function(content,
                            n = 3,
                            size = "256x256",
                            response_format = "url",
                            Output_image = TRUE,
                            SaveImg = TRUE,
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
    if(SaveImg){ saveRDS(result, file = paste0("CreatedImg_", formatC(length(dir(pattern = "[.]Rds"))+1, flag = "0", width = 3), ".Rds")) }
    return(result)

  } else {
    return(extract.url)
  }
}


#' Display Images and Optionally Write Them to Disk
#'
#' This function displays a list of EBImage objects, and optionally writes them to disk as PNG files.
#'
#' @title Display Images and Optionally Write Them to Disk
#' @description Displays a list of EBImage objects. If write is TRUE, it also writes them to the disk.
#'
#' @param img A list of EBImage objects. These are the images to display and optionally write to disk.
#' @param write A boolean. Defaults to FALSE. If TRUE, the function writes the images to disk as PNG files.
#'
#' @importFrom assertthat assert_that
#' @importFrom EBImage display rotate
#' @importFrom abind abind
#' @importFrom png writePNG
#'
#' @return This function doesn't return anything. It displays images and optionally writes them to disk.
#'
#' @export
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Load an image
#' img <- list(EBImage::readImage(system.file("images", "sample-color.png", package="EBImage")))
#'
#' # Display the image
#' Display(img)
#'
#' # Display and write the image to disk
#' Display(img, write = TRUE)
#' }

Display <- function(img, write = FALSE, Rds = FALSE){
  # Store the current graphics parameters
  oldpar <- graphics::par(no.readonly = TRUE)

  # Make sure to restore the original graphics parameters when the function exits
  on.exit(graphics::par(oldpar))

  # Ensure that the input is a list and that the first element is of class "Image"
  assertthat::assert_that(is.list(img), length(img) > 0, class(img[[1]]) == "Image")

  # Set display method to raster
  options(EBImage.display = "raster")

  #Save as Rds
  if(Rds){
    r <- paste0("Img_", formatC(length(dir(pattern = "[.]Rds"))+1, flag = "0", width = 3), ".Rds")
    saveRDS(img, file = r)
    }

  # Iterate over the images in the list and display each one
  for(n in seq_along(img)){
    #n <- 3
    EBImage::display(img[[n]])

    f <- paste0("Img_", formatC(length(dir(pattern = "[.]png"))+1, flag = "0", width = 3), ".png")
    if(write){
      if (dim(img[[n]])[3] != 4) {
          img[[n]] <- EBImage::rotate(img[[n]], angle=-90)
          alpha_channel <- matrix(0, nrow = dim(img[[n]])[1], ncol = dim(img[[n]])[2])
          img[[n]] <- abind::abind(img[[n]], alpha_channel, along = 3)
      }
      #save image
      png::writePNG(img[[n]], target = f)
    }
  }
}


