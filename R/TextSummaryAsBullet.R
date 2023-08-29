#' Summarize Selected Text into Bullet Points
#'
#' @title Summarize Text into Bullet Points
#' @description This function takes a text input and summarizes it into a specified number of bullet points.
#'    It can either take the selected code from RStudio or read from the clipboard.
#' @param BulletPoints An integer specifying the number of bullet points for the summary. Default is 4.
#' @param Model A string specifying the machine learning model to use for text summarization. Default is "gpt-4-0613".
#' @param temperature A numeric value between 0 and 1 indicating the randomness of the text generation. Default is 1.
#' @param verbose A logical value indicating whether to print the summary. Default is FALSE.
#' @param SpeakJA A logical value indicating whether to speak the summary in Japanese. Default is FALSE.
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
#' @importFrom assertthat assert_that is.string is.number
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @return The summarized text in bullet points is returned.
#' @export TextSummaryAsBullet
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' TextSummaryAsBullet(text = "This is a sample text.", BulletPoints = 3)
#' }

TextSummaryAsBullet <- function(BulletPoints = 4,
                                Model = "gpt-4-0613",
                                temperature = 1,
                                verbose = TRUE,
                                SpeakJA = FALSE,
                                SelectedCode = TRUE){

  if(verbose){
  cat("\n", "TextSummaryAsBullet: ", "\n")
  pb <- utils::txtProgressBar(min = 0, max = 4, style = 3)}

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  # Validate input types and values
  assertthat::assert_that(assertthat::is.string(input))
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.number(BulletPoints))
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)
  assertthat::assert_that(is.logical(SpeakJA))
  assertthat::assert_that(is.logical(verbose))
  assertthat::assert_that(is.logical(SelectedCode))

  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Preprocessing
  text0 <- paste0(input, collapse = " ")
  text0 <- gsub('\", \n\"', ' ', text0)
  text0 <- gsub('[(][0-9][0-9][:][0-9][0-9][)]', '', text0)
  text0 <- gsub('[(][0-9][:][0-9][0-9][:][0-9][0-9][)]', '', text0)

  # Template for text generation
  template0 = "
  You are a great assistant and a highly skilled copilot.
  You have to summarize some input text into bullet points.
  Your output is just the summarized and bulleted form text.
  You must strictly reproduce and reconsider every detail without being overly concise in your writing.
  The language used in the summary is the same as the input text.
  "

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Create the prompt
  template1 = "Please summarize the following text in %s bullet points.:"
  template1s <- sprintf(template1, BulletPoints)
  pr <- paste0(template1s, " ", text0)

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template0),
                  list('role' = 'user', 'content' = pr))

  if(verbose){utils::setTxtProgressBar(pb, 3)}

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  # Output the summarized text
  if(all(verbose, SpeakJA)){
    cat(res, "\n")
    system(paste0("say -r 200 -v Kyoko '", res, "'"))
  }

  if(verbose){utils::setTxtProgressBar(pb, 4)}

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
  } else {
    return(clipr::write_clip(res))
  }
}
