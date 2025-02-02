#' Search the R function based on the provided text
#'
#' This function searches for an R function that corresponds to the text
#' provided either through the RStudio editor selection or the clipboard.
#' It fetches the related R function and outputs its name, package, and
#' a brief description. The function uses GPT-4 for its underlying search.
#'
#' @title Search R Functions based on Text
#' @description Searches for an R function related to the provided text
#'   either through the RStudio editor selection or clipboard.
#' @param Summary_nch Numeric, number of characters to limit the function description (default = 100).
#' @param Model String, the model used for the search, default is "gpt-4o-mini".
#' @param SelectedCode Logical, whether to get text from RStudio selection (default = TRUE).
#' @param verbose Logical, whether to print the results verbosely (default = TRUE).
#' @param SlowTone Logical, whether to slow down the print speed for readability (default = FALSE).
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string is.count noNA
#' @return Console output of the identified R function, its package, and a brief description.
#' @export searchFunction
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # To search for an R function related to "linear regression"
#' searchFunction(Summary_nch = 50, SelectedCode = FALSE)
#' }
#'

searchFunction <- function(Summary_nch = 100,
                           Model = "gpt-4o-mini",
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
  cat("\n", "searchFunction: ", "\n")
  pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)}

  # Assertions to ensure proper argument types and settings
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.count(Summary_nch),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Define the temperature parameter for the model
  temperature = 1

   if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Create a template for the model prompt
  template = "
  You are an excellent assistant and a highly skilled genius co-pilot of the R language.
  You always look up the R function in relation to the input text.
  You always provide the name of the R package, the name of the R function, and a brief description of the function in a professional and concise manner.
  The output format must be the package name including the R function you mention, the function name, and the function description.
  The language used is always the same as the input text.
  "

  # Create another template for the prompt including the limit on description characters
  template1 = "
  Please search the R function in relation to the following input and explain it in %s words.:
  "

  # Merge the input with the prompt template
  template1s <- paste0(sprintf(template1, Summary_nch), paste0(input, collapse = " "), sep=" ")

  # Create a history object for API call
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute the function that interacts with the API
  res <- as.character(chat4R_history(history=history,
                        Model = Model,
                        temperature = temperature))

  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n\n")}

  # Print output conditionally based on 'verbose' and 'SlowTone'
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
