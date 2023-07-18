

generageImg2img_StableDiffusion4R <- function(
    text_prompts = "",
    negative_prompts = "",
    weight = 0.5,
    height = 512, width = 512,
    number_of_images = 1,
    steps = 15,
    cfg_scale = 7 ,
    clip_guidance_preset = "NONE",
    api_host = "https://api.stability.ai",
    api_key = Sys.getenv("DreamStudio_API_KEY")) {

  #contentが空ならストップ
  if(text_prompts == "") {
    warning("No input provided.")
    stop()
  }

  # APIのエンドポイントとヘッダーを設定
  engine_id <- "stable-diffusion-512-v2-1"
  uri <- paste0(api_host, "/v1/generation/", engine_id, "/text-to-image")

  #ヘッダーの作成
  headers <- httr::add_headers(
    "Content-Type" = "application/json",
    "Accept" = "application/json",
    "Authorization" = paste0("Bearer ", api_key)
  )

  # 画像生成に必要なプロンプトやパラメータを設定
  payload <- list(
    "text_prompts" = list(
      list("text" = text_prompts,
           "weight" = weight)
    ),
    negative_prompts = list(
      list("text" = negative_prompts)
    ),
    "cfg_scale" = cfg_scale,
    "clip_guidance_preset" = clip_guidance_preset,
    "height" = height,
    "width" = width,
    "samples" = number_of_images,
    "steps" = steps
  )

  #空のlistの定義
  result <- list()

  #stable diffusion modelで画像生成
  for (i in seq_len(number_of_images)) {

    #実行状況
    #i <- 1
    cat("Generate", i, "image\n")

    # リクエストを送信する
    response <- httr::POST(uri,
                           body = payload,
                           encode = "json",
                           config = headers)

    # レスポンスのステータスコードを確認
    if (httr::http_status(response)$category != "Success") {
      stop("Non-200 response: ", httr::content(response, "text"))
    }

    #JSONをパース
    image_data <- jsonlite::fromJSON(httr::content(response, "text"))

    # Base64エンコードされた文字列をバイナリデータにデコードし、そのバイナリデータをreadPNG関数でPNG画像として読み込む
    decode_image <- png::readPNG(base64enc::base64decode(image_data$artifacts$base64))
    #str(decode_image)

    #EBImageオブジェクトに変換する
    Img <- EBImage::rotate(EBImage::Image(decode_image, colormode = 'Color' ), angle=90)
    #str(Img)
    #range(Img)
    result[[i]] <- Img
  }
}

