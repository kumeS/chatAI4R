#' Check Error Details in Japanese
#'
#' This function provides a way to check error details in R. It takes an error message from the R console,
#' executes the function, and shows how to fix the error in Japanese.
#'
#' @title Check Error Details in Japanese
#' @description A function to analyze and provide guidance on how to fix an error message copied from the R console.
#' @param input A string containing the error message to be analyzed, read from the clipboard by default.
#' @param Summary_nch An integer specifying the maximum number of characters for the summary.
#' @param Model A string specifying the model to be used, default is "gpt-4-0314".
#' @param verbose A logical value to control the verbosity of the output, default is TRUE.
#' @param SlowTone A logical value to control the printing speed of the output, default is FALSE.
#' @importFrom clipr read_clip
#' @return The function prints the guidance on how to fix the error message.
#' @export checkErrorDet_JP
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Copy the error message that you want to fix.
#'   checkErrorDet_JP()
#'   checkErrorDet_JP(language = "Japanese")
#' }

checkErrorDet_JP <- function(input = clipr::read_clip(),
                          Summary_nch = 100,
                          Model = "gpt-4-0314",
                          verbose = TRUE,
                          SlowTone = FALSE) {
  # Assertions
  assertthat::is.string(input)
  assertthat::noNA(input)
  assertthat::is.count(Summary_nch)
  assertthat::is.string(language)
  temperature = 1

  # Template creation
  template = "
  For questions related to the R language, you should always be a great assistant
  supporter, always be a very good software engineer of R programming, always respond
  to deliverables and related explanations in a very professional and accurate manner,
  always try to give the best answer to the questioner, and always be comprehensive and
  detailed in your responses. You should use Japanese for the explanation.
  "

  template1 = "
  Please describe in %s words or less how to fix the following error message in %s.
  You should use Japanese for the explanation.
  "

  # Substituting arguments into the prompt
  template1s <- paste0(sprintf(template1, Summary_nch, "Japanese"), paste0(input, collapse = " "), sep=" ")

  # Prompt creation
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execution
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)

  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3)
      slow_print(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15)
      slow_print(res, delay = d)
    }
  }
}


