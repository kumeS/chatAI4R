% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/replicateAPI4R.R
\name{replicatellmAPI4R}
\alias{replicatellmAPI4R}
\title{replicatellmAPI4R: Interact with Replicate API for LLM models in R}
\usage{
replicatellmAPI4R(
  input,
  model_url,
  simple = TRUE,
  fetch_stream = FALSE,
  api_key = Sys.getenv("Replicate_API_KEY")
)
}
\arguments{
\item{input}{A list containing the API request body with parameters including prompt, max_tokens, top_k, top_p, min_tokens, temperature, system_prompt, presence_penalty, and frequency_penalty.}

\item{model_url}{A character string specifying the model endpoint URL (e.g., "/models/meta/meta-llama-3.1-405b-instruct/predictions").}

\item{simple}{A logical value indicating whether to return a simplified output (only the model output) if TRUE, or the full API response if FALSE. Default is TRUE.}

\item{fetch_stream}{A logical value indicating whether to fetch a streaming response. Default is FALSE.}

\item{api_key}{A character string representing the Replicate API key. Defaults to the environment variable "Replicate_API_KEY".}
}
\value{
If fetch_stream is FALSE, returns either a simplified output (if simple is TRUE) or the full API response. In streaming mode, outputs the response stream directly to the console.
}
\description{
This function interacts with the Replicate API (v1) to utilize language models (LLM) such as Llama. It sends a POST request with the provided input and handles both streaming and non-streaming responses.
}
\examples{
\dontrun{
  Sys.setenv(Replicate_API_KEY = "Your API key")
  input <- list(
    input = list(
      prompt = "What is the capital of France?",
      max_tokens = 1024,
      top_k = 50,
      top_p = 0.9,
      min_tokens = 0,
      temperature = 0.6,
      system_prompt = "You are a helpful assistant.",
      presence_penalty = 0,
      frequency_penalty = 0
    )
  )
  model_url <- "/models/meta/meta-llama-3.1-405b-instruct/predictions"
  response <- replicatellmAPI4R(input, model_url)
  print(response)
}

}
\author{
Satoshi Kume
}
