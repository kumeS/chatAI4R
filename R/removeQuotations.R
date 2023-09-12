#' Remove All Types of Quotations from Text
#'
#' This function takes a text string as input and removes all occurrences
#' of single, double, and back quotations marks.
#'
#' @param text A character string from which quotations will be removed.
#' @importFrom assertthat assert_that is.string noNA
#' @return A character string with all types of quotations removed.
#' @export removeQuotations
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' removeQuotations("\"XXX'`\"YYY'`") # Returns "XXXYYY"
#' }

removeQuotations <- function(text) {
  # Validate that the input 'text' is a single string without NA values
  assert_that(is.string(text), noNA(text))

  # Remove single quotations from the text
  res <- gsub("\'", "", text)

  # Remove double quotations from the text
  res <- gsub("\"", "", res)

  # Remove back quotations from the text
  res <- gsub("\`", "", res)

  return(res)
}
