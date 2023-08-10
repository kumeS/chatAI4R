#' Conversation Interface for R with OpenAI
#'
#' This function provides an interface to communicate with OpenAI's models using R. It maintains a conversation history and allows for initialization of a new conversation.
#'
#' @title Conversation Interface for R
#' @description Interface to communicate with OpenAI's models using R, maintaining a conversation history and allowing for initialization of a new conversation.
#' @param message A string containing the message to be sent to the model.
#' @param api_key A string containing the OpenAI API key. Default is retrieved from the system environment variable "OPENAI_API_KEY".
#' @param template A string containing the template for the conversation. Default is an empty string.
#' @param ConversationBufferWindowMemory_k An integer representing the conversation buffer window memory. Default is 2.
#' @param Model A string representing the model to be used. Default is "gpt-3.5-turbo-16k".
#' @param language A string representing the language to be used in the conversation. Default is "English".
#' @param initialization A logical flag to initialize a new conversation. Default is FALSE.
#' @param verbose A logical flag to print the conversation. Default is TRUE.
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @return Prints the conversation if verbose is TRUE. No return value.
#' @export conversation4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' conversation4R(message = "Hello, OpenAI!",
#'                api_key = "your_api_key_here",
#'                language = "English",
#'                initialization = TRUE)
#' }

conversation4R <- function(message,
                           api_key = Sys.getenv("OPENAI_API_KEY"),
                           template = "",
                           ConversationBufferWindowMemory_k = 2,
                           Model = "gpt-3.5-turbo-16k",
                           language = "English",
                           initialization = FALSE,
                           verbose = TRUE){

# Assertions to verify the types of the input parameters
assertthat::assert_that(assertthat::is.string(message))
assertthat::assert_that(assertthat::is.string(api_key))
assertthat::assert_that(assertthat::is.string(template))
assertthat::assert_that(assertthat::is.count(ConversationBufferWindowMemory_k))
assertthat::assert_that(assertthat::is.flag(initialization))

# Initialization
if(!exists("chat_history")){
chat_history <- new.env()
chat_history$history <- c()
} else {
if(initialization){
chat_history <- new.env()
chat_history$history <- c()
}}

# Define
temperature = 1

# Prompt Template
if(template == ""){
  template = paste0("You are an excellent assistant. Please reply in ", language, ".")
}

template2 = "
History:%s"

template3 = "
Human: %s"

template4 = "
Assistant: %s"

if(identical(as.character(chat_history$history), character(0))){

chat_historyR <- list(
  list(role = "system", content = template),
  list(role = "user", content = message))

# Run
res <- chatAI4R::chat4R_history(history = chat_historyR,
               api_key = api_key,
               Model = Model,
               temperature = temperature)


template3s <- sprintf(template3, message)
template4s <- sprintf(template4, res)

chat_history$history <- list(
  list(role = "system", content = template),
  list(role = "user", content = message),
  list(role = "assistant", content = res)
)

out <- c(paste0("System: ", template),
         crayon::red(template3s),
         crayon::blue(template4s))

if(verbose){
  cat(out)
}

}else{

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

assistant_conversation<- list(list(role = "assistant", content = res))
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

out <- c(paste0("System: ", template),
         template2s,
         crayon::red(sprintf(template3, new_conversation[[1]]$content)),
         crayon::blue(sprintf(template4, assistant_conversation[[1]]$content)))

chat_history$history <- chat_historyR

if(verbose){
  cat(out)
}

}
}
}
