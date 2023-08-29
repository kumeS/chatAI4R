#' Suggest Improvements for R Code
#'
#' @title Suggest Improvements to the R Code on Your Clipboard
#' @description This function uses LLM to analyze the R code from the clipboard and suggests improvements.
#'    The function can also control the verbosity and speed of the output.
#' @param Summary_nch An integer specifying the maximum number of characters for the summary. Default is 100.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4-0613".
#' @param verbose A logical value indicating whether to print the result. Default is TRUE.
#' @param SlowTone A logical value indicating whether to print the result slowly. Default is FALSE.
#' @importFrom assertthat assert_that is.string noNA is.count
#' @importFrom clipr read_clip
#' @return No return value; the function prints the suggestions for code improvement.
#' @export RcodeImprovements
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' #Copy your function to your clipboard
#' RcodeImprovements(Summary_nch = 100, Model = "gpt-4-0613")
#' }

RcodeImprovements <- function(Summary_nch = 100,
                              Model = "gpt-4-0613",
                              verbose = TRUE,
                              SlowTone = FALSE){

  # Read the clipboard content into a string
  input <- paste0(clipr::read_clip(), collapse = " \n")

  # Validate the input and other parameters
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.count(Summary_nch),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Set the temperature for the GPT model
  temperature <- 1

  # Define the system and user prompts for the GPT model
  template <- "
  For the R language, you should always be a great, highly skilled assistant co-pilot,
  Always be a very good software engineer of R programming,
  Always respond to deliverables and related explanations in a very professional and accurate manner,
  Always be comprehensive and detailed in your responses.
  You should briefly describe the improvement of the provided R code and why you made the change.
  You do not use code blocks and you do not provide tests or examples.
  Please always start by rating how many points on a 100-point scale the R-code.
  For example, 100 points for no changes, 80 points for excellent, 50 points for normal, and 30 points for poor.
  The language used is always the same as the input text.
  "

  template1 <- sprintf("
  Please always start by rating how many points on a 100-point scale the R code deserves.
  Please suggest for R function and code improvements on the following input within %s words.:
  ", Summary_nch)

  # Create the full prompt for the GPT model
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Create the chat history for the GPT model
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Generate the suggestions using the GPT model
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)

  # Print the suggestions based on the verbosity and speed settings
  if(verbose){
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }
}
