#' Speak Selected Text in English on MacOS System
#'
#' @title Speak Selected Text in English
#' @description This function reads aloud the selected text in English using the MacOS system's 'say' command.
#'    It uses the voice specified by the parameter `systemVoice`. The default voice is "Alex". It only works on MacOS systems.
#' @param systemVoice The voice to be used for speech. Default is "Alex".
#' @importFrom assertthat assert_that
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom deepRstudio is_mac
#' @return A message indicating the completion of the speech is returned.
#' @export speakInEN
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Select some text in RStudio and then run the rstudio addin
#' }

speakInEN <- function(systemVoice = "Alex") {

  # Check if RStudio API is available
  assertthat::assert_that(rstudioapi::isAvailable(), msg = "RStudio API is not available.")

  # Check if the system is MacOS
  assertthat::assert_that(deepRstudio::is_mac(), msg = "This function only works on MacOS.")

  # Get available voices
  voices <- system("say -v \\?", intern = TRUE)
  a <- strsplit(voices, split = "       |#")
  b <- data.frame(matrix(NA, nrow = length(a), ncol = 3), stringsAsFactors = FALSE)
  names(b) <- c("Voice", "Language", "Description")

  # Parse voice information
  for (n in seq_len(length(a))) {
    a1 <- a[[n]][a[[n]] != ""]
    a1[2] <- gsub(" ", "", a1[2])
    a1[3] <- gsub("^ ", "", a1[3])
    b[n, ] <- a1
  }

  # Check if specified voice is available
  if (any(b$Voice %in% systemVoice)) {
    H_AI_voice <- systemVoice
  } else {
    stop(paste("Voice", systemVoice, "is not available."))
  }

  # Get the selected text from RStudio
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  # Speak the selected text in English
  rate <- 200
  system(paste0("say -r ", rate, " -v ", H_AI_voice, " '", txt, "'"))

  return(message(crayon::red("Finished!!")))
}
