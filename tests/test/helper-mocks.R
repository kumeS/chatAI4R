# =============================================================================
# Test Helper: Mock Functions for Testing
# =============================================================================
#
# This file provides mock functions to test clipboard-dependent functions
# without requiring actual clipboard operations.
#
# =============================================================================

#' Mock Clipboard Read Function
#'
#' Temporarily replaces clipr::read_clip() with a mock function that returns
#' predefined text. This allows testing of clipboard-dependent functions.
#'
#' @param mock_text Character string to return instead of clipboard content
#' @param test_code Code to execute with the mocked clipboard
#' @return Result of test_code execution
#'
#' @examples
#' \dontrun{
#' with_mock_clipboard("test code", {
#'   result <- some_clipboard_function()
#' })
#' }
with_mock_clipboard <- function(mock_text, test_code) {
  # Store original function
  original_read_clip <- NULL
  if (exists("read_clip", envir = asNamespace("clipr"))) {
    original_read_clip <- get("read_clip", envir = asNamespace("clipr"))
  }
  
  # Create mock function
  mock_read_clip <- function() {
    return(mock_text)
  }
  
  # Replace with mock
  tryCatch({
    unlockBinding("read_clip", asNamespace("clipr"))
    assign("read_clip", mock_read_clip, envir = asNamespace("clipr"))
    lockBinding("read_clip", asNamespace("clipr"))
    
    # Execute test code
    result <- eval(substitute(test_code), envir = parent.frame())
    
    # Restore original function
    if (!is.null(original_read_clip)) {
      unlockBinding("read_clip", asNamespace("clipr"))
      assign("read_clip", original_read_clip, envir = asNamespace("clipr"))
      lockBinding("read_clip", asNamespace("clipr"))
    }
    
    return(result)
    
  }, error = function(e) {
    # Ensure we restore even on error
    if (!is.null(original_read_clip)) {
      unlockBinding("read_clip", asNamespace("clipr"))
      assign("read_clip", original_read_clip, envir = asNamespace("clipr"))
      lockBinding("read_clip", asNamespace("clipr"))
    }
    stop(e)
  })
}

#' Mock RStudio API Functions
#'
#' Provides mock implementations for RStudio API functions to enable
#' testing outside of RStudio environment.
#'
#' @param selected_text Text to return as "selected" in RStudio
#' @param test_code Code to execute with mocked RStudio API
#' @return Result of test_code execution
with_mock_rstudio <- function(selected_text, test_code) {
  # Mock rstudioapi functions
  mock_env <- new.env(parent = emptyenv())
  
  mock_env$isAvailable <- function() TRUE
  
  mock_env$getActiveDocumentContext <- function() {
    list(
      selection = list(
        list(text = selected_text)
      )
    )
  }
  
  mock_env$insertText <- function(text) {
    invisible(text)
  }
  
  # This is a simplified mock - actual implementation would need more work
  # For now, we'll skip RStudio-dependent tests
  warning("RStudio mocking is limited - some tests may be skipped")
  
  return(NULL)
}

#' Create Temporary Test Image
#'
#' Creates a simple temporary image file for testing vision functions
#'
#' @param width Image width in pixels
#' @param height Image height in pixels
#' @return Path to temporary image file
create_test_image <- function(width = 100, height = 100) {
  tmpfile <- tempfile(fileext = ".png")
  
  png(tmpfile, width = width, height = height)
  plot(1:10, 1:10, main = "Test Image", xlab = "X", ylab = "Y",
       pch = 16, col = "blue", cex = 2)
  text(5, 5, "TEST", cex = 3, col = "red")
  dev.off()
  
  return(tmpfile)
}

#' Clean Up Test Resources
#'
#' Removes temporary files created during testing
#'
#' @param files Vector of file paths to remove
cleanup_test_files <- function(files) {
  for (file in files) {
    if (file.exists(file)) {
      unlink(file)
    }
  }
  invisible(NULL)
}

# Export functions to global environment when sourced
assign("with_mock_clipboard", with_mock_clipboard, envir = .GlobalEnv)
assign("with_mock_rstudio", with_mock_rstudio, envir = .GlobalEnv)
assign("create_test_image", create_test_image, envir = .GlobalEnv)
assign("cleanup_test_files", cleanup_test_files, envir = .GlobalEnv)

cat("Test helper functions loaded:\n")
cat("  • with_mock_clipboard()\n")
cat("  • with_mock_rstudio()\n")
cat("  • create_test_image()\n")
cat("  • cleanup_test_files()\n\n")
