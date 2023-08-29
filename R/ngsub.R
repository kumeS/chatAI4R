#' Remove Extra Spaces and Newline Characters
#'
#' This function removes extra spaces and newline characters from the given text.
#' It replaces sequences of multiple spaces with a single space and removes newline characters followed by a space.
#'
#' @title ngsub
#' @description Remove extra spaces and newline characters from text.
#' @param text The input text from which extra spaces and newline characters need to be removed.
#' @return Returns the modified text as a character string.
#' @export ngsub
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' ngsub("This is  a text \n with  extra   spaces.")
#' }

ngsub <- function(text){
  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(text),
    assertthat::noNA(text)
  )

  # Remove newline characters followed by a space and replace multiple spaces with a single space
  results <- gsub("\n ", " ", gsub("  ", " ", text))
  results <- sub("^ ", "", results)
  results <- sub(" $", "", results)

  # Return the modified text as a character string
  return(as.character(results))
}
