#' Convert Bullet Points to Sentences
#'
#' This function takes bullet points as input and converts them into sentences.
#' The function uses the OpenAI GPT model for text generation to assist in the conversion.
#' The function can either take the selected text from the RStudio environment or from the clipboard.
#'
#' @title convertBullet2Sentence
#' @description Convert bullet points to sentences using OpenAI GPT model.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4-0613".
#' @param temperature The temperature parameter for text generation. Default is 1.
#' @param verbose Logical flag to indicate whether to display progress. Default is TRUE.
#' @param SpeakJA Logical flag to indicate whether to use Japanese speech output. Default is FALSE.
#' @param SelectedCode Logical flag to indicate whether to use selected text in RStudio. Default is TRUE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @importFrom assertthat assert_that is.string is.number
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @return Inserts the converted sentences into the RStudio editor if `SelectedCode` is TRUE, otherwise writes to clipboard.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' convertBullet2Sentence(Model = "gpt-4-0613", SelectedCode = FALSE)
#' }

convertBullet2Sentence <- function(Model = "gpt-4-0613",
                                   temperature = 1,
                                   verbose = TRUE,
                                   SpeakJA = FALSE,
                                   SelectedCode = TRUE){

  if(verbose){
    cat("\n", "convertBullet2Sentence: ", "\n")
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
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)
  assertthat::assert_that(is.logical(SpeakJA))
  assertthat::assert_that(is.logical(verbose))
  assertthat::assert_that(is.logical(SelectedCode))

  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Preprocessing
  text0 <- paste0(input, collapse = " ")

  # Template for text generation
  template0 = "
  You are a great assistant and a highly skilled co-pilot.
  You need to convert input bullet points into sentences.
  Your output is just sentences from the summarized text.
  You must strictly reproduce and reconsider every detail without being too concise in your writing.
  If the input is not bulleted, point this out to the user and do nothing.
  The language used in the summary is the same as the input text.
  "

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Create the prompt
  template1 = "Please convert  the following input bullet points into some sentences.:"
  pr <- paste0(template1, " ", text0)

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
    if(verbose){cat(res, "\n")}
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
