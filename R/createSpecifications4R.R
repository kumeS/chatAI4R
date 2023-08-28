#' Create Specifications for R Function
#'
#' @title Create Specifications for R Function
#' @description This function generates specifications for an R function from your clipboard.
#'    It takes in a text input, model name, verbosity, and tone speed to generate the specifications.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4-0613".
#' @param verbose A logical value indicating whether to print the output. Default is TRUE.
#' @param SlowTone A logical value indicating whether to print the output slowly. Default is FALSE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip
#' @return The function prints the generated specifications to the console.
#' @export createSpecifications4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' createSpecifications4R(input = "Your R function specification")
#' }






createSpecifications4R <- function(Model = "gpt-4-0613",
                                   verbose = TRUE,
                                   SlowTone = FALSE) {

  input = paste0(clipr::read_clip(), collapse = " \n")

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature
  temperature = 1

  # Create template for the prompt
  template = "
  You are an excellent assistant and a highly skilled R programmer.
  You will need to prepare an R function requirements definition for project overview, main functions,
  technical specifications, inputs, outputs, usage, limitations, and additional functionality.
  You will output only the summary and line item text of the deliverable.
  The language used is the same as the input text.
  "

  template1 = "
  Using the following information, please provide an overview of the architecture of an R package and describe the functionality and use of the R function.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute the chat model
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)

  # Print the result based on verbosity and tone speed
  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print(res, delay = d)
    }
  }
}
