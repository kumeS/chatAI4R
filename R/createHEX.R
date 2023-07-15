
provide a description for R package to create its Hex stickers

description = "hatAI4R provides a seamless interface for integrating OpenAI and other APIs into R."
p_nam = "R package"

res <- createHEX4R(description, p_nam)
Display(res)

createHEX4R <- function(description, package_name,  n = 3){

#プロンプトの作成
pr <- paste0('Generate one hexadecimal sticker as called "hex sticker" for the R package at the center of the output image using the following description: ',
       description)

#画像生成
res <-  generateImage4R(content = pr,
                        n = n,
                        size = "256x256",
                  response_format = "url",
                  Output_image = FALSE,
                  SaveImg = FALSE,
                  api_key = Sys.getenv("OPENAI_API_KEY"))


#Hex作成
img <- list()
for(k in seq_len(n)){
img[[k]] <-  hexSticker::sticker(res[k],
                         package = package_name,
                         p_y = 1.5, p_size=12,
                         s_x=1, s_y=.8, s_width=.5)
}

#結果を出力
return(img)

}

