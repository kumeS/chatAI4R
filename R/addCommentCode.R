#' Add Comments to R Code
#'
#' @title Add Comments to R Code
#' @description This function adds comments to R code without modifying the input R code.
#'    It can either take the selected code from RStudio or read from the clipboard.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4-0613".
#' @param language A character string specifying the language for the comments. Default is "English".
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @return A message indicating completion if `SelectedCode` is TRUE, otherwise the commented code is copied to the clipboard.
#' @export addCommentCode
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' addCommentCode(Model = "gpt-4-0613", language = "English", SelectedCode = TRUE)
#' }

addCommentCode <- function(Model = "gpt-4-0613",
                           language = "English",
                           SelectedCode = TRUE) {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature <- 1

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled genius R programmer.
  You always give great answers about the R language.
  You should add inline comments to explain this code. Your output goes directly into a source (.R) file.
  You should comment the code line by line without modifying the input R code.
  You should provide a one-sentence summary comment for each run, without redundant explanations.
  You should output only the text of the deliverable in %s.
  "

  template <- sprintf(template, language)

  template1 <- "
  Please add inline comments to explain the following input code without changing the input R code.:
  "

  # Create the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(res))
  }
}
