#' Check Error Details
#'
#' This function provides a way to check error details in R. It takes an error message from the R console,
#' executes the function, and shows how to fix the error in the specified language.
#'
#' @title Check Error Details
#' @description A function to analyze and provide guidance on how to fix an error message copied from the R console.
#' @param Summary_nch An integer specifying the maximum number of characters for the summary.
#' @param Model A string specifying the model to be used, default is "gpt-4-0314".
#'    Currently, "gpt-4", "gpt-4-0314" and "gpt-4-0613" can be selected as gpt-4 models.
#'    Execution with GPT-4 is recommended.
#' @param language A string specifying the output language, default is "English".
#' @param verbose A logical value to control the verbosity of the output, default is TRUE.
#' @param SlowTone A logical value to control the printing speed of the output, default is FALSE.
#' @importFrom clipr read_clip
#' @importFrom stats runif
#' @return The function prints the guidance on how to fix the error message.
#' @export checkErrorDet
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Copy the error message that you want to fix.
#'   checkErrorDet()
#'   checkErrorDet(language = "Japanese")
#' }

checkErrorDet <- function(Summary_nch = 100,
                          Model = "gpt-4-0613",
                          language = "English",
                          verbose = TRUE,
                          SlowTone = FALSE) {

  input = paste0(clipr::read_clip(), collapse = " ")

  # Assertions
  assertthat::assert_that(
  assertthat::is.string(input),
  assertthat::noNA(input),
  assertthat::is.count(Summary_nch),
  assertthat::is.string(language),
  Sys.getenv("OPENAI_API_KEY") != ""
  )

  temperature = 1

  # Template creation
  template = "
  For questions related to the R language, you should always be a great assistant
  supporter, always be a very good software engineer of R programming, always respond
  to deliverables and related explanations in a very professional and accurate manner,
  always try to give the best answer to the questioner, and always be comprehensive and
  detailed in your responses.
  "

  template1 = "
  Please describe how to fix the following error message in %s within %s words.
  "

  # Substituting arguments into the prompt
  template1s <- paste0(sprintf(template1, language, Summary_nch), input, sep=" ")

  # Prompt creation
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execution
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)

  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print(res, delay = d)
    }
  }
}



