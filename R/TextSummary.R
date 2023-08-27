#' Summarize Long Text
#'
#' @title Summarize Long Text
#' @description This function summarizes a long text using AI models like GPT-4.
#'    It is recommended to execute this function with GPT-4. This is an experimental function.
#' @param text A character vector containing the text to be summarized.
#' If not provided, the function will attempt to read from the clipboard.
#' @param nch Integer specifying the number of characters at which to split the input text for processing.
#' @param Summary_block Integer specifying the target number of characters for the summarized output.
#' @param Model A character string specifying the AI model to be used for text summarization. Default is "gpt-3.5-turbo".
#'    Execution with GPT-4 is recommended.
#' @param temperature Numeric specifying the randomness of the AI model's output.
#' @param verbose A logical flag to print the message. Default is TRUE.
#' @param SpeakJA A logical flag to enable Japanese voice output. Default is FALSE.
#' @importFrom clipr read_clip write_clip
#' @importFrom assertthat assert_that is.string is.count
#' @return The summarized text is placed into the clipboard and the function returns the result of \code{clipr::write_clip}.
#' @export TextSummary
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' TextSummary(text = c("This is a long text to be summarized.",
#'                      "It spans multiple sentences and goes into much detail."),
#'             nch = 1000, Summary_block = 100,
#'             Model = "gpt-3.5-turbo", temperature = 1)
#' }

TextSummary <- function(text = clipr::read_clip(),
                        nch = 1500,
                        Summary_block = 150,
                        Model = "gpt-3.5-turbo",
                        temperature = 1,
                        verbose = TRUE,
                        SpeakJA = FALSE){

  # Validate input types and values
  assertthat::assert_that(assertthat::is.string(text[1]))
  assertthat::assert_that(assertthat::is.count(nch), nch > 0)
  assertthat::assert_that(assertthat::is.count(Summary_block), Summary_block > 0)
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)
  assertthat::assert_that(is.logical(SpeakJA))

  # Preprocessing
  text0 <- paste0(text, collapse = " ")
  text0 <- gsub('\", \n\"', ' ', text0)
  text0 <- gsub('[(][0-9][0-9][:][0-9][0-9][)]', '', text0)
  text0 <- gsub('[(][0-9][:][0-9][0-9][:][0-9][0-9][)]', '', text0)

  # Splitting the text
  len <- nchar(text0)
  if(len < nch){nch <- len}
  text1 <- sapply(seq(1, floor(len/nch)*nch, by=nch), function(i) substr(text0, i, min(i+nch-1, len)))

  template0 = "
  You are a great assistant. You summarize and itemize the user's input.
  Your output is just the summarized text.
  The language used in the summary is the same as the input text.
  "

  # Template creation
  template1 = "
  Please summarize the following text within %s characters.:
  "

  # Substituting arguments into the prompt
  template1s <- sprintf(template1, Summary_block)

  # Prompt creation
  pr <- paste0(template1s, text1, sep=" ")

  # Variable creation
  result <- list()
  history <- list(list('role' = 'system', 'content' = template0))

  # Execution
  for(n in seq_len(length(pr))){
    #n <- 1
    if(verbose){cat("Text: ", n, "\n")}
    history[[length(history) + 1]] <- list('role' = 'user', 'content' = pr[n])

    retry_count <- 0
    while (retry_count < 5) {
      res <- chat4R_history(history = history,
                            Model = Model,
                            temperature = temperature)
      if(nchar(res) < Summary_block + 100){ break }
      retry_count <- retry_count + 1
    }

    if(verbose){cat(res, "\n")}
    history[[length(history) + 1]] <- list('role' = 'assistant', 'content' = res)
    history <- history[sapply(history[1:length(history)], function(x) x$role) != "user"]

    if(all(verbose, SpeakJA)){
    system(paste0("say -r 200 -v Kyoko '", res, "'"))
    }

    #output
    result[[n]] <- res

  }

  if(verbose){
  #Re-summarize
  txt2 <- paste0(result, collapse = " ")
  #nchar(txt2)

  # Substituting arguments into the prompt
  Summary_block1 <- 300
  template1ss <- sprintf(template1, Summary_block1)
  pr1 <- paste0(template1ss, txt2, sep=" ")

  history <- list(list('role' = 'system', 'content' = template0),
                  list('role' = 'user', 'content' = pr1))

  retry_count <- 0
  while (retry_count < 5) {
  res1 <- chat4R_history(history = history,
                         Model = Model,
                         temperature = temperature)
  if(nchar(res1) < Summary_block1 + 100){ break }
  retry_count <- retry_count + 1
  }

  cat("Summary ( nchar:",  nchar(res1), "): \n")
  cat(res1, "\n")

  if(all(verbose, SpeakJA)){
  system(paste0("say -r 200 -v Kyoko '", res, "'"))
  }
  }

  # Put into the clipboard
  return(clipr::write_clip(txt2))

}

