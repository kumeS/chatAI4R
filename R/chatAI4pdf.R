#' Summarize PDF Text Using a Large Language Model
#'
#' This function reads a PDF file and summarizes its content using a specified Large Language Model (LLM).
#'
#' @title chatAI4pdf
#' @description Reads a PDF file and summarizes its content using a specified Large Language Model (LLM).
#' @param pdf_file_path The path to the PDF file to be summarized. Must be a string.
#' @param nch The maximum number of characters for the summary. Default is 2000.
#' @param verbose Logical flag to print the summary. Default is TRUE.
#' @importFrom pdftools pdf_text
#' @return A string containing the summarized text.
#' @export chatAI4pdf
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' #Read GPT-4 Technical Report
#' pdf_txt <- pdftools::pdf_text("https://cdn.openai.com/papers/gpt-4.pdf")
#'
#' #Extract some text
#' pdf_txt <- pdf_txt[1:3]
#'
#' #Execute
#' summary_text <- chatAI4pdf("1403.2805.pdf", Model, nch, Summary_block)
#' }

chatAI4pdf <- function(pdf_file_path,
                       nch = 2000,
                       verbose = TRUE) {

  # Read PDF text
  pdf_txt <- pdftools::pdf_text(pdf_file_path)

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(pdf_file_path),
    assertthat::is.count(nch),
    assertthat::noNA(pdf_file_path),
  )

  # Pre-processing
  for(n in 1:10) {
    pdf_txt <- sapply(pdf_txt, ngsub)
  }

  # Combine all text
  pdf_txt_all <- paste0(pdf_txt, collapse = " ")

  # Execute summarization
  res <- TextSummary(text = pdf_txt_all,
                     nch = nch,
                     verbose = FALSE,
                     returnText = TRUE)

  # Show the summary text if verbose is TRUE
  if(verbose) {
    cat(res)
  }

  # Return the summary as a string
  return(res)
}
