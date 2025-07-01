#' Gemini API Google Search Grounding Request (v1beta, 2025-07)
#'
#' A thin R wrapper for Google Gemini API with Google Search grounding enabled.
#' Grounding improves factuality by incorporating web search results.
#'
#' @param mode        One of `"text"`, `"stream_text"`, `"chat"`, `"stream_chat"`.
#' @param contents    Character vector (single-turn) or list of message objects
#'                    (chat modes). See Examples.
#' @param model       Gemini model ID. Default `"gemini-2.0-flash"`.
#' @param store_history Logical. If TRUE, chat history is persisted to the
#'                      `chat_history` env-var (JSON).
#' @param dynamic_threshold Numeric [0,1] for dynamic retrieval threshold (default: 1).
#' @param api_key     Your Google Gemini API key (default: `Sys.getenv("GoogleGemini_API_KEY")`).
#' @param max_tokens  Maximum output tokens. NULL for server default.
#' @param ...         Additional `httr::POST` options (timeouts etc.).
#'
#' @return For non-stream modes, a parsed list. For stream modes, a list with
#'         `full_text` and `chunks`.
#'
#' @author Satoshi Kume (revised 2025-07-01)
#' @export
#'
#' @examples
#' \dontrun{
#'   # Synchronous text generation with grounding:
#'   result <- geminiGrounding4R(
#'     mode = "text",
#'     contents = "What is the current Google stock price?",
#'     store_history = FALSE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(result)
#'
#'   # Chat mode with history storage:
#'   chat_history <- list(
#'     list(role = "user", text = "Hello"),
#'     list(role = "model", text = "Hi there! How can I help you?")
#'   )
#'   chat_result <- geminiGrounding4R(
#'     mode = "chat",
#'     contents = chat_history,
#'     store_history = TRUE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(chat_result)
#'
#'   # Streaming text generation:
#'   stream_result <- geminiGrounding4R(
#'     mode = "stream_text",
#'     contents = "Tell me a story about a magic backpack.",
#'     store_history = FALSE,
#'     dynamic_threshold = 1,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(stream_result$full_text)
#' }

geminiGrounding4R <- function(mode,
                               contents,
                               model             = "gemini-2.0-flash",
                               store_history     = FALSE,
                               dynamic_threshold = 1,
                               api_key           = Sys.getenv("GoogleGemini_API_KEY"),
                               max_tokens        = 2048,
                               ...) {

  mode <- tolower(mode)
  valid_modes <- c("text", "stream_text", "chat", "stream_chat")
  if (!mode %in% valid_modes)
    stop("Invalid mode. Choose one of: ", paste(valid_modes, collapse = ", "))

  #----- Build endpoint --------------------------------------------------------
  method   <- if (grepl("^stream", mode)) "streamGenerateContent" else "generateContent"
  endpoint <- sprintf(
    "https://generativelanguage.googleapis.com/v1beta/models/%s:%s?key=%s",
    model, method, api_key
  )
  if (grepl("^stream", mode))
    endpoint <- paste0(endpoint, "&alt=sse")  # SSE required for streaming

  #----- Construct request body ------------------------------------------------
  make_message <- function(role, text) {
    list(role = role,
         parts = list(list(text = text)))
  }

  # Google Search grounding tool configuration
  grounding_tool <- list(
    google_search_retrieval = list(
      dynamic_retrieval_config = list(
        mode = "MODE_DYNAMIC",
        dynamic_threshold = dynamic_threshold
      )
    )
  )

  body <- switch(
    mode,
    "text" = list(
      contents = list(make_message("user", contents)),
      tools = list(grounding_tool)
    ),
    "stream_text" = list(
      contents = list(make_message("user", contents)),
      tools = list(grounding_tool)
    ),
    "chat" = list(
      contents = lapply(contents, \(m) make_message(m$role, m$text)),
      tools = list(grounding_tool)
    ),
    "stream_chat" = list(
      contents = lapply(contents, \(m) make_message(m$role, m$text)),
      tools = list(grounding_tool)
    )
  )

  if (!is.null(max_tokens))
    body$generationConfig <- list(maxOutputTokens = max_tokens)

  json_body <- jsonlite::toJSON(body, auto_unbox = TRUE)

  #---------------------------------------------------------------------------
  if (mode %in% c("text", "chat")) {        # ■ synchronous --------------------
    res <- httr::POST(
      url  = endpoint,
      body = json_body,
      encode = "json",
      httr::add_headers("Content-Type" = "application/json"),
      ...
    )
    if (httr::http_error(res))
      stop("HTTP error: ", httr::status_code(res))

    parsed <- jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"),
                                 simplifyVector = FALSE)

    if (mode == "chat" && store_history) {
      prev <- Sys.getenv("chat_history")
      hist <- if (nzchar(prev)) jsonlite::fromJSON(prev, simplifyVector = FALSE) else list()
      Sys.setenv(chat_history = jsonlite::toJSON(c(hist, body$contents, parsed),
                                                 auto_unbox = TRUE))
    }
    return(parsed)
  }

  #---------------------------------------------------------------------------
  if (mode %in% c("stream_text", "stream_chat")) {   # ■ streaming --------------
    h <- curl::new_handle()
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    curl::handle_setopt(h, post = TRUE, postfields = json_body)

    acc <- character()

    cb <- function(raw, ...) {
      for (line in strsplit(rawToChar(raw), "\n")[[1]]) {
        line <- trimws(line)
        if (!nchar(line) || !startsWith(line, "data:")) next
        payload <- sub("^data:\\s*", "", line)
        if (payload == "[DONE]") next
        dat <- tryCatch(jsonlite::fromJSON(payload, simplifyVector = FALSE),
                        error = \(e) NULL)
        if (is.null(dat)) next

        # Extract incremental text
        new_txt <- unlist(lapply(dat$candidates, function(cand) {
          vapply(cand$content$parts, `[[`, "", "text")
        }), use.names = FALSE)
        if (length(new_txt))
          acc <<- c(acc, new_txt)

        if (mode == "stream_chat" && store_history) {
          prev <- Sys.getenv("chat_history")
          hist <- if (nzchar(prev)) jsonlite::fromJSON(prev, simplifyVector = FALSE) else list()
          Sys.setenv(chat_history = jsonlite::toJSON(c(hist, list(dat)),
                                                     auto_unbox = TRUE))
        }
      }
      length(raw)
    }

    curl::curl_fetch_stream(endpoint, cb, handle = h)
    list(full_text = paste(acc, collapse = ""), chunks = acc)
  }
}
