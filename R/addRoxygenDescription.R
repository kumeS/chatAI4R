#' Add Roxygen Description to R Function
#'
#' @title Add Roxygen Description to R Function
#' @description This function adds a Roxygen description to an R function using the GPT-4 model.
#'    It can either take the selected code from RStudio or read from the clipboard.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4-0613".
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @return A message indicating completion if `SelectedCode` is TRUE, otherwise the Roxygen-annotated code is copied to the clipboard.
#' @export addRoxygenDescription
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' addRoxygenDescription(Model = "gpt-4-0613", SelectedCode = TRUE)
#' }

addRoxygenDescription <- function(Model = "gpt-4-0613",
                                 SelectedCode = TRUE,
                                 verbose = TRUE) {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "addRoxygenDescription: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature <- 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled genius copilot of the R language.
  You always have great answers about the R language.
  You should understand the input R code carefully, line by line.
  You create a Roxygen skeleton in English from the R function input.
  You should output only the roxygen format strictly according to roxygen policy in English, without using code blocks.
  "

  # Create the prompt
  template1 <- "
  You need to output in roxygen2 format, using #' not only ' style in English.
  Your definition should be in the roxygen2 format and include specific elements such as @title, @description, @param, @importFrom, @return, @export, @author [Blank], and @examples.
  It is important to make sure that the function name you define is also defined in @export.
  In addition, you should translate any comments in the function to English and make sure that the content of the comments is consistent and correct throughout the function.
  If you find any errors or areas for improvement in the R script, you should correct them according to these instructions.
  If there is a risk of errors occurring during text generation, you should make the necessary changes to prevent these errors.
  Once you have completed the definition, please submit it as a final product.
  You should use the assertthat::is.string, assertthat::is.count, assertthat::noNA, and other function groups in the assertthat package, and append the data verification execution command to the function according to the type of argument.
  You should omit the R code output.:
  "

  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n")}

  # Combine Roxygen comments with original code
  result <- paste0(res, "\n", input)

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(result))
  } else {
    return(clipr::write_clip(result))
  }
}
