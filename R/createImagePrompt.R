#' Create Image Prompt
#'
#' @title Create Image Prompt
#' @description This function creates a prompt for generating an image from text using an AI model.
#'  This is an experimental function.
#' @param content A character string describing the image to be generated. If not provided, the function will throw a warning and stop.
#' @param Model A character string specifying the AI model to be used for text generation.
#' @param Text2Img A character string specifying the model to be used for text to image transformation.
#' @param len Integer specifying the maximum length of the text input.
#' @importFrom assertthat assert_that is.string
#' @return A character string that serves as the prompt for generating an image.
#' @export createImagePrompt
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' createImagePrompt(content = "A Japanese girl animation with blonde hair.")
#' }
#'

createImagePrompt <- function(content = "",
                                Model = "gpt-3.5-turbo-16k",
                                len = 200){
  # Asserting input types and values
  assertthat::assert_that(assertthat::is.string(content))
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.count(len), len > 0)

  if(content == "") {
    warning("No input provided.")
    stop()
  }

  # Creating the prompt
  len_w <- paste0("Texts should be less than ", len, " words and the prompt should be in English. Please use the following information to create an image generation prompt for the scene/story.", content)
  history <- list(list('role' = 'system', 'content' = paste0('You are a helpful assistant and prompt master for creating text to images.')),
                 list('role' = 'user', 'content' = len_w))

  # Executing chat4R_history
  res <- chat4R_history(history, Model = Model)

  # Returning the image generation prompt
  return(res)
}
