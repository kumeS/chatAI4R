#' Create R Code from Selected Text or Clipboard Content
#'
#' This function reads text from your selected text or clipboard, interprets it as a prompt, and generates R code based on the given input.
#' The generated R code is then printed to the R console with optional slow printing.
#' This function can be executed from RStudio's Addins menu.
#'
#' @title Create R Code from Clipboard Content and Output into the R Console
#' @description Reads text from the clipboard and generates R code based on the given input, printing the result to the R console.
#' @section RStudio Addins: This function can be added to RStudio's Addins menu for easy access.
#' @param Summary_nch The maximum number of characters for the summary.
#' @param Model The model to be used for code generation, default is "gpt-4-0613".
#' @param SelectedCode A logical flag to indicate whether to read from RStudio's selected text. Default is TRUE.
#' @param verbose A logical value indicating whether to print the result to the console, default is TRUE.
#' @param SlowTone A logical value indicating whether to print the result slowly, default is FALSE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom clipr read_clip write_clip
#' @return Prints the generated R code to the R console.
#' @export createRcode
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' # Copy the origin of R code to your clipboard then execute from RStudio's Addins.
#'
#' }

createRcode <- function(Summary_nch = 100,
                        Model = "gpt-4-0613",
                        SelectedCode = TRUE,
                        verbose = TRUE,
                        SlowTone = FALSE){

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "createRcode: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.count(Summary_nch),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  temperature = 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template creation
  template = "
  You are an excellent assistant and a highly skilled genius co-pilot of the R language,
  Always be a very good software engineer of R programming,
  Always respond to deliverables and related explanations in a very professional and accurate manner,
  Always try to give the best answer to the questioner, and always be comprehensive and detailed in your answers.
  Always have great answers about the R language.
  Always provide only R code as a deliverable.
  The language used is always the same as the input.
  "

  template1 = "
  Please create the R script based on the following input around %s words.:
  "

  # Substituting arguments into the prompt
  template1s <- paste0(sprintf(template1, Summary_nch), paste0(input, collapse = " "), sep=" ")

  # Prompt creation
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execution
  res <- chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature)
  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n")}

  # Output
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
  } else {
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



