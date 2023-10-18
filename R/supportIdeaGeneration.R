#' Support Idea Generation from Selected Text or Clipboard Input
#'
#' This feature helps you generate ideas or concepts based on input from your selected text or clipboard.
#' It uses the OpenAI GPT model for text generation to assist in the idea generation process.
#' The function reads the input from the clipboard.
#'
#' @title supportIdeaGeneration: Support Idea Generation from Selected Text or Clipboard.
#' @description Assist in generating ideas or concepts.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4-0613".
#' @param SelectedCode Logical flag to indicate whether to use the selected text in RStudio editor. Default is TRUE.
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @param SlowTone Logical flag to indicate whether to print the text slowly. Default is FALSE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom stats runif
#' @return Prints the generated ideas or concepts based on the verbosity and tone speed settings.
#' @export supportIdeaGeneration
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' supportIdeaGeneration()
#' }

supportIdeaGeneration <- function(Model = "gpt-4-0613",
                                  SelectedCode = TRUE,
                                  verbose = TRUE,
                                  SlowTone = FALSE) {

  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input = rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input = paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "supportIdeaGeneration: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature
  temperature = 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Create template for the prompt
  template = "
  You are an exceptional assistant and an exceptionally skilled R programmer.
  You do not have to respond at the R code level.
  You need to take a given idea as input and articulate the idea or concept in written form.
  An idea is often the starting point for a new product, service, or solution.
  A concept is the development of those ideas into a concrete plan or design.
  You are the navigator, providing the direction to follow and how to translate it into a program.
  You provide only the summary and bulleted details of the deliverables.
  The language used in the output deliverables must be the same as the language of the following input.
  "

  template1 = "
  Please provide ideas and concepts concisely and comprehensively for further discussion using the following input.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute the chat model
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)

  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n\n")
    }

  # Output
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
  } else {
  # Print the result based on verbosity and tone speed
  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }

  return(clipr::write_clip(res))

  }

}
