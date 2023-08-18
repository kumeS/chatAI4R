#' Translate English Text to Other Languages via DeepL API
#'
#' This function takes English text from the clipboard and translates it into the specified target language using the DeepL API.
#' The translated text is then placed back into the clipboard, ready to be pasted wherever needed.
#'
#' @title Translate English Text to Other Languages via DeepL API
#' @description Translate English text from the clipboard into the specified target language using the DeepL API.
#' @param input The text to be translated, default is the content of the clipboard. \code{assertthat::is.string(input)}
#' @param target_lang The language into which the text should be translated. Options are:
#'    BG - Bulgarian, CS - Czech, DA - Danish, DE - German, EL - Greek,
#'    EN - English (unspecified variant for backward compatibility; please select EN-GB or EN-US instead),
#'    EN-GB - English (British), EN-US - English (American), ES - Spanish, ET - Estonian,
#'    FI - Finnish, FR - French, HU - Hungarian, ID - Indonesian, IT - Italian,
#'    JA - Japanese, KO - Korean, LT - Lithuanian, LV - Latvian, NB - Norwegian (Bokmål),
#'    NL - Dutch, PL - Polish, PT - Portuguese (unspecified variant for backward compatibility; please select PT-BR or PT-PT instead),
#'    PT-BR - Portuguese (Brazilian), PT-PT - Portuguese (all Portuguese varieties excluding Brazilian Portuguese),
#'    RO - Romanian, RU - Russian, SK - Slovak, SL - Slovenian, SV - Swedish,
#'    TR - Turkish, UK - Ukrainian, ZH - Chinese (simplified).
#' \code{assertthat::is.string(target_lang)}
#' @param Auth_Key The authentication key for the DeepL API.
#' @param free_mode A logical value indicating whether to use the free or paid DeepL API. Default is TRUE.
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom clipr read_clip write_clip
#' @return The translated text is placed into the clipboard and the function returns the result of \code{clipr::write_clip}.
#' @export deepel_from_EN
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' #Copy English text into your clipboard the excute the function. Then paste your clipboard.
#' deepel_from_EN(target_lang = 'JA')
#'
#' }

deepel_from_EN <- function(input = clipr::read_clip(),
                           target_lang = 'JA',
                           Auth_Key = Sys.getenv("DeepL_API_KEY"),
                           free_mode = TRUE){

  assertthat::assert_that(assertthat::is.string(input))
  assertthat::assert_that(assertthat::is.string(target_lang))
  assertthat::assert_that(assertthat::is.string(Auth_Key))
  assertthat::assert_that(is.logical(free_mode))

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
    source_lang = "EN",
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

  # Convert to string
  res <- as.character(translated_text$text)

  # Put into the clipboard
  return(clipr::write_clip(res))
}
