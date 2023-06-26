% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conversation.R
\name{conversation4R}
\alias{conversation4R}
\title{Conversation for R}
\usage{
conversation4R(
  message,
  api_key,
  template1 = "",
  ConversationBufferWindowMemory_k = 2,
  Model = "gpt-3.5-turbo-16k",
  initialization = FALSE,
  output = FALSE
)
}
\arguments{
\item{message}{The message to send to the model.}

\item{api_key}{Your OpenAI API key.}

\item{template1}{The initial template for the conversation.}

\item{ConversationBufferWindowMemory_k}{The number of previous messages to keep in memory.}

\item{Model}{The model to use for the chat completion. Default is "gpt-3.5-turbo-16k".}

\item{initialization}{Whether to initialize the chat history.}

\item{output}{Whether to return the output.}
}
\value{
A string containing the conversation history.
}
\description{
This function uses the OpenAI API to manage a conversation with the specified model.
}
\details{
Conversation for R

This function manages a conversation with OpenAI's GPT-3.5-turbo model.
}
\examples{
\dontrun{
message <- "Hello, how are you?"
api_key <- "your_api_key"
conversation4R(message, api_key = api_key)
}
}
\author{
Satoshi Kume
}