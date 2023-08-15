#' Proofread English Text During R Package Development via RStudio API
#'
#' This function provides a feature to proofread English text during the development of an R package.
#' It can either take the selected text from the RStudio editor or read from the clipboard, executes the proofreading, and returns the result to the user's clipboard or replaces the selected text.
#' The user can then paste and check the result if read from the clipboard. The function adheres to R package policies and carefully proofreads the English text.
#' Execution with GPT-4 is recommended.
#'
#' @title Proofread English Text
#' @description A function to proofread English text or text in different languages during R package development.
#' It translates the input into English if necessary and returns meticulously checked English text.
#' @param Model A string specifying the model to be used for proofreading, defaulting to "gpt-4-0314".
#'    Currently, "gpt-4", "gpt-4-0314" and "gpt-4-0613" can be selected as gpt-4 models.
#'    Execution with GPT-4 is recommended.
#' @param SelectedCode A logical value indicating whether to read the selected text from the RStudio editor (TRUE) or from the clipboard (FALSE). Defaults to TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @return The proofread text, which is also written to the clipboard if SelectedCode is FALSE, or replaces the selected text if SelectedCode is TRUE.
#' @export proofreadEnglishText
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Proofreading selected text in RStudio
#'   proofreadEnglishText(Model = "gpt-4-0613", SelectedCode = TRUE)
#'   # Proofreading text from the clipboard
#'   proofreadEnglishText(Model = "gpt-4-0613", SelectedCode = FALSE)
#' }

proofreadEnglishText <- function(Model = "gpt-4-0613",
                                 SelectedCode = TRUE) {

  if(SelectedCode){
  assertthat::assert_that(rstudioapi::isAvailable())
  input = getActiveDocumentContext()$selection[[1]]$text
  }else{
  input = paste0(clipr::read_clip(), collapse = " \n")
  }

  # Assertions
  assertthat::assert_that(
  assertthat::is.string(input),
  assertthat::noNA(input),
  assertthat::is.string(Model),
  Sys.getenv("OPENAI_API_KEY") != ""
  )
  temperature = 1


  # Template creation
  template = "
  You are an excellent R package builder's assistant and a skilled multilingual translator.
  You can accept English text or text in different languages as input.
  If necessary, translate the input into English, and use a backslash n to start a new line.
  According to the R package policy, you should only output meticulously checked English text without any additional explanation.
  "

  template1 = "
  Please proofread the following input text in English without altering the meaning of the text, and only output the final product.:
  "

  # Bind into the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Prompt creation
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execution
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)
  #str(res)

  if(SelectedCode){
  rstudioapi::insertText(text = as.character(res))
  return(message("Finished!!"))
  }else{
  # Put into the clipboard
  return(clipr::write_clip(res))
  }

}
