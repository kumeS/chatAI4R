#!/bin/bash

# chatAI4pdf Standalone Script
# This script provides the chatAI4pdf functionality as a separate component
# that can be sourced independently of the main chatAI4R package.
# 
# Usage:
#   source chatAI4pdf_standalone.sh
#   R -e "chatAI4pdf('path/to/file.pdf')"
#
# Requirements:
#   - R with chatAI4R package installed (excluding chatAI4pdf function)
#   - pdftools R package
#   - qpdf system library
#
# Installation of system dependencies:
#   Ubuntu/Debian: sudo apt-get install libqpdf-dev
#   CentOS/RHEL:   sudo yum install qpdf-devel  
#   Rocky Linux:   sudo dnf install qpdf-devel
#   macOS:         brew install qpdf

echo "Loading chatAI4pdf standalone functionality..."

# Check if R is available
if ! command -v R &> /dev/null; then
    echo "Error: R is not installed or not in PATH"
    exit 1
fi

# Check if qpdf system library is available
if ! command -v qpdf &> /dev/null; then
    echo "Warning: qpdf command not found. The pdftools R package may not work correctly."
    echo "Please install qpdf system library:"
    echo "  Ubuntu/Debian: sudo apt-get install libqpdf-dev"
    echo "  CentOS/RHEL:   sudo yum install qpdf-devel"
    echo "  Rocky Linux:   sudo dnf install qpdf-devel"
    echo "  macOS:         brew install qpdf"
fi

# Create the chatAI4pdf function in R
R --slave --no-restore --no-save << 'EOF'

# Define chatAI4pdf function
chatAI4pdf <- function(pdf_file_path,
                       nch = 2000,
                       verbose = TRUE) {

  # Check if chatAI4R is installed
  if (!requireNamespace("chatAI4R", quietly = TRUE)) {
    stop(
      "Package 'chatAI4R' is required but is not installed.\n",
      "Please install it with: install.packages('chatAI4R')",
      call. = FALSE
    )
  }

  # Check if pdftools is installed
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop(
      "Package 'pdftools' is required for PDF processing but is not installed.\n",
      "Please install it with: install.packages('pdftools')\n\n",
      "Note: On Linux, you may need to install system dependencies first:\n",
      "  Ubuntu/Debian: sudo apt-get install libqpdf-dev\n",
      "  CentOS/RHEL:   sudo yum install qpdf-devel\n",
      "  Rocky Linux:   sudo dnf install qpdf-devel\n",
      "  macOS:         brew install qpdf\n",
      "See the standalone script documentation for more information.",
      call. = FALSE
    )
  }

  # Load required packages
  library(chatAI4R)
  
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
    pdf_txt <- sapply(pdf_txt, chatAI4R::ngsub)
  }

  # Combine all text
  pdf_txt_all <- paste0(pdf_txt, collapse = " ")

  #number of characters
  N <- nchar(pdf_txt_all)
  N2 <- round(pds*N, 0)
  if (selection1 == 1){N2[1] <- 1}
  pdf_txt_sub <- substr(pdf_txt_all, N2[1], N2[2])

  # Execute summarization
  res <- chatAI4R::TextSummary(text = pdf_txt_sub,
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

# Make function available in global environment
assign("chatAI4pdf", chatAI4pdf, envir = .GlobalEnv)

cat("chatAI4pdf function loaded successfully!\n")
cat("Usage: chatAI4pdf('path/to/your/file.pdf')\n")

EOF

echo "chatAI4pdf standalone script setup complete!"
echo ""
echo "To use this function:"
echo "1. Source this script: source chatAI4pdf_standalone.sh"
echo "2. Start R and use: chatAI4pdf('path/to/your/file.pdf')"
echo ""
echo "Or run directly: R -e \"source('chatAI4pdf_standalone.sh'); chatAI4pdf('your_file.pdf')\""