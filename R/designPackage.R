#' Design Package for R
#'
#' This function assists in proposing the overall design and architecture of an R package.
#' It uses the OpenAI GPT model for text generation to assist in the design process.
#' The function reads the input from the clipboard.
#'
#' @title designPackage
#' @description Assist in proposing the overall design and architecture of an R package.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4-0613".
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @param SlowTone Logical flag to indicate whether to print the text slowly. Default is FALSE.
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom stats runif
#' @return Prints the proposed design and architecture based on the verbosity and tone speed settings.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Copy the text into your clipboard then execute
#' designPackage(Model = "gpt-4-0613", verbose = TRUE, SlowTone = FALSE)
#' }

designPackage <- function(Model = "gpt-4-0613",
                          verbose = TRUE,
                          SlowTone = FALSE) {

  # Read input from clipboard
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
  You are an excellent assistant and a highly skilled genius R programmer.
  You always give great answers about the R language.
  You must strictly propose the overall design and architecture of the package based on the inputs.
  You will output only the summary and line item text of the deliverable.
  The language used will always be the same as the language of the input text.
  "

  template1 = "
  Please propose the overall design and architecture of the R package with the following input text.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute the chat model
  res <- as.character(chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature))

  # Print the result based on verbosity and tone speed
  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }
}
