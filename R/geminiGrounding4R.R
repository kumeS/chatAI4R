#' Gemini API Google Search Grounding Request (v1/v1beta, 2025-07)
#'
#' A thin R wrapper for Google Gemini API with Google Search grounding enabled.
#' Grounding improves factuality by incorporating web search results.
#'
#' @param mode        One of `"text"`, `"stream_text"`, `"chat"`, `"stream_chat"`.
#' @param contents    Character vector (single-turn) or list of message objects
#'                    (chat modes). See Examples.
#' @param model       Gemini model ID. Default `"gemini-2.5-flash"`.
#' @param api_version API version for the Generative Language API (`"v1"` or `"v1beta"`). Default `"v1beta"`.
#' @param store_history Logical. If TRUE, chat history is persisted to the
#'                      `chat_history` env-var (JSON).
#' @param dynamic_threshold Numeric [0,1] for dynamic retrieval threshold (default: 0.7). Only used for Gemini 1.5 models with `googleSearchRetrieval`; ignored for newer models that use `google_search`.
#' @param api_key     Your Google Gemini API key (default: `Sys.getenv("GoogleGemini_API_KEY")`).
#' @param max_tokens  Maximum output tokens. Default 2048.
#' @param debug       Logical. If TRUE, prints request details for debugging.
#' @param enable_grounding Logical. If TRUE, enables Google Search grounding (default).
#' @param ...         Additional `httr::POST` options (timeouts etc.).
#'
#' @return For non-stream modes, a parsed list. For stream modes, a list with
#'         `full_text` and `chunks`.
#'
#' @author Satoshi Kume (revised 2025-07-01)
#' @export geminiGrounding4R
#'
#' @examples
#' \dontrun{
#'   # Synchronous text generation with grounding:
#'   result <- geminiGrounding4R(
#'     mode = "text",
#'     contents = "What is the current Google stock price?",
#'     store_history = FALSE,
#'     debug = TRUE,  # Enable debug to see request details
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(result)
#'
#'   # Basic text generation without grounding (for troubleshooting):
#'   basic_result <- geminiGrounding4R(
#'     mode = "text",
#'     contents = "Hello, how are you?",
#'     enable_grounding = FALSE,
#'     debug = TRUE,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(basic_result)
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
#'     dynamic_threshold = 0.7,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(chat_result)
#'
#'   # Streaming text generation:
#'   stream_result <- geminiGrounding4R(
#'     mode = "stream_text",
#'     contents = "Tell me a story about a magic backpack.",
#'     store_history = FALSE,
#'     dynamic_threshold = 0.7,
#'     api_key = Sys.getenv("GoogleGemini_API_KEY")
#'   )
#'   print(stream_result$full_text)
#' }

geminiGrounding4R <- function(mode,
                               contents,
                               model             = "gemini-2.5-flash",
                               api_version       = "v1beta",
                               store_history     = FALSE,
                               dynamic_threshold = 0.7,
                               api_key           = Sys.getenv("GoogleGemini_API_KEY"),
                               max_tokens        = 2048,
                               debug             = FALSE,
                               enable_grounding  = TRUE,
                               ...) {

  # Input validation
  if (is.null(api_key) || nchar(api_key) == 0) {
    stop("API key is required. Set GoogleGemini_API_KEY environment variable or provide api_key parameter.", call. = FALSE)
  }

  mode <- tolower(mode)
  valid_modes <- c("text", "stream_text", "chat", "stream_chat")
  if (!mode %in% valid_modes)
    stop("Invalid mode. Choose one of: ", paste(valid_modes, collapse = ", "), call. = FALSE)

  api_version <- tolower(api_version)
  if (!api_version %in% c("v1", "v1beta")) {
    stop('api_version must be "v1" or "v1beta".', call. = FALSE)
  }

  #----- Build endpoint --------------------------------------------------------
  method   <- if (grepl("^stream", mode)) "streamGenerateContent" else "generateContent"
  endpoint <- sprintf(
    "https://generativelanguage.googleapis.com/%s/models/%s:%s",
    api_version, model, method
  )
  if (grepl("^stream", mode))
    endpoint <- paste0(endpoint, "?alt=sse")  # SSE required for streaming

  #----- Construct request body ------------------------------------------------
  make_message <- function(role, text) {
    list(role = role,
         parts = list(list(text = text)))
  }

  empty_object <- function() {
    x <- list()
    names(x) <- character(0)
    x
  }

  # Grounding tool selection (Gemini 1.5 uses googleSearchRetrieval; Gemini 2/3 use google_search)
  build_grounding_tools <- function(model, dynamic_threshold, debug = FALSE) {
    if (!enable_grounding) return(NULL)

    # Validate threshold only if supplied
    if (!is.null(dynamic_threshold)) {
      if (!is.numeric(dynamic_threshold) || length(dynamic_threshold) != 1 ||
          is.na(dynamic_threshold) || dynamic_threshold < 0 || dynamic_threshold > 1) {
        stop("dynamic_threshold must be a single numeric value between 0 and 1.", call. = FALSE)
      }
    }

    # Gemini 1.5 supports googleSearchRetrieval (with dynamic threshold)
    if (grepl("1\\.5", model)) {
      dt <- if (is.null(dynamic_threshold)) 0.7 else as.numeric(dynamic_threshold)
      return(list(
        list(
          googleSearchRetrieval = list(
            dynamicRetrievalConfig = list(
              mode = "MODE_DYNAMIC",
              dynamicThreshold = dt
            )
          )
        )
      ))
    }

    # Gemini 2.x/3.x: use google_search (dynamic threshold not supported in public Developer API)
    if (!is.null(dynamic_threshold) && debug) {
      message("dynamic_threshold is ignored for google_search on this model.")
    }
    list(list(google_search = empty_object()))
  }

  body <- switch(
    mode,
    "text" = list(
      contents = list(make_message("user", contents))
    ),
    "stream_text" = list(
      contents = list(make_message("user", contents))
    ),
    "chat" = list(
      contents = lapply(contents, \(m) make_message(m$role, m$text))
    ),
    "stream_chat" = list(
      contents = lapply(contents, \(m) make_message(m$role, m$text))
    )
  )

  # Add grounding tools if enabled
  tools <- build_grounding_tools(model, dynamic_threshold, debug)
  if (!is.null(tools)) {
    body$tools <- tools
  }

  if (!is.null(max_tokens))
    body$generationConfig <- list(maxOutputTokens = max_tokens)

  json_body <- jsonlite::toJSON(body, auto_unbox = TRUE)

  # Debug output
  if (debug) {
    cat("=== DEBUG: Request Body ===\n")
    cat(json_body)
    cat("\n=== DEBUG: Endpoint ===\n")
    cat(endpoint)
    cat("\n========================\n")
  }

  #---------------------------------------------------------------------------
  if (mode %in% c("text", "chat")) {        # ■ synchronous --------------------
    res <- httr::POST(
      url  = endpoint,
      body = json_body,
      encode = "json",
      httr::add_headers(
        "Content-Type" = "application/json",
        "x-goog-api-key" = api_key
      ),
      ...
    )
    if (httr::http_error(res)) {
      error_content <- httr::content(res, "text", encoding = "UTF-8")
      stop("HTTP error: ", httr::status_code(res), "\nResponse: ", error_content, call. = FALSE)
    }

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
    curl::handle_setheaders(
      h,
      "Content-Type" = "application/json",
      "x-goog-api-key" = api_key
    )
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
