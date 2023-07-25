#' @title Stable Diffusion Image to Image Transformation
#'
#' @description This function uses the Stable Diffusion process to transform
#' an initial image according to given prompts.
#'
#' @param text_prompts A string. The text prompt to guide image transformation. Should not be empty.
#' @param init_image_path A string. This is the path to the image file to be used as the basis for the image to image transformation. Should be a valid PNG file.
#' @param init_image_mode A string. Determines whether to use 'image_strength' or 'step_schedule_*' to control the influence of the initial image. Default is 'IMAGE_STRENGTH'.
#' @param image_strength A numeric value. Specifies the influence of the initial image on the diffusion process. Default is 0.35.
#' @param weight A numeric value. Indicates the weight of the text prompt. Default is 0.5.
#' @param number_of_images An integer. The number of images to generate. Default is 1.
#' @param steps An integer. The number of diffusion steps to run. Default is 15.
#' @param cfg_scale A numeric value. How strictly the diffusion process adheres to the prompt text. Default is 7.
#' @param seed An integer. The seed for random noise generation. Default is 0.
#' @param clip_guidance_preset A string. A preset to guide the image model. Default is 'NONE'.
#' @param style_preset A string. Specifies the style preset to guide the image model towards a particular style. Default is 'photographic'.
#' @param engine_id A string. The engine id to be used in the API. Default is 'stable-diffusion-v1-5'.
#'                  Other possible values are 'stable-diffusion-512-v2-1', 'stable-diffusion-xl-beta-v2-2-2', 'stable-diffusion-768-v2-1'.
#' @param api_host A string. The host of the Stable Diffusion API. Default is 'https://api.stability.ai'.
#' @param api_key A string. The API key for the Stable Diffusion API. It is read from the 'DreamStudio_API_KEY' environment variable by default.
#' @importFrom assertthat assert_that is.string is.count noNA
#' @importFrom httr add_headers POST http_status content
#' @importFrom jsonlite fromJSON
#' @importFrom base64enc base64decode
#' @importFrom png readPNG
#' @importFrom EBImage rotate Image
#' @return A list of images generated from the initial image and the text prompt.
#' @export img2img_StableDiffusion4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' text_prompts <- "Add a cat"
#' init_image_path <- system.file("img", "JP_castle.png", package = "chatAI4R")
#' images = img2img_StableDiffusion4R(text_prompts, init_image_path)
#' Display(images)
#' }

#sampler
#string (Sampler)
#Enum: DDIM DDPM K_DPMPP_2M K_DPMPP_2S_ANCESTRAL K_DPM_2 K_DPM_2_ANCESTRAL K_EULER K_EULER_ANCESTRAL K_HEUN K_LMS
#Which sampler to use for the diffusion process. If this value is omitted we'll automatically select an appropriate sampler for you.


img2img_StableDiffusion4R <- function(
  text_prompts,
  init_image_path,
  init_image_mode = "IMAGE_STRENGTH",
  image_strength = 0.35,
  weight = 0.5,
  number_of_images = 1,
  steps = 15,
  cfg_scale = 7,
  seed = 0,
  clip_guidance_preset = "NONE",
  sampler = NULL,
  style_preset = "photographic",
  engine_id = "stable-diffusion-v1-5",
  api_host = "https://api.stability.ai",
  api_key = Sys.getenv("DreamStudio_API_KEY")
) {

  # Verify if text_prompts is not empty or NULL
  if (is.null(text_prompts) || text_prompts == "") {
    stop("text_prompts must not be empty or NULL")
  }

  assertthat::assert_that(
    assertthat::is.string(text_prompts),
    assertthat::is.number(weight),
    assertthat::noNA(weight),
    weight >= 0,
    weight <= 1,
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
    assertthat::is.string(engine_id),
    engine_id %in% c("stable-diffusion-512-v2-1", "stable-diffusion-v1-5", "stable-diffusion-xl-beta-v2-2-2", "stable-diffusion-768-v2-1"),
    assertthat::is.string(api_host),
    assertthat::is.string(api_key)
  )

  # Defining the URL
  uri <- paste0(api_host, "/v1/generation/", engine_id, "/image-to-image")

  headers <- httr::add_headers(
    "Content-Type" = "multipart/form-data",
    "Accept" = "application/json",
    "Authorization" = paste0("Bearer ", api_key)
  )
if(is.null(sampler)){
  payload <- list(
    "text_prompts[0][text]" = text_prompts,
    "text_prompts[0][weight]" = weight,
    "init_image" = httr::upload_file(init_image_path),
    "init_image_mode" = init_image_mode,
    "image_strength" = image_strength,
    "cfg_scale" = cfg_scale,
    "clip_guidance_preset" = clip_guidance_preset,
    "samples" = number_of_images,
    "steps" = steps,
    "seed" = seed,
    "style_preset" = style_preset
  )
}else{
  payload <- list(
    "text_prompts[0][text]" = text_prompts,
    "text_prompts[0][weight]" = weight,
    "init_image" = httr::upload_file(init_image_path),
    "init_image_mode" = init_image_mode,
    "image_strength" = image_strength,
    "cfg_scale" = cfg_scale,
    "clip_guidance_preset" = clip_guidance_preset,
    "samples" = number_of_images,
    "steps" = steps,
    "seed" = seed,
    "sampler" = sampler,
    "style_preset" = style_preset
  )
}


  # Creating empty variable
  result <- list()

  for (i in seq_len(number_of_images)) {
    cat("Generating", i, "image\n")

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

    result[[i]] <- Img
  }

  return(result)
}
