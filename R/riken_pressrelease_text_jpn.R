#' Extract text from RIKEN press-release (Japanese)
#'
#' @title riken_pressrelease_text_jpn
#' @description This function aims to extract text from RIKEN's press releases
#' and filter out specific strings. The filtering is done in two stages.
#' In the first stage, the text is split at certain strings, and in the second
#' stage, specific strings are removed. Finally, the filtered text is returned.
#' @param url A string. The URL of the RIKEN press-release from which to extract the text.
#' @param k Integer. Number of texts to skip from the end. Default is 4.
#' @importFrom rvest read_html html_nodes html_text
#' @importFrom stringr str_split
#' @importFrom magrittr %>%
#'
#' @return A character vector of the filtered text from the RIKEN press-release.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' riken_pressrelease_text_jpn("https://www.riken.jp/pr/press/2020/20201218_1/")
#' }

#url <- "https://www.riken.jp/press/2017/20170427_1/index.html"
#library(magrittr)

riken_pressrelease_text_jpn <- function(url, k=4){

  # Get text from RIKEN press-release (Japanese)
  text <- url %>%
    rvest::read_html() %>%
    rvest::html_nodes(xpath = '//*[@id="main"]/div') %>%
    rvest::html_text()

  # Filter 01
  sp0 <- c("\n\t\t\t\t\t\t\t",
           "\n\t\t\t\t\t\t",
           "\n\t\t\t\t\n\t\t\t\t\t",
           "\n\n\n\n\n\n",
           "\t\t\t理化学研究所\n\t\t",
           "\r\n要旨\r\n",
           "\r\n要旨",
           "\r\n背景\r\n",
           "\r\n背景",
           "\r\n研究手法と成果\r\n",
           "\r\n研究手法と成果",
           "\r\n今後の期待\r\n",
           "\r\n今後の期待",
           "\r\n補足説明\r\n",
           "\r\n補足説明",
           "\r\n共同研究チーム\r\n",
           "\r\n共同研究チーム",
           "\r\n研究支援\r\n",
           "\r\n研究支援",
           "\r\n原論文情報\r\n",
           "\r\n原論文情報",
           "\r\n発表者\r\n",
           "\r\n発表者",
           "\r\n※共同研究グループ",
           "\r\n研究チーム\r\n",
           "\r\n研究チーム",
           "\r\n共同研究グループ\r\n",
           "\r\n共同研究グループ",
           "\r\n国際共同研究グループ\r\n",
           "\r\n国際共同研究グループ",
           "\r\nお問い合わせ先\r\n",
           "\r\nお問い合わせ先",
           "\r\n報道担当\r\n",
           "\r\n報道担当",
           "\r\n産業利用に関するお問い合わせ\r\n",
           "\r\n産業利用に関するお問い合わせ")
  text0 <- stringr::str_split(text,
                     pattern = paste0(sp0, collapse = "|"))[[1]][-1]

  # Filter 02
  sp1 <- c("\r\n", "\t", "\t ", "\r\n", "\n\n", '\"',
           "\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\n\t\r\n\r\n",
           "\n\n\n\n\n\n", "\n\n\n\n\n", "\n\n\n\n", "\n\n\n\n\n\n")
  text1 <- text0 %>%
    gsub(pattern=paste0(sp1, collapse = "|"),
                   replacement="", .)  %>%
    gsub(pattern="[[][0-9][]]|[[][0-9][0-9][]]",
         replacement="", .)  %>%
    .[nchar(.) > 3] %>%
    .[. != "理化学研究所"] %>%
    .[. != "理化学研究所 広報室 報道担当お問い合わせフォーム"] %>%
    .[. != "お問い合わせフォーム"] %>%
    .[!grepl("お問い合わせフォーム", .)]

  # Filter 03
  for(j in 1:10){text1 <- gsub("  ", " ", text1)}
  text1 <- gsub("^[ ]", "", text1)

  # Proc 01
  text2 <- text1[1:5][nchar(text1[1:5]) < 50]
  text2g <- text2[!grepl("^[0-9][0-9][0-9][0-9]年", text2)]
  text2g <- text2g[!grepl("^理化学研究所", text2g)]
  text3 <- c(paste(text2g, collapse = " "),
             text1[(length(text2)+1):length(text1)])
  text4 <- text3[c(1:(length(text3)-k))]

  if(grepl("^理化学研究所", text4[length(text4)])){
    text5 <- text4[-length(text4)]
  }else{
    text5 <- text4
  }

  return(text5)

}
