#' Proofread Text During R Package Development Through the RStudio API
#'
#' This function offers a feature for proofreading text while developing an R package.
#' It can either use the text selected in the RStudio editor or read from the clipboard, perform the proofreading, and then either replace the selected text or return the result to the user's clipboard.
#' The language of the output will match the language of the input text. Using GPT-4 for execution is recommended.
#'
#' @title proofreadText
#' @description Proofreads text during the development of an R package.
#' @param Model The Large Language Model to be used for proofreading. Default is "gpt-4-0613".
#' @param SelectedCode Logical flag to indicate whether to use the selected text in RStudio editor. Default is TRUE.
#' @param verbose Logical flag to print the progress. Default is TRUE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom clipr read_clip write_clip
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom assertthat assert_that is.string noNA
#' @return NULL if `SelectedCode` is TRUE, otherwise returns the proofread text to the clipboard.
#' @export proofreadText
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Proofread text from clipboard
#' proofreadText(SelectedCode = FALSE)
#' }

proofreadText <- function(Model = "gpt-4-0613",
                          SelectedCode = TRUE,
                          verbose = TRUE) {

  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input = rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input = paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "proofreadText: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  temperature = 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template creation for the prompt
  template = "
  You are an excellent assistant to the R package builder and a highly skilled co-pilot.
  According to the R package policy, you should output only carefully reviewed and grammatically checked text without additional explanation and without changing the meaning of the text.
  The language used is always the same as the language of the input text.
  The amount of text in the output should be as close as possible to the amount of text in the input.
  "

  template1 = "
  Please proofread the following input text in the same language as the input text, without changing the meaning of the text, and output only the final product.:
  "

  # Combine template and input
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute the chat model
  res <- as.character(chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature))

  if(verbose){utils::setTxtProgressBar(pb, 3)}

  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
  } else {
    # Put into the clipboard
    return(clipr::write_clip(res))
  }
}
