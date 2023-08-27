#' Add Roxygen Description to R Function
#'
#' @title Add Roxygen Description to R Function
#' @description This function adds a Roxygen description to an R function using the GPT-4 model.
#'    It can either take the selected code from RStudio or read from the clipboard.
#' @param Model A character string specifying the GPT model to be used. Default is "gpt-4-0613".
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
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
                                 SelectedCode = TRUE) {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
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

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled R copilot.
  You should understand the input R code carefully, line by line.
  You create a Roxygen skeleton in English from the R function input.
  You should output only the roxygen format strictly according to roxygen policy in English, without using code blocks.
  "

  # Create the prompt
  path <- system.file("chatGPT_prompts/", package = "chatAI4R")
  template1 <- paste0(readLines(paste0(path, "create_roxygen2_v02.txt")), ":\n", collapse = "\n")
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  # Combine Roxygen comments with original code
  result <- paste0(res, "\n", input)

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(result))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(result))
  }
}
