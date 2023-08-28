#' Summarize Text into Bullet Points
#'
#' @title Summarize Text into Bullet Points from Clipboard
#' @description This function takes a text input and summarizes it into a specified number of bullet points.
#' @param text A character vector containing the text to be summarized. Default is text from the clipboard.
#' @param BulletPoints An integer specifying the number of bullet points for the summary. Default is 4.
#' @param Model A string specifying the machine learning model to use for text summarization. Default is "gpt-4-0613".
#' @param temperature A numeric value between 0 and 1 indicating the randomness of the text generation. Default is 1.
#' @param verbose A logical value indicating whether to print the summary. Default is FALSE.
#' @param SpeakJA A logical value indicating whether to speak the summary in Japanese. Default is FALSE.
#' @importFrom assertthat assert_that is.string is.number
#' @importFrom clipr read_clip write_clip
#' @return The summarized text in bullet points is returned and also copied to the clipboard.
#' @export TextSummaryAsBullet
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' TextSummaryAsBullet(text = "This is a sample text.", BulletPoints = 3)
#' }

TextSummaryAsBullet <- function(text = clipr::read_clip(),
                                BulletPoints = 4,
                                Model = "gpt-4-0613",
                                temperature = 1,
                                verbose = FALSE,
                                SpeakJA = FALSE){

  # Validate input types and values
  assertthat::assert_that(assertthat::is.string(text[1]))
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.number(BulletPoints))
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)
  assertthat::assert_that(is.logical(SpeakJA))
  assertthat::assert_that(is.logical(verbose))

  # Preprocessing
  text0 <- paste0(text, collapse = " ")
  text0 <- gsub('\", \n\"', ' ', text0)
  text0 <- gsub('[(][0-9][0-9][:][0-9][0-9][)]', '', text0)
  text0 <- gsub('[(][0-9][:][0-9][0-9][:][0-9][0-9][)]', '', text0)

  # Template for text generation
  template0 = "You are a great assistant and a highly skilled R copilot..."

  # Create the prompt
  template1 = "Please summarize the following text in %s bullet points.:"
  template1s <- sprintf(template1, BulletPoints)
  pr <- paste0(template1s, text0, sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template0),
                  list('role' = 'user', 'content' = pr))

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  # Output the summarized text
  if(verbose){cat(res, "\n")}
  if(all(verbose, SpeakJA)){
    system(paste0("say -r 200 -v Kyoko '", res, "'"))
  }

  # Copy the summarized text to the clipboard
  return(clipr::write_clip(res))
}
