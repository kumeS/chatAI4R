#' Extract text and perform text embedding from RIKEN press-release
#'
#' @title riken_pressrelease_textEmbedding
#' @description This function extracts text from a given RIKEN press-release URL and performs text embedding.
#' @param url A string. The URL of the RIKEN press-release from which to extract the text.
#' @param api_key A string. The API key for the text embedding service.
#' @importFrom purrr map
#' @return A data frame of the text from the RIKEN press-release and its text embeddings.
#' @export riken_pressrelease_textEmbedding
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' riken_pressrelease_textEmbedding("https://www.riken.jp/pr/press/2020/20201218_1/", "your_api_key")
#' }

riken_pressrelease_textEmbedding <- function(url, api_key){

  # Get text
  text <- riken_pressrelease_text_jpn(url)

  # Perform text embedding
  result <- purrr::map(text, ~textEmbedding(.x, api_key))
  #str(result)


  # Combine text and embeddings into a data frame
  dat <- data.frame(text = text, X = do.call(rbind, result))
  #str(dat); dim(dat)

  #rename
  colnames(dat)[2:ncol(dat)] <- paste0("X", formatC(1:length(result[[1]]), width = 4, flag = "0"))

  # Return the output
  return(dat)

}
