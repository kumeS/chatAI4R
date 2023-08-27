#' Speak Selected Text in Japanese on MacOS System
#'
#' @title Speak Selected Text in Japanese
#' @description This function reads aloud the selected text in Japanese using the MacOS system's 'say' command.
#'    The function specifically uses the 'Kyoko' voice for the speech. It only works on MacOS systems.
#' @importFrom assertthat assert_that
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom deepRstudio is_mac
#' @return A message indicating the completion of the speech is returned.
#' @export speakInJA
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Select some text in RStudio and then run the rstudio addins
#' }

speakInJA <- function() {

  # Check if RStudio API is available
  assertthat::assert_that(rstudioapi::isAvailable(), msg = "RStudio API is not available.")

  # Check if the system is MacOS
  assertthat::assert_that(deepRstudio::is_mac(), msg = "This function only works on MacOS.")

  # Get available voices
  voices <- system("say -v \\?", intern = TRUE)
  a <- strsplit(voices, split="       |#")
  b <- data.frame(matrix(NA, nrow = length(a), ncol = 3))

  # Parse voice information
  for(n in seq_len(length(a))) {
    a1 <- a[[n]][a[[n]] != ""]
    a1[2] <- gsub(" ", "", a1[2])
    a1[3] <- gsub("^ ", "", a1[3])
    b[n,] <- a1
  }

  # Filter Japanese voices
  d <- b[grepl("JP$", b$X2),]

  # Check if 'Kyoko' voice is available
  if(any(d$X1 %in% "Kyoko")) {
    H_AI_voices <- "Kyoko"
  } else {
    stop("No AI voice available.")
  }

  # Get the selected text from RStudio
  txt = rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  # Speak the selected text in Japanese
  rate <- 200
  system(paste0("say -r ", rate, " -v ", H_AI_voices, " '", txt, "'"))

  return(message(crayon::red("Finished!!")))
}
