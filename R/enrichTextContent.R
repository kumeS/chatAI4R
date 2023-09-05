#' Enrich Text Content
#'
#' @title Enrich Text Content
#' @description This function doubles the amount of text without changing its meaning.
#'    The GPT-4 model is currently recommended for text generation. It can either read from the RStudio selection or the clipboard.
#' @param Model A character string specifying the AI model to be used for text enrichment. Default is "gpt-4-0613".
#' @param SelectedCode A logical flag to indicate whether to read from RStudio's selected text. Default is TRUE.
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @return If SelectedCode is TRUE, the enriched text is inserted into the RStudio editor and a message "Finished!!" is returned.
#'         Otherwise, the enriched text is placed into the clipboard.
#' @export enrichTextContent
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   enrichTextContent(Model = "gpt-4-0613", SelectedCode = TRUE)
#' }

enrichTextContent <- function(Model = "gpt-4-0613",
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
    cat("\n", "enrichTextContent: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  temperature <- 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template for text generation
  template <- "
  You are an excellent assistant.
  You should double the amount of text without changing the meaning of the input text.
  You should transform the input sentence by replacing words with their synonyms, converting it into a complex structure, adding appropriate adjectives and adverbs, incorporating metaphors.
  You output only the text of the deliverable. The language used is the same as the input text.
  "

  template1 <- "
  Please double the following input text without changing the meaning or intent:
  "

  # Create the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute text generation
  retry_count <- 0
  while (retry_count <= 3) {
    res <- chat4R_history(history = history,
                          Model = Model,
                          temperature = temperature)
    if(nchar(res) >= nchar(input) * 2){ break }
    retry_count <- retry_count + 1
  }

  if(verbose){utils::setTxtProgressBar(pb, 3)}

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(res))
  }
}
