#' Check Error Details
#'
#' This function provides a way to check error details in R. It takes an error message from the R console,
#' executes the function, and shows how to fix the error in the specified language.
#'
#' @title Check Error Details
#' @description A function to analyze and provide guidance on how to fix an error message copied from the R console.
#' @param input A string containing the error message to be analyzed, read from the clipboard by default.
#' @param Summary_nch An integer specifying the maximum number of characters for the summary.
#' @param Model A string specifying the model to be used, default is "gpt-4-0314".
#' @param temperature A numeric value for controlling randomness in the output, default is 1.
#' @param language A string specifying the output language, default is "English".
#' @param verbose A logical value to control the verbosity of the output, default is TRUE.
#' @param SlowTone A logical value to control the printing speed of the output, default is FALSE.
#' @importFrom clipr read_clip
#' @return The function prints the guidance on how to fix the error message.
#' @export checkErrorDet
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Copy the error message that you want to fix.
#'   checkErrorDet()
#'   checkErrorDet(language = "Japanese")
#' }

checkErrorDet <- function(input = clipr::read_clip(),
                          Summary_nch = 100,
                          Model = "gpt-4-0314",
                          temperature = 1,
                          language = "English",
                          verbose = TRUE,
                          SlowTone = FALSE) {
  # Assertions
  assertthat::is.string(input)
  assertthat::noNA(input)
  assertthat::is.count(Summary_nch)
  assertthat::is.string(language)

  # Template creation
  template1 = "
  You are a great helper for R coding.
  Please describe how to fix the following error message in %s within %s words.
  "

  # Substituting arguments into the prompt
  template1s <- sprintf(template1, language, Summary_nch)

  # Prompt creation
  pr <- paste0(template1s, paste0(input, collapse = " "), sep=" ")

  # Execution
  res <- chat4R(content=pr,
                Model = Model,
                temperature = temperature,
                simple=TRUE)

  if(verbose) {
    if(SlowTone) {
      slow_print(res, delay = 20/nchar(res))
    } else {
      slow_print(res, delay = 10/nchar(res))
    }
  }
}
