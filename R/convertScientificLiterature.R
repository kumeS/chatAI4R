#' Convert to Scientific Literature
#'
#' This function assists in converting the input text into scientific literature.
#' It uses the OpenAI GPT model for text generation to assist in the conversion process.
#' The function reads the input either from the RStudio active document or the clipboard.
#'
#' @title convertScientificLiterature
#' @description Convert input text into scientific literature.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4o-mini".
#' @param SelectedCode Logical flag to indicate whether to read the input from RStudio's active document. Default is TRUE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @importFrom assertthat assert_that is.string noNA
#' @return Inserts the converted text into the RStudio active document if SelectedCode is TRUE, otherwise writes to the clipboard.
#' @export convertScientificLiterature
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' convertScientificLiterature(SelectedCode = FALSE)
#' }

convertScientificLiterature <- function(Model = "gpt-4o-mini",
                                        SelectedCode = TRUE) {

  # Read input either from RStudio active document or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input = rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input = paste0(clipr::read_clip(), collapse = " \n")
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature = 1

  # Create template for the prompt
  template = "
  You are an excellent assistant and a highly qualified scientific researcher of professorial level.
  You always have to convert the input text into scientific literature.
  You output only the text of the deliverable.
  The language used is always the same as the input text.
  "

  template1 = "
  Please convert the following input text into scientific literature.:
  "

  # Substitute arguments into the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Create prompt history
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

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

  # Output the converted text
  if(SelectedCode){
    rstudioapi::insertText(text = res)
  } else {
    # Write to the clipboard
    return(clipr::write_clip(res))
  }
}
