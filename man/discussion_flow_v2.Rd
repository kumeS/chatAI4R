% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/discussion_flow_v2.R
\name{discussion_flow_v2}
\alias{discussion_flow_v2}
\title{discussion_flow_v2: Interactions and Flow Control Between LLM-based Bots (LLBs)}
\usage{
discussion_flow_v2(
  issue,
  Domain = "bioinformatics",
  Model = "gpt-4-0613",
  api_key = Sys.getenv("OPENAI_API_KEY"),
  language = "English",
  Summary_nch = 50,
  Sentence_difficulty = 2,
  R_expert_setting = TRUE,
  verbose = TRUE,
  sayENorJA = TRUE,
  rep_x = 3
)
}
\arguments{
\item{issue}{The issue to be discussed. Example: "I want to solve linear programming and create a timetable."}

\item{Domain}{The domain of the discussion, default is "bioinformatics".}

\item{Model}{The LLM model to be used, default is "gpt-4-0613".}

\item{api_key}{The API key for OpenAI, default is retrieved from the system environment variable "OPENAI_API_KEY".}

\item{language}{The language for the discussion, default is "English".}

\item{Summary_nch}{The number of characters for the summary, default is 50.}

\item{Sentence_difficulty}{Numeric, the complexity level for sentence construction, default is 2.}

\item{R_expert_setting}{Logical, whether R expert settings are enabled, default is TRUE.}

\item{verbose}{Logical, whether to print verbose output, default is TRUE.}

\item{sayENorJA}{Logical, whether to speak in English or Japanese, default is TRUE. This feature is available on macOS systems only.}

\item{rep_x}{Numeric, a number of repeats for the conversations, default is 3.}
}
\value{
A summary of the conversation between the bots.
}
\description{
Simulates interactions and flow control between three different roles of LLM-based bots (LLBs).
}
\details{
Interactions and Flow Control Between LLM-based Bots (LLBs)

In the v2 model, we added a regulation of the difficulty of the sentence,
the human intervention in their conversation between LLM bots, and number of repetitions of conversation.
This function is described to simulate the interactions and flow control between
three different roles of LLM-based bots, abbreviated as LLBs, namely A (Beginner), B (Expert), and C (Peer Reviewer).
These roles have distinct functions and work together to facilitate more complex and meaningful discussions.
Here is a brief description of the roles:
A (Beginner): This bot generates questions and summaries based on the content of the discussion provided by the user.
B (Expert): This bot provides professional answers to questions posed by LLB A.
C (Peer Reviewer):  This bot reviews the dialog between LLB A and LLB B and suggests improvements or refinements.
The three parties independently call the OpenAI API according to their roles.
In addition, it keeps track of the conversation history between the bots and performs
processes such as questioning, answering, and peer review.
The function is designed to work in a "domain," which is essentially a specific area
or topic around which conversations revolve.
It is recommended to use GPT-4 or a model with higher accuracy than GPT-4.
English is recommended as the input language, but the review will also be conducted in Japanese, the native language of the author.
}
\examples{
\dontrun{
issue <-  "I want to solve linear programming and create a timetable."

#Run Discussion with the domain of bioinformatics
discussion_flow_v2(issue)
}
}
\author{
Satoshi Kume
}
