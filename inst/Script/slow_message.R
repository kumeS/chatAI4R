#' Slowly Message Text
#'
#' This function prints the characters of a given text string one by one,
#' with a specified delay between each character. The delay can be either fixed or random.
#'
#' @title Slowly Message Text
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
#' @importFrom crayon black
#' @return Invisible NULL. The function prints the text to the console.
#' @export slow_message
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' slow_message("Hello, World!")
#' slow_message("Hello, World!", random = TRUE)
#' slow_message("Hello, World!", delay = 0.1)
#' }

slow_message <- function(text, random = FALSE, delay = 0.125) {
  assertthat::is.string(text)
  assertthat::noNA(text)
  assertthat::is.number(delay)
  stopifnot(delay >= 0)

  if (random) {
    for (i in seq_along(strsplit(text, "")[[1]])) {
      message(crayon::black(strsplit(text, "")[[1]][i]))
      Sys.sleep(stats::runif(1, min = 0.0001, max = 0.3))
    }
  } else {
    for (i in seq_along(strsplit(text, "")[[1]])) {
      message(crayon::black(strsplit(text, "")[[1]][i]))
      Sys.sleep(delay*stats::runif(1, min = 0.95, max = 1.05))
    }
  }
  message(crayon::black("\n"))  # Move to the next line after printing the text
}

