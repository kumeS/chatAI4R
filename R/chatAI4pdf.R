#' Summarize PDF Text Using a Large Language Model
#'
#' This function reads a PDF file and summarizes its content using a specified Large Language Model (LLM).
#'
#' @title chatAI4pdf
#' @description Reads a PDF file and summarizes its content using a specified Large Language Model (LLM).
#' @param pdf_file_path The path to the PDF file to be summarized. Must be a string.
#' @param Model The Large Language Model to be used for summarization. Default is "gpt-3.5-turbo".
#' @param nch The maximum number of characters for the summary. Default is 2000.
#' @param Summary_block The block size for summarization. Default is 150.
#' @param verbose Logical flag to print the summary. Default is TRUE.
#' @importFrom pdftools pdf_text
#' @return A string containing the summarized text.
#' @export chatAI4pdf
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' download.file("http://arxiv.org/pdf/1403.2805.pdf", "1403.2805.pdf", mode = "wget")
#' pdf_txt <- pdftools::pdf_text("1403.2805.pdf")
#'
#' #Extract some text
#' pdf_txt <- pdf_txt[1:3]
#'
#' #Execute
#' summary_text <- chatAI4pdf("1403.2805.pdf", Model, nch, Summary_block)
#' }

chatAI4pdf <- function(pdf_file_path,
                       Model = "gpt-3.5-turbo",
                       nch = 2000,
                       Summary_block = 150,
                       verbose = TRUE) {

  # Read PDF text
  pdf_txt <- pdftools::pdf_text(pdf_file_path)

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(pdf_file_path),
    assertthat::is.string(Model),
    assertthat::is.count(nch),
    assertthat::is.count(Summary_block),
    assertthat::noNA(pdf_file_path),
    assertthat::noNA(Model)
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
                     Summary_block = Summary_block,
                     Model = Model,
                     temperature = 1,
                     verbose = FALSE,
                     returnText = TRUE)

  # Show the summary text if verbose is TRUE
  if(verbose) {
    cat(res)
  }

  # Return the summary as a string
  return(res)
}
