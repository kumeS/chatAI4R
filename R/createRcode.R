#' Create R Code from Clipboard Content and Output into the R Console
#'
#' This function reads text from the clipboard, interprets it as a prompt, and generates R code based on the given input.
#' The generated R code is then printed to the R console with optional slow printing.
#' This function can be executed from RStudio's Addins menu.
#'
#' @title Create R Code from Clipboard Content and Output into the R Console
#' @description Reads text from the clipboard and generates R code based on the given input, printing the result to the R console.
#' @section RStudio Addins: This function can be added to RStudio's Addins menu for easy access.
#' @param input The text to be interpreted, default is the content of the clipboard.
#' @param Summary_nch The maximum number of characters for the summary.
#' @param Model The model to be used for code generation, default is "gpt-4-0613".
#' @param language The language in which the code should be created, default is "English".
#' @param verbose A logical value indicating whether to print the result to the console, default is TRUE.
#' @param SlowTone A logical value indicating whether to print the result slowly, default is FALSE.
#' @return Prints the generated R code to the R console.
#' @export createRcode
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' # Copy the origin of R code to your clipboard then execute from RStudio's Addins.
#'
#' }


createRcode <- function(input = clipr::read_clip(),
                        Summary_nch = 100,
                        Model = "gpt-4-0613",
                        language = "English",
                        verbose = TRUE,
                        SlowTone = FALSE){

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
  For R language, you should always be a great assistant supporter,
  always be a very good software engineer of R programming, always respond
  to deliverables and related explanations in a very professional and accurate manner,
  always try to give the best answer to the questioner, and always be comprehensive and
  detailed in your responses.
  "

  template1 = "
  Please create the R script based on the following input in %s within %s words.:
  "

  # Substituting arguments into the prompt
  template1s <- paste0(sprintf(template1, language, Summary_nch), paste0(input, collapse = " "), sep=" ")

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



