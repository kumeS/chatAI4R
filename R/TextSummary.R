#' Summarize Long Text
#'
#' @title Summarize Long Text
#' @description This function summarizes a long text using an AI model.
#' @param text A character vector containing the text to be summarized. If not provided, the function will attempt to read from the clipboard.
#' @param nch Integer specifying the number of characters at which to split the input text for processing.
#' @param Summary_block Integer specifying the target number of characters for the summarized output.
#' @param Model A character string specifying the AI model to be used for text summarization.
#' @param temperature Numeric specifying the randomness of the AI model's output.
#' @param language A character string specifying the language in which the summary should be generated.
#' @importFrom magrittr %>%
#' @importFrom purrr map
#' @importFrom clipr read_clip
#' @importFrom assertthat assert_that is.string
#' @return A list of character vectors where each vector is a part of the summarized text.
#' @export TextSummary
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' TextSummary(text = c("This is a long text to be summarized.",
#'                      "It spans multiple sentences and goes into much detail."),
#'             nch = 1000, Summary_block = 100,
#'             Model = "gpt-3.5-turbo", temperature = 1, language = "English")
#' }

TextSummary <- function(text = clipr::read_clip(),
                        nch=1000,
                        Summary_block = 200,
                        Model = "gpt-3.5-turbo-16k",
                        temperature = 1,
                        language = "Japanese"){
  # Asserting input types and values
  assertthat::assert_that(assertthat::is.string(text[1]))
  assertthat::assert_that(assertthat::is.count(nch), nch > 0)
  assertthat::assert_that(assertthat::is.count(Summary_block), Summary_block > 0)
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)
  assertthat::assert_that(assertthat::is.string(language))

  # Preprocessing
  text0 <- paste0(text, collapse = " ") %>%
    gsub('\", \n\"', ' ', .) %>%
    gsub('[(][0-9][0-9][:][0-9][0-9][)]', '', .) %>%
    gsub('[(][0-9][:][0-9][0-9][:][0-9][0-9][)]', '', .)

  # Splitting the text
  len <- nchar(text0)
  if(len < nch){nch <- len}
  text1 <- sapply(seq(1, floor(len/nch)*nch, by=nch), function(i) substr(text0, i, min(i+nch-1, len)))

  # Template creation
  template1 = "
  Language: %s
  Number of characters: %s
  Deliverables: Summary text only

  You are a great assistant.
  I will give you the input text of the minutes.
  Please complete the following required fields
  Language used in summary: {Language}
  Number of characters in output: {Number of characters}
  Deliverables you will output: {Deliverables}
  Input text:
  "

  # Substituting arguments into the prompt
  template1s <- sprintf(template1, language, Summary_block)

  # Prompt creation
  pr <- paste0(template1s, text1, sep=" ")

  # Variable creation
  result <- list()

  # Execution
  for(n in seq_len(length(pr))){
    cat(n, "\n")

    retry_count <- 0
    while (retry_count < 5) {
      res <- chat4R(content = pr[n],
                            Model = Model,
                            temperature = temperature,
                            simple = TRUE)
      if(nchar(res) < Summary_block + 100){ break }
      retry_count <- retry_count + 1
    }

    result[[n]] <- res

  }

  return(result)

}

