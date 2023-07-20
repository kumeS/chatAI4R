#' @title DeepL Translation Function
#'
#' @description This function translates text using the DeepL API.
#'
#' @param input The text to be translated.
#' @param target_lang The target language code for translation (e.g., 'EN' for English, 'JA' for Japanese).
#' @param Auth_Key Your DeepL API authentication key.
#' @param free_mode A boolean value; set to TRUE if using the free DeepL API, FALSE if using the paid version. Default is TRUE.
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#'
#' @return A data frame containing the detected source language, target language, and translated text.
#'
#' @export deepel
#'
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' Auth_Key <- "your_deepl_api_key"
#' input <- "Hello, how are you?"
#' target_lang <- "JA"
#'
#' translated_text <- deepel(input, target_lang, Auth_Key)
#' print(translated_text)
#' }
#'

deepel <- function(input,
                   target_lang = 'EN',
                   Auth_Key = Sys.getenv("DeepL_API_KEY"),
                   free_mode=TRUE) {

  if(free_mode){
    base_url <- "https://api-free.deepl.com/v2/translate"
  }else{
    base_url <- "https://api.deepl.com/v2/translate"
  }

  # Set API request parameters
  # English: EN, Japanese: JA
  params <- list(
    auth_key = Auth_Key,
    text = input,
    target_lang = target_lang
  )

  # Send API request
  response <- httr::GET(url = base_url, query = params)

  # Extract translation result from response
  response_content <- httr::content(response, "text", encoding = "UTF-8")
  parsed_content <- jsonlite::fromJSON(response_content)

  translated_text <-
    data.frame(detected_source_language=parsed_content$translations$detected_source_language,
               target_language=target_lang,
               text=parsed_content$translations$text)

  return(translated_text)

}
