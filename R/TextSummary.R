#' Summarize Long Text
#'
#' @title Summarize Long Text
#' @description This function summarizes a long text using LLM.
#'    The development of this function started with the idea that it might be interesting
#'    to perform a copy-and-paste, sentence summarization and aims to be an evangelist for
#'    copy-and-paste LLM execution. It is recommended to run this function with GPT-4, but it is not cost effective and slow.
#'    This is still an experimental feature.
#' @param text A character vector containing the text to be summarized.
#'    If not provided, the function will attempt to read from the clipboard.
#' @param nch Integer specifying the number of characters at which to split the input text for processing.
#' @param verbose A logical flag to print the message. Default is TRUE.
#' @param returnText A logical flag to return summarized text results. Default is FALSE.
#' @importFrom clipr read_clip write_clip
#' @importFrom utils menu
#' @importFrom assertthat assert_that is.string is.count
#' @return The summarized text is placed into the clipboard and the function returns the result of \code{clipr::write_clip}.
#' @export TextSummary
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' TextSummary(text = c("This is a long text to be summarized.",
#'                      "It spans multiple sentences and goes into much detail."),
#'             nch = 10)
#' }

TextSummary <- function(text = clipr::read_clip(),
                        nch = 2000,
                        verbose = TRUE,
                        returnText = FALSE){

  choices1 <- c("GPT-3.5", "GPT-4 (0613)", "Another LLM")
  selection1 <- utils::menu(choices1, title = "Which language model do you prefer?")

  if (selection1 == 1) {
    Model = "gpt-3.5-turbo"
  } else if (selection1 == 2) {
    Model = "gpt-4-0613"
  } else if (selection1 == 3) {
    return(message("No valid selection made."))
  } else {
    return(message("No valid selection made."))
  }

  choices2 <- c("High Compression Rate", "Middle Compression Rate", "Low Compression Rate")
  selection2 <- utils::menu(choices2, title = "What is the summary rate of the text?")

  if (selection2 == 1) {
  Summary_block = nch*0.1
  } else if (selection2 == 2) {
  Summary_block = nch*0.25
  } else if (selection2 == 3) {
  Summary_block = nch*0.4
  } else {
  return(message("No valid selection made."))
  }

  #temperature
  temperature = 1

  # Validate input types and values
  assertthat::assert_that(assertthat::is.string(text[1]))
  assertthat::assert_that(assertthat::is.count(nch), nch > 0)
  assertthat::assert_that(assertthat::is.count(Summary_block), Summary_block > 0)
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.number(temperature), temperature >= 0, temperature <= 1)

  # Preprocessing
  text0 <- paste0(text, collapse = " ")
  text0 <- gsub('\", \n\"', ' ', text0)
  text0 <- gsub('[(][0-9][0-9][:][0-9][0-9][)]', '', text0)
  text0 <- gsub('[(][0-9][:][0-9][0-9][:][0-9][0-9][)]', '', text0)

  # Splitting the text
  len <- nchar(text0)
  if(len <= nch){
    #nch <- len
    text1 <- text0
  }else{
    val <- round(seq(1, len, length.out = ceiling(len/nch)), 0)

    # Define the start and end indices for substr
    start_indices <- val[1:(length(val)-1)]
    end_indices <- val[2:(length(val))]

    # Use sapply to apply substr function
    text1 <- sapply(seq_len(length(start_indices)),
                    function(i) substr(text0, start_indices[i], end_indices[i]))
    #sum(nchar(unlist(text1)))
  }

  if(verbose){
  cat("\n")
  cat("Text nchar:", len, "\n")
  cat("Text block:", length(text1), "\n")
  }

  template0 = "
  You are a great assistant and an excellent co-pilot.
  Your response should always be both response speed and accuracy.
  You summarize and itemize the user's input. Your output is only the summarized text.
  You must strictly reproduce and reconsider every detail without being overly concise in your writing.
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

  if(returnText){
  cat("\n")
  cat("TextSummary ( nchar:", nchar(text0), "): ", "\n")
  pb <- utils::txtProgressBar(min = 0, max = length(pr), style = 3)
  }

  # Execution
  if(verbose){cat("\n")}
  for(n in seq_len(length(pr))){
    #n <- 1
    if(verbose){cat("Text: ", n, "\n")}
    history[[length(history) + 1]] <- list('role' = 'user', 'content' = pr[n])

    retry_count <- 0
    while (retry_count <= 2) {
      res <- chat4R_history(history = history,
                            Model = Model,
                            temperature = temperature)
      if(nchar(res) < Summary_block + 100){ break }
      retry_count <- retry_count + 1
    }

    if(verbose){cat(res, "\n")}
    history[[length(history) + 1]] <- list('role' = 'assistant', 'content' = res)
    history <- history[sapply(history[1:length(history)], function(x) x$role) != "user"]

    #output
    result[[n]] <- res
    if(returnText){utils::setTxtProgressBar(pb, n)}

  }

  # Put into the clipboard
  if(returnText){
  return(unlist(result))
  }else{
  txt2 <- paste0(result, collapse = " ")
  if(verbose){
  cat("\n")
  cat("Summarized text nchar:", nchar(txt2), "\n")
  message("Finished!!")
  }
  return(clipr::write_clip(txt2))
  }
}

