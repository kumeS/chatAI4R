#' Support Idea Generation from Clipboard.
#'
#' This feature helps you generate ideas or concepts based on input from your clipboard.
#' It uses the OpenAI GPT model for text generation to assist in the idea generation process.
#' The function reads the input from the clipboard.
#'
#' @title supportIdeaGeneration: Support Idea Generation from Clipboard.
#' @description Assist in generating ideas or concepts.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4-0613".
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @param SlowTone Logical flag to indicate whether to print the text slowly. Default is FALSE.
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom stats runif
#' @return Prints the generated ideas or concepts based on the verbosity and tone speed settings.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' supportIdeaGeneration()
#' }

supportIdeaGeneration <- function(Model = "gpt-4-0613",
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
  You need to use the idea as input to formulate an idea or concept in writing.
  An idea is an abstract concept, an ambiguity, or a possibility,
  It is sometimes the starting point for a new product, service, or solution.
  A concept is a further development of the above ideas into a concrete plan or design.
  You are the one who points out the direction to take and how to turn it into a program.
  You will output only the summary and line item text of the deliverable.
  The language used is the same as the input text.
  "

  template1 = "
  With the following input, please be open to ideas and concepts for further discussion.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input), sep=" ")

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
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }
}
