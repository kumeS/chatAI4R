#' Translate Selected Text to English via DeepL API
#'
#' This function uses the rstudioapi to execute English translation of the selected text using the DeepL API.
#' It will attempt to auto-detect the language of the text and translate it into English.
#' First, select the text and execute "DeepL Translation into English" from addins.
#' As a result, the selected part will be translated into English.
#'
#' @title Translate Selected Text to English via DeepL API
#' @description Translate the selected text in RStudio into English using the DeepL API with auto-detection of the source language.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom assertthat assert_that
#' @return A message indicating the completion of the translation. No value is returned.
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' #Select the following text: "La selección está traducida al inglés."
#' #Then, execute "DeepL Translation into English" from addins.
#'
#' }

deepel_rstudioapi_2EN <- function(){

  assertthat::assert_that(rstudioapi::isAvailable())

  # Get the selected text
  txt = rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  # Translate into English
  res <- deepel(input = txt,
                target_lang = 'EN',
                Auth_Key = Sys.getenv("DeepL_API_KEY"),
                free_mode = TRUE)$text

  # Replace the selected text
  rstudioapi::insertText(text = as.character(res))
  return(message("Finished!!"))

}

