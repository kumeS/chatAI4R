# Internal state helpers -----------------------------------------------------
#
# These helpers keep chat logs and cached data inside the package environment
# instead of writing to the global environment, which avoids R CMD check notes
# while still persisting state across function calls.

.chatAI4R_state <- new.env(parent = emptyenv())

.get_chat_history_env <- function() {
  if (!exists("chat_history", envir = .chatAI4R_state, inherits = FALSE)) {
    .reset_chat_history_env()
  }
  get("chat_history", envir = .chatAI4R_state, inherits = FALSE)
}

.reset_chat_history_env <- function() {
  chat_env <- new.env(parent = emptyenv())
  chat_env$history <- list()
  assign("chat_history", chat_env, envir = .chatAI4R_state)
  chat_env
}

.get_cache_env <- function() {
  .chatAI4R_state
}
