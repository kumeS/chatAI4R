#' Create Specifications for R Function
#'
#' @title Create Specifications for R Function
#' @description This function generates specifications for an R function from your selected text or clipboard.
#'    It takes in a text input, model name, verbosity, and tone speed to generate the specifications.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4o-mini".
#' @param SelectedCode A logical flag to indicate whether to read from RStudio's selected text. Default is TRUE.
#' @param verbose A logical value indicating whether to print the output. Default is TRUE.
#' @param SlowTone A logical value indicating whether to print the output slowly. Default is FALSE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @return The function prints the generated specifications to the console.
#' @export createSpecifications4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' createSpecifications4R(input = "Your R function specification")
#' }

createSpecifications4R <- function(Model = "gpt-4o-mini",
                                   SelectedCode = TRUE,
                                   verbose = TRUE,
                                   SlowTone = FALSE) {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "createSpecifications4R: ", "\n")
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
  You are an excellent assistant and a highly skilled genius R programmer to build specifications of R function.
  You should always carefully understand the intent of the ideas and concepts you are given,
  and be prepared to be specific in your specifications in an appropriate and comprehensive manner.
  You need to prepare an R function requirements specification for project and technical overview, main functions,
  input parameters, output parameters, use cases or applications, and constraints.
  Finally, you need to make proposals for items missing from the above requirements definition.
  You are sure to output only the deliverables in the requirements definition.
  The language used in the output deliverables must be the same as the language of the following input.
  "

  template1 = "
  Please provide an overview of the requirements definition for an R function based on the following input.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute the chat model
  res_df <- chat4R_history(history=history,
                          Model = Model,
                          temperature = temperature)

  # Extract content from data.frame
  if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) || 
      is.null(res_df$content) || length(res_df$content) == 0 || nchar(trimws(res_df$content)) == 0) {
    stop("Invalid or empty response from chat4R_history", call. = FALSE)
  }
  
  res <- as.character(res_df$content)

  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n")}

  # Output
  if(SelectedCode){
    rstudioapi::insertText(text = res)
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
