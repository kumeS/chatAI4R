#' Text-to-image generator using Stable Diffusion
#'
#' This function generates an image from a text prompt via Stable Diffusion.
#'
#' @title generageTxt2img_StableDiffusion4R
#' @description Generate an image from a text prompt using the Stable Diffusion API.
#'              It sends the parameters to the API and receives a response that includes
#'              the base64-encoded image data, which is then converted to a PNG image.
#' @param text_prompts A string. The text prompt to use for image generation. Should not be empty.
#' @param negative_prompts A string. The negative prompts for image generation. Default is an empty string.
#' @param weight A numeric value indicating the weight of the text prompt. Default is 0.5.
#' @param height An integer. The height of the image in pixels. Default is 512.
#' @param width An integer. The width of the image in pixels. Default is 512.
#' @param number_of_images An integer. The number of images to generate. Default is 1.
#' @param steps An integer. The number of diffusion steps to run. Default is 15.
#' @param cfg_scale A numeric value. How strictly the diffusion process adheres to the prompt text. Default is 7.
#' @param clip_guidance_preset A string. A preset to guide the image model. Default is 'NONE'.
#' @param api_host A string. The host of the Stable Diffusion API. Default is 'https://api.stability.ai'.
#' @param api_key A string. The API key for the Stable Diffusion API. It is read from the 'DreamStudio_API_KEY' environment variable by default.
#' @importFrom assertthat assert_that is.string is.count noNA
#' @importFrom httr add_headers POST http_status content
#' @importFrom jsonlite fromJSON
#' @importFrom base64enc base64decode
#' @importFrom png readPNG
#' @importFrom EBImage rotate Image display
#' @return A list of images generated from the text prompt.
#' @export generageTxt2img_StableDiffusion4R
#' @author Satoshi Kume
#' @examples
#' Sys.setenv(DreamStudio_API_KEY = "Your API key")
#' text_prompts = "japanese castle"
#' images = generageTxt2img_StableDiffusion4R(text_prompts)
#' EBImage::display(images[[1]])
generageTxt2img_StableDiffusion4R <- function(
  text_prompts = "",
  negative_prompts = "",
  weight = 0.5,
  height = 512, width = 512,
  number_of_images = 1,
  steps = 15,
  cfg_scale = 7 ,
  clip_guidance_preset = "NONE",
  api_host = "https://api.stability.ai",
  api_key = Sys.getenv("DreamStudio_API_KEY")
) {
  assertthat::assert_that(
    assertthat::is.string(text_prompts),
    assertthat::is.string(negative_prompts),
    assertthat::is.count(weight),
    assertthat::noNA(weight),
    weight >= 0,
    weight <= 1,
    assertthat::is.count(height),
    height %% 64 == 0,
    height >= 128,
    assertthat::is.count(width),
    width %% 64 == 0,
    width >= 128,
    assertthat::is.count(number_of_images),
    number_of_images >= 1,
    number_of_images <= 10,
    assertthat::is.count(steps),
    steps >= 10,
    steps <= 150,
    assertthat::is.count(cfg_scale),
    cfg_scale >= 0,
    cfg_scale <= 35,
    assertthat::is.string(clip_guidance_preset),
    clip_guidance_preset %in% c("FAST_BLUE", "FAST_GREEN", "NONE", "SIMPLE", "SLOW", "SLOWER", "SLOWEST"),
    assertthat::is.string(api_host),
    assertthat::is.string(api_key)
  )

  engine_id <- "stable-diffusion-512-v2-1"
  uri <- paste0(api_host, "/v1/generation/", engine_id, "/text-to-image")

  headers <- httr::add_headers(
    "Content-Type" = "application/json",
    "Accept" = "application/json",
    "Authorization" = paste0("Bearer ", api_key)
  )

  payload <- list(
    "text_prompts" = list(
      list("text" = text_prompts,
           "weight" = weight)
    ),
    negative_prompts = list(
      list("text" = negative_prompts)
    ),
    "cfg_scale" = cfg_scale,
    "clip_guidance_preset" = clip_guidance_preset,
    "height" = height,
    "width" = width,
    "samples" = number_of_images,
    "steps" = steps
  )

  result <- list()

  for (i in seq_len(number_of_images)) {
    cat("Generate", i, "image\n")

    response <- httr::POST(uri,
                           body = payload,
                           encode = "json",
                           config = headers)

    if (httr::http_status(response)$category != "Success") {
      stop("Non-200 response: ", httr::content(response, "text"))
    }

    image_data <- jsonlite::fromJSON(httr::content(response, "text"))

    decode_image <- png::readPNG(base64enc::base64decode(image_data$artifacts$base64))

    Img <- EBImage::rotate(EBImage::Image(decode_image, colormode = 'Color' ), angle=90)

    result[[i]] <- Img
  }

  return(result)
}
