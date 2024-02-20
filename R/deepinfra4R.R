R Function for Deepinfra APIs

この関数は、Deepinfra APIsを使った実行をサポートします。
Llama-2、CodeLlama、PhindなどをDeepinfraのAPIを使って実行します。

使用前に、`Sys.setenv(DEEPINFRA_API_KEY = "Your API key")`を定義してください。
prompt: string, text to generate from


Parameter_Setting
max_new_tokens: integer, default value is 512, maximum length of the newly generated generated text.
temperature: number, default value is 0.7, temperature to use for sampling

top_p: number, default value is 0.9, Sample from the set of tokens with highest probability such that sum of probabilies is higher than p.






deepinfra4R <- function(prompt,
                   Model = "Phind/Phind-CodeLlama-34B-v2",
                   Parameter_Setting,
                   simple = TRUE,
                   fromJSON_parsed = FALSE
                   ) {

  # Define parameters
  api_base_url <- "https://api.deepinfra.com/v1/inference/"
  n <- 1
  top_p <- 1
  api_key = Sys.getenv("DEEPINFRA_API_KEY")

  #Check prompt
  if(prompt == ""){
    return(message("Bad Request: parameter is emput"))
    }

  # Configure headers for the API request
  headers <- httr::add_headers(`Content-Type` = "application/json",
                      `Authorization` = paste("Bearer", api_key))

  # Define the body of the API request
  if(Model == "Phind/Phind-CodeLlama-34B-v2"){
    api_base_url <- paste0(api_base_url, "/", Model)

    DefaultParameters <- c(max_new_tokens = 512,
                       temperature = 0.7,
                       top_p = 0.9,
                       top_k = 0,
                       repetition_penalty = 1,
                       num_responses = 1,
                       frequency_penalty = 0
                       )

    if(any(names(Parameter_Setting) == "max_new_tokens")){
      DefaultParameters["max_new_tokens"] <- Parameter_Setting["max_new_tokens"]
    }

    body <- list(
      input = prompt,
      temperature = temperature,
      top_p = top_p,
      n = n)
  }

#Non-options
#stop: Up to 16 strings that will terminate generation immediately
#webhook: The webhook to call when inference is done, by default you will get the output in the response of your inference request
#stream: Whether to stream tokens, by default it will be false, currently only supported for Llama 2 text generation models, token by token updates will be sent over SSE


  # Send a POST request to the OpenAI server
  response <- httr::POST(url = api_url,
                         body = jsonlite::toJSON(body, auto_unbox = TRUE),
                         encode = "json", config = headers)

  # Extract and return the response content
  if(simple){
   return(data.frame(content=httr::content(response, "parsed")$choices[[1]]$message$content))
  }else{
  if(fromJSON_parsed){
    raw_content <- httr::content(response, "raw")
    char_content <- rawToChar(raw_content)
    parsed_data <- jsonlite::fromJSON(char_content)
    return(parsed_data)
  }else{
    return(data.frame(httr::content(response, "parsed")))
  }
  }
}
