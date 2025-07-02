#' Conversation Interface for R with OpenAI
#'
#' This function provides an interface to communicate with OpenAI's models using R. It maintains a conversation history and allows for initialization of a new conversation.
#'
#' @title Conversation Interface for R
#' @description Interface to communicate with OpenAI's models using R, maintaining a conversation history and allowing for initialization of a new conversation.
#' @param message A string containing the message to be sent to the model.
#' @param api_key A string containing the OpenAI API key. Default is retrieved from the system environment variable "OPENAI_API_KEY".
#' @param system_set A string containing the system_set for the conversation. Default is an empty string.
#' @param ConversationBufferWindowMemory_k An integer representing the conversation buffer window memory. Default is 2.
#' @param Model A string representing the model to be used. Default is "gpt-4o-mini".
#' @param language A string representing the language to be used in the conversation. Default is "English".
#' @param initialization A logical flag to initialize a new conversation. Default is FALSE.
#' @param verbose A logical flag to print the conversation. Default is TRUE.
#' @importFrom assertthat assert_that is.string is.count is.flag
#' @importFrom crayon red blue
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
                           system_set = "",
                           ConversationBufferWindowMemory_k = 2,
                           Model = "gpt-4o-mini",
                           language = "English",
                           initialization = FALSE,
                           verbose = TRUE){

# Assertions to verify the types of the input parameters
assertthat::assert_that(assertthat::is.string(message))
assertthat::assert_that(assertthat::is.string(api_key))
assertthat::assert_that(assertthat::is.string(system_set))
assertthat::assert_that(assertthat::is.count(ConversationBufferWindowMemory_k))
assertthat::assert_that(assertthat::is.flag(initialization))

# Initialization - use global environment to persist chat_history
if(!exists("chat_history", envir = .GlobalEnv) || initialization){
  chat_history <- new.env()
  chat_history$history <- list()
  assign("chat_history", chat_history, envir = .GlobalEnv)
} else {
  chat_history <- get("chat_history", envir = .GlobalEnv)
}

# Define
temperature = 1

# Prompt system_set
if(system_set == ""){
  system_set = paste0("You are an excellent assistant. Please reply in ", language, ".")
}

system_set2 = "
History:%s"

system_set3 = "
Human: %s"

system_set4 = "
Assistant: %s"

if(length(chat_history$history) == 0){

chat_historyR <- list(
  list(role = "system", content = system_set),
  list(role = "user", content = message))

# Run with safe error handling
res_df <- tryCatch({
  chatAI4R::chat4R_history(history = chat_historyR,
                          api_key = api_key,
                          Model = Model,
                          temperature = temperature)
}, error = function(e) {
  stop("Failed to get response from chat4R_history: ", e$message, call. = FALSE)
})

# Extract content from data.frame and validate response
if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) || 
    is.null(res_df$content) || length(res_df$content) == 0 || nchar(trimws(res_df$content)) == 0) {
  stop("Invalid or empty response from chat4R_history", call. = FALSE)
}

res <- as.character(res_df$content)


system_set3s <- sprintf(system_set3, message)
system_set4s <- sprintf(system_set4, res)

chat_history$history <- list(
  list(role = "system", content = system_set),
  list(role = "user", content = message),
  list(role = "assistant", content = res)
)

# Save to global environment
assign("chat_history", chat_history, envir = .GlobalEnv)

out <- c(paste0("System: ", system_set),
         crayon::red(system_set3s),
         crayon::blue(system_set4s))

if(verbose){
  cat(out)
}

}else{

# Handle continuing conversation (chat_history exists and has content)

if(length(chat_history$history) > ConversationBufferWindowMemory_k*2 + 1){
  # Keep system message + last k pairs of user/assistant messages
  start_idx <- length(chat_history$history) - (ConversationBufferWindowMemory_k*2)
  chat_historyR <- c(chat_history$history[1], chat_history$history[start_idx:length(chat_history$history)])
}else{
  chat_historyR <- chat_history$history
}


new_conversation <- list(list(role = "user", content = message))
chat_historyR <- c(chat_historyR, new_conversation)

# Run with safe error handling
res_df <- tryCatch({
  chatAI4R::chat4R_history(history = chat_historyR,
                          api_key = api_key,
                          Model = Model,
                          temperature = temperature)
}, error = function(e) {
  stop("Failed to get response from chat4R_history: ", e$message, call. = FALSE)
})

# Extract content from data.frame and validate response
if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) || 
    is.null(res_df$content) || length(res_df$content) == 0 || nchar(trimws(res_df$content)) == 0) {
  stop("Invalid or empty response from chat4R_history", call. = FALSE)
}

res <- as.character(res_df$content)

assistant_conversation<- list(list(role = "assistant", content = res))
chat_historyR <- c(chat_historyR, assistant_conversation)

# Update the global chat_history with new conversation
chat_history$history <- chat_historyR

# Generate display history from updated chat_history (excluding current exchange)
rr <- c()
if(length(chat_history$history) > 3) {  # More than system + current user + current assistant
  for(n in 2:(length(chat_history$history)-2)){  # Exclude current user/assistant pair
    # Safe access to history elements with null checks
    if (!is.null(chat_history$history[[n]]) && 
        !is.null(chat_history$history[[n]]$role) && 
        !is.null(chat_history$history[[n]]$content)) {
      
      r <- switch(chat_history$history[[n]]$role,
                   "system" = paste0("System: ", chat_history$history[[n]]$content),
                   "user" = paste0("\nHuman: ", chat_history$history[[n]]$content),
                   "assistant" = paste0("\nAssistant: ", chat_history$history[[n]]$content),
                   paste0("\nUnknown: ", chat_history$history[[n]]$content))  # fallback
      rr <- c(rr, r)
    }
  }
}

system_set2s <- sprintf(system_set2, paste0(rr, collapse = ""))

# Safe access to conversation elements with null checks
user_content <- if (!is.null(new_conversation[[1]]) && !is.null(new_conversation[[1]]$content)) {
  new_conversation[[1]]$content
} else {
  "Error: Missing user content"
}

assistant_content <- if (!is.null(assistant_conversation[[1]]) && !is.null(assistant_conversation[[1]]$content)) {
  assistant_conversation[[1]]$content
} else {
  "Error: Missing assistant content"
}

out <- c(paste0("System: ", system_set),
         system_set2s,
         crayon::red(sprintf(system_set3, user_content)),
         crayon::blue(sprintf(system_set4, assistant_content)))

# Save updated history to global environment
assign("chat_history", chat_history, envir = .GlobalEnv)

if(verbose){
  cat(out)
}

}
}
