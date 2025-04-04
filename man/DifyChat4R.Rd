% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DifyChat4R.R
\name{DifyChat4R}
\alias{DifyChat4R}
\title{DifyChat4R Function (Blocking Mode Only)}
\usage{
DifyChat4R(
  query,
  user = "abc-123",
  api_key = Sys.getenv("DIFY_API_KEY"),
  conversation_id = "",
  files = NULL,
  response_mode = "blocking",
  endpoint = "chat-messages"
)
}
\arguments{
\item{query}{A character string representing the user's input query.}

\item{user}{A character string representing the user identifier. Default is "abc-123".}

\item{api_key}{A character string for the Dify API secret key.
Defaults to the value of the environment variable "DIFY_API_KEY".}

\item{conversation_id}{A character string representing the conversation ID. Default is an empty string.}

\item{files}{A list of lists representing file information to be sent with the query. Default is NULL.
Each file should be a list containing at least the keys:
  - type (e.g., "image")
  - transfer_method (e.g., "remote_url")
  - url (the file URL)}

\item{response_mode}{A character string specifying the response mode. Default is "blocking".}

\item{endpoint}{A character string specifying which endpoint to use.
Valid values are "chat-messages" and "completion-messages". Default is "chat-messages".}
}
\value{
A list containing the parsed JSON response from the Dify API.
}
\description{
This function sends a chat query to the Dify API using blocking mode.
It allows switching between the "chat-messages" and "completion-messages" endpoints.
It returns the complete parsed JSON response from the API.
}
\examples{
\dontrun{
  # Set your Dify API key in the environment or pass it directly
  Sys.setenv(DIFY_API_KEY = "YOUR-DIFY-SECRET-KEY")

  # Use the chat-messages endpoint
  response_chat <- DifyChat4R(
    query = "Hello world via chat!",
    endpoint = "chat-messages"
  )
  print(response_chat)

  # Use the completion-messages endpoint
  response_completion <- DifyChat4R(
    query = "Hello world via completion!",
    endpoint = "completion-messages"
  )
  print(response_completion)
}

}
