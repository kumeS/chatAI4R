#' Summarize PDF Text via LLM
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
#' #Baktash et al: GPT-4: A REVIEW ON ADVANCEMENTS AND OPPORTUNITIES IN NATURAL LANGUAGE PROCESSING
#' pdf_file_path <- "https://arxiv.org/pdf/2305.03195.pdf"
#'
#' #Execute
#' summary_text <- chatAI4pdf(pdf_file_path)
#' }

chatAI4pdf <- function(pdf_file_path,
                       nch = 2000,
                       verbose = TRUE) {

  #selection
  choices1 <- c("All text",  "First Quarter Text",  "Second Quarter Text",
                "Third Quarter Text", "Fourth Quarter Text")
  selection1 <- utils::menu(choices1, title = "Where would you summarize the text?")

  if (selection1 == 1) {
    pds <- c(0, 1)
  } else if (selection1 == 2) {
    pds <- c(0, 0.25)
  } else if (selection1 == 3) {
    pds <- c(0.25, 0.5)
  } else if (selection1 == 4) {
    pds <- c(0.5, 0.75)
  } else if (selection1 == 5) {
    pds <- c(0.75, 1)
  } else {
    return(message("No valid selection made."))
  }

  # Read PDF text
  pdf_txt <- pdftools::pdf_text(pdf_file_path)

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(pdf_file_path),
    assertthat::is.count(nch),
    assertthat::noNA(pdf_file_path)
  )

  # Pre-processing
  for(n in 1:10) {
    pdf_txt <- sapply(pdf_txt, ngsub)
  }

  # Combine all text
  pdf_txt_all <- paste0(pdf_txt, collapse = " ")

  #number of characters
  N <- nchar(pdf_txt_all)
  N2 <- round(pds*N, 0)
  if (selection1 == 1){N2[1] <- 1}
  pdf_txt_sub <- substr(pdf_txt_all, N2[1], N2[2])

  # Execute summarization
  res <- TextSummary(text = pdf_txt_sub,
                     nch = nch,
                     verbose = FALSE,
                     returnText = TRUE)

  # Show the summary text if verbose is TRUE
  if(verbose) {
    cat("\nSummarized text:\n")
    cat(res)
  }

  # Return the summary as a string
  return(res)
}
