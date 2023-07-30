#' Conversation for R
#'
#' This function manages a conversation with OpenAI's GPT model.
#'
#' @title Conversation for R
#' @description This function uses the OpenAI API to manage a conversation with the specified model.
#' @param message The message to send to the model. Must be a string.
#' @param api_key A string. Your OpenAI API key. Defaults to the value of the environment variable "OPENAI_API_KEY".
#' @param template1 The initial template for the conversation. Must be a string. Default is an empty string.
#' @param ConversationBufferWindowMemory_k The number of previous messages to keep in memory.
#'    Must be a positive integer. Default is 2.
#' @param Model The model to use for the chat completion. Must be a string. Default is "gpt-3.5-turbo-16k".
#' @param initialization Whether to initialize the chat history. Must be a logical value. Default is FALSE.
#' @param output Whether to return the output. Must be a logical value. Default is FALSE.
#' @importFrom httr add_headers POST content
#' @importFrom jsonlite toJSON
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @return A string containing the conversation history.
#' @export conversation4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' message <- "Hello, how are you?"
#' api_key <- "your_api_key"
#' conversation4R(message, api_key = api_key)
#' }

conversation4R <- function(message,
                           api_key = Sys.getenv("OPENAI_API_KEY"),
                           template1 = "",
                           ConversationBufferWindowMemory_k = 2,
                           Model = "gpt-3.5-turbo-16k",
                           initialization = FALSE,
                           output = FALSE){

# Assertions to verify the types of the input parameters
assertthat::assert_that(assertthat::is.string(message))
assertthat::assert_that(assertthat::is.string(api_key))
assertthat::assert_that(assertthat::is.string(template1))
assertthat::assert_that(assertthat::is.count(ConversationBufferWindowMemory_k))
assertthat::assert_that(assertthat::is.string(Model))
assertthat::assert_that(assertthat::is.flag(initialization))
assertthat::assert_that(assertthat::is.flag(output))

# Initialization
if(!exists("chat_history")){
  chat_history <<- new.env()
  chat_history$history <- c()
} else {
  if(initialization){
    chat_history <<- new.env()
    chat_history$history <- c()
  }
}

# Define
temperature = 1

# Prompt Template
if(template1 == ""){
  template1 = "You are an excellent assistant.\nPlease reply in Japanese."
}

template2 = "
History:%s"

template3 = "
 Human: %s"

template4 = "
 Assistant: %s"

if(identical(as.character(chat_history$history), character(0))){

res <- chatAI4R::chat4R(content=message,
              api_key=api_key,
              Model = Model,
              temperature = temperature)

template3s <- sprintf(template3, message)
template4s <- sprintf(template4, res$choices.message.content)

chat_history$history <- list(
  list(role = "system", content = template1),
  list(role = "user", content = message),
  list(role = "assistant", content = res$choices.message.content)
)

out <- c(template1,
         crayon::red(template3s),
         crayon::blue(template4s))

if(output){
  return(res)
}else{
  return(cat(out))
}

}

if(!identical(as.character(chat_history$history), character(0))){

if(length(chat_history$history) > ConversationBufferWindowMemory_k*2 + 1){
  chat_historyR <- chat_history$history[(length(chat_history)-1):length(chat_history)]
}else{
  chat_historyR <- chat_history$history
}


new_conversation <- list(list(role = "user", content = message))
chat_historyR <- c(chat_historyR, new_conversation)

# Run
res <- chatAI4R::chat4R_history(history = chat_historyR,
               api_key = api_key,
               Model = Model,
               temperature = temperature)

assistant_conversation<- list(list(role = "assistant", content = res$choices.message.content))
chat_historyR <- c(chat_historyR, assistant_conversation)

rr <- c()
for(n in 2:length(chat_history$history)){
r <- switch(chat_history$history[[n]]$role,
                 "system" = paste0("System: ", chat_history$history[[n]]$content),
                 "user" = paste0("\nHuman: ", chat_history$history[[n]]$content),
                 "assistant" = paste0("\nAssistant: ", chat_history$history[[n]]$content))
rr <- c(rr, r)
}

template2s <- sprintf(template2, paste0(rr, collapse = ""))

out <- c(template1,
         template2s,
         crayon::red(sprintf(template3, new_conversation[[1]]$content)),
         crayon::blue(sprintf(template4, assistant_conversation[[1]]$content)))

chat_history$history <<- chat_historyR

if(output){
  return(res)
}else{
  return(cat(out))
}

}
}

