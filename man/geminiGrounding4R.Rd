% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geminiGrounding4R.R
\name{geminiGrounding4R}
\alias{geminiGrounding4R}
\title{Gemini API Google Search Grounding Request Function}
\usage{
geminiGrounding4R(
  mode,
  contents,
  store_history = FALSE,
  dynamic_threshold = 1,
  api_key,
  ...
)
}
\arguments{
\item{mode}{A character string specifying the mode. Valid values are "text", "stream_text", "chat", "stream_chat".}

\item{contents}{For "text" or "stream_text" modes, a character string with the input text.
For "chat" or "stream_chat" modes, a list of messages. Each message is a list with fields:
\code{role} (e.g., "user" or "model") and \code{text} (the message content).}

\item{store_history}{Logical. If TRUE in chat mode, the chat history is stored in the environment
variable "chat_history" as a JSON string.}

\item{dynamic_threshold}{A numeric value [0,1] specifying the dynamic retrieval threshold.
The default is 1, meaning grounding is always applied.}

\item{api_key}{A character string containing your Gemini API key.}

\item{...}{Additional options passed to the HTTP request.}
}
\value{
For synchronous modes ("text", "chat"), a parsed JSON object is returned.
  For streaming modes ("stream_text", "stream_chat"), a list with \code{full_text} (combined output)
  and \code{chunks} (individual text pieces) is returned.
}
\description{
This function sends a request to the Gemini API with Google Search grounding enabled.
Grounding improves the factuality of the answer by incorporating the latest web search results.
}
\examples{
\dontrun{
  # Synchronous text generation with grounding:
  result <- geminiGrounding4R(
    mode = "text",
    contents = "What is the current Google stock price?",
    store_history = FALSE,
    dynamic_threshold = 1,
    api_key = Sys.getenv("GoogleGemini_API_KEY")
  )
  print(result)

  # Chat mode with history storage:
  chat_history <- list(
    list(role = "user", text = "Hello"),
    list(role = "model", text = "Hi there! How can I help you?")
  )
  chat_result <- geminiGrounding4R(
    mode = "chat",
    contents = chat_history,
    store_history = TRUE,
    dynamic_threshold = 1,
    api_key = Sys.getenv("GoogleGemini_API_KEY")
  )
  print(chat_result)

  # Streaming text generation:
  stream_result <- geminiGrounding4R(
    mode = "stream_text",
    contents = "Tell me a story about a magic backpack.",
    store_history = FALSE,
    dynamic_threshold = 1,
    api_key = Sys.getenv("GoogleGemini_API_KEY")
  )
  print(stream_result$full_text)
}
}
\author{
Satoshi Kume
}
