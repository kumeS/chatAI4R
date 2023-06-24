
#example
Func_description = "2*n+3 sequence"
Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
Sys.setenv(GPT_MODEL = "gpt-3.5-turbo-16k")


createFunction4R <- function(Func_description,
                             api_key,
                             packages="base",
                             correction_number=2,
                             roxygen=TRUE,
                             Rscript=TRUE){

#テンプレートの作成
template1 = "
Computer language: R
Packages used: %s
Deliverables: R Script text only

You are a great assistant.
I will give you the function overview to create in this project.
Please complete the following required fields
Function description: a R function to perform %s
Language used in the script: {Computer language}
Packages used for the function: {Packages used}
Deliverables you will output: {Deliverables}
"

#引数をプロンプトに代入する
template1s <- sprintf(template1, packages, Func_description)

#01 Run function creation
cat("01 Run function creation \n")
f <- chat4R(content = template1s,
       api_key = Sys.getenv("OPENAI_API_KEY"),
       Model = Sys.getenv("GPT_MODEL"),
       temperature = 1,
       simple = TRUE)






}



二回
改善
何回改善するか選べる

結果の関数を出力する

rだと、rオキシゲンを入れられる

改行のところは改行記号を入れてと

rファイルで出力できる

このような実行関数を作成する

iPhoneから送信
