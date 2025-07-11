#' Create Image Prompt version 1
#'
#' @title Create Image Prompt version 1
#' @description This function creates a prompt for generating an image from text using an AI model.
#'  This is an experimental function.
#' @param content A character string describing the image to be generated. If not provided, the function will throw a warning and stop.
#' @param Model A character string specifying the AI model to be used for text generation.
#' @param len Integer specifying the maximum length of the text input.
#' @importFrom assertthat assert_that is.string
#' @return A character string that serves as the prompt for generating an image.
#' @export createImagePrompt_v1
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' createImagePrompt_v1(content = "A Japanese girl animation with blonde hair.")
#' }
#'

createImagePrompt_v1 <- function(content,
                                Model = "gpt-4o-mini",
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
  res_df <- chat4R_history(history, Model = Model)

  # Extract content from data.frame
  if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) || 
      is.null(res_df$content) || length(res_df$content) == 0 || nchar(trimws(res_df$content)) == 0) {
    stop("Invalid or empty response from chat4R_history", call. = FALSE)
  }
  
  res <- as.character(res_df$content)

  # Returning the image generation prompt
  return(res)
}
