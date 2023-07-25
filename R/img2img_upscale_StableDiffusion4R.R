#' @title Stable Diffusion Image to Image Up-scaling Transformation
#'
#' @description This function create a higher resolution version of an input image via the Stable Diffusion API.
#'
#' @param init_image_path A string. This is the path to the image file to be used as the basis for the image to image transformation. Should be a valid PNG file.
#' @param engine_id A string. The engine id to be used in the API. Default is 'esrgan-v1-x2plus'.
#'                  Other possible value is 'stable-diffusion-x4-latent-upscaler'.
#' @param api_host A string. The host of the Stable Diffusion API. Default is 'https://api.stability.ai'.
#' @param api_key A string. The API key for the Stable Diffusion API. It is read from the 'DreamStudio_API_KEY' environment variable by default.

#' @importFrom assertthat assert_that is.string is.count noNA
#' @importFrom httr add_headers POST http_status content
#' @importFrom jsonlite fromJSON
#' @importFrom base64enc base64decode
#' @importFrom png readPNG
#' @importFrom EBImage rotate Image
#' @return A list of image up-scaled from the initial image.
#' @export img2img_upscale_StableDiffusion4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' init_image_path <- system.file("images", "JP_castle.png", package = "chatAI4R")
#' result <- img2img_upscale_StableDiffusion4R(init_image_path)
#' Display(result, write_file = TRUE)
#' }

img2img_upscale_StableDiffusion4R <- function(
  init_image_path,
  width = 1024,
  engine_id = "esrgan-v1-x2plus",
  api_host = "https://api.stability.ai",
  api_key = Sys.getenv("DreamStudio_API_KEY")
) {

  # Verify if text_prompts is not empty or NULL
  if (is.null(init_image_path) || init_image_path == "") {
    stop("init_image_path must not be empty or NULL")
  }

  assertthat::assert_that(
    assertthat::is.string(init_image_path),
    assertthat::is.number(width_height),
    width_height >= 512,
    assertthat::is.string(engine_id),
    engine_id %in% c("esrgan-v1-x2plus", "stable-diffusion-x4-latent-upscaler"),
    assertthat::is.string(api_host),
    assertthat::is.string(api_key)
  )

  # Defining the URL
  uri <- paste0(api_host, "/v1/generation/", engine_id, "/image-to-image/upscale")

  headers <- httr::add_headers(
    "Content-Type" = "multipart/form-data",
    "Accept" = "application/json",
    "Authorization" = paste0("Bearer ", api_key)
  )

  payload <- list(
    "image" = httr::upload_file(init_image_path),
    "width" = width)

  # Creating empty variable
  result <- list()
  cat("Generating an up-scaled image\n")

  response <- httr::POST(uri,
                         body = payload,
                         encode = "multipart",
                         config = headers)

  if (httr::http_status(response)$category != "Success") {
      stop("Non-200 response: ", httr::content(response, "text", encoding = "UTF-8"))
  }

    image_data <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))

    decode_image <- png::readPNG(base64enc::base64decode(image_data$artifacts$base64))

    Img <- EBImage::rotate(EBImage::Image(decode_image, colormode = 'Color' ), angle=90)

    result[[1]] <- Img

  return(result)
}
