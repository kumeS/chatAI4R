#' Speak Clipboard in Japanese on MacOS System
#'
#' @title Speak Clipboard in Japanese
#' @description This function reads aloud the clipboard content in Japanese using the MacOS system's 'say' command.
#'    The function specifically uses the 'Kyoko' voice for the speech. It only works on MacOS systems.
#' @importFrom assertthat assert_that
#' @importFrom clipr read_clip
#' @return A message indicating the completion of the speech is returned.
#' @export speakInJA_v2
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Copy some text into your clipboard in RStudio and then run the function
#'   speakInJA_v2()
#' }

speakInJA_v2 <- function() {

  # Check if the system is MacOS
  assertthat::assert_that(Sys.info()['sysname'] == 'Darwin', msg = "This function only works on MacOS.")

  # Get available voices
  voices <- system("say -v ?", intern = TRUE)
  available_voices <- strsplit(voices, split = "\n")[[1]]

  # Check if 'Kyoko' voice is available
  assertthat::assert_that("Kyoko" %in% available_voices, msg = "Kyoko voice is not available.")

  # Get the clipboard text
  txt = paste0(clipr::read_clip(), collapse = " ")

  # Validate that the clipboard contains text
  assertthat::assert_that(assertthat::is.string(txt))

  # Speak the clipboard text in Japanese
  rate <- 200
  system(paste0("say -r ", rate, " -v Kyoko '", txt, "'"))

  return(message("Finished!!"))
}
