
library(magrittr)
library(purrr)

#テストテキスト
text <- read.delim("/Users/sas/Desktop/R_chatAI4R/text/pivot_text.txt")

#長文要約するR関数
longTextSummary <- function(text,
                            api_key,
                            nch=2000,
                            Summary_block = 500,
                            Summary_characters = 500,
                            Model = "gpt-3.5-turbo-16k",
                            temperature=1,
                            language="Japanese"
                            ){

#前処理
text0 <- paste0(text, collapse = " ") %>%
  gsub('\", \n\"', ' ', .)

##テキストの分割
len <- nchar(text0)
text1 <- sapply(seq(1, floor(len/nch)*nch, by=nch), function(i) substr(text0, i, min(i+nch-1, len)))

#テンプレートの作成
template1 = "
Language: %s
Number of characters: %s
Deliverables: Summary text only

You are a great assistant.
I will give you the text of the minutes.
Please complete the following required fields
Language used in summary: {Language}
Number of characters in output: {Number of characters}
Deliverables you will output: {Deliverables}
"

#引数をプロンプトに代入する
template1s <- sprintf(template1, language, Summary_block)

#プロンプトの作成
pr <- paste0(template1s, text1, sep=" ")

#実行
result <- purrr::map(pr,
                     ~chatAI4R::chat4R(content=.x,
                                         api_key=api_key,
                                         Model = Model,
                                         temperature = temperature,
                                         simple=TRUE))

#str(result)

return(result)

}




