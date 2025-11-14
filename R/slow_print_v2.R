#' Slowly Print Text
#'
#' This function prints the characters of a given text string one by one,
#' with a specified delay between each character. The delay can be either fixed or random.
#'
#' @title Slowly Print Text
#' @description Prints the characters of the input text string one by one,
#'    with a specified delay between each character. If the random parameter
#'    is set to TRUE, the delay will be a random value between 0.0001 and 0.3 seconds.
#'    Otherwise, the delay will be the value specified by the delay parameter.
#' @param text A string representing the text to be printed. Must be a non-NA string.
#' @param random A logical value indicating whether the delay between characters should be random.
#'    Default is FALSE.
#' @param delay A numeric value representing the fixed delay between characters in seconds.
#'    Default is 0.125. Must be a non-negative number.
#' @importFrom assertthat is.string noNA is.number
#' @importFrom stats runif
#' @return Invisible NULL. The function prints the text to the console.
#' @export slow_print_v2
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' slow_print_v2("Hello, World!")
#' slow_print_v2("Hello, World!", random = TRUE)
#' slow_print_v2("Hello, World!", delay = 0.1)
#' }

slow_print_v2 <- function(text, random = FALSE, delay = 0.125) {
  # Enhanced validation with detailed error reporting
  tryCatch({
    assertthat::is.string(text)
    assertthat::noNA(text)
  }, error = function(e) {
    stop(paste("Invalid text argument:", e$message,
               "| Type:", typeof(text),
               "| Class:", class(text),
               "| Length:", length(text)), call. = FALSE)
  })

  assertthat::is.number(delay)
  stopifnot(delay >= 0)

  # Additional safety check: ensure text is character type and single element
  if (!is.character(text) || length(text) != 1 || is.na(text)) {
    stop("Text must be a single non-NA character string", call. = FALSE)
  }

  # Handle empty text case gracefully
  if (nchar(text) == 0) {
    cat("\n")
    return(invisible(NULL))
  }

  # Split text safely with error handling
  text_split <- tryCatch({
    strsplit(text, "")[[1]]
  }, error = function(e) {
    stop(paste("Failed to split text:", e$message), call. = FALSE)
  })

  if (random) {
    for (i in seq_along(text_split)) {
      cat(text_split[i])
      Sys.sleep(stats::runif(1, min = 0.0001, max = 0.4))
    }
  } else {
    for (i in seq_along(text_split)) {
      cat(text_split[i])
      Sys.sleep(delay*stats::runif(1, min = 0.9, max = 1.1))
    }
  }
  cat("\n")  # Move to the next line after printing the text
}


