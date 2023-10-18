#' Extract Keywords from Text
#'
#' This function extracts keywords from the input text. It uses the OpenAI GPT model
#' for text generation to assist in the extraction process. The function reads the input
#' from the clipboard and outputs the extracted keywords in a comma-separated format.
#'
#' @title extractKeywords
#' @description Extract keywords from input text and output them in a comma-separated format.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4-0613".
#' @param verbose Logical flag to indicate whether to print the result. Default is TRUE.
#' @param SlowTone Logical flag to indicate the speed of the output. Default is FALSE.
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string noNA
#' @return Prints the extracted keywords based on verbosity and tone speed settings.
#' @export extractKeywords
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' extractKeywords(Model = "gpt-4-0613", verbose = TRUE, SlowTone = FALSE)
#' }

extractKeywords <- function(Model = "gpt-4-0613",
                            verbose = TRUE,
                            SlowTone = FALSE) {

  # Read input from clipboard
  input = paste0(clipr::read_clip(), collapse = " \n")

  if(verbose){
  cat("\n", "extractKeywords: ", "\n")
  pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)}

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature = 1

  # Create template for the prompt
  template = "
  You are an excellent and highly skilled assistant.
  You need to extract keywords from the input text.
  The keywords should be in comma separated format.
  The language used is the same as the input text.
  "

  if(verbose){utils::setTxtProgressBar(pb, 1)}
  template <- ngsub(template)

  template1 = "
  Please extract keywords from the following input text and provide keywords in comma-separated format.:
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

  if(verbose){utils::setTxtProgressBar(pb, 3)}
  # Print the result based on verbosity and tone speed
  if(verbose) {
    cat("\n\n")
    cat("Result from extractKeywords :\n")
    if(SlowTone) {
      d <- ifelse(5/nchar(res) < 0.3, 5/nchar(res), 0.3) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(2.5/nchar(res) < 0.15, 2.5/nchar(res), 0.15) * stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }

  # Output into your clipboard
  if(verbose){
    cat("\n")
    message("Finished!!")
  }

  return(clipr::write_clip(res))

}
