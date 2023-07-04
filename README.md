# chatAI4R: Chat-based Artificial Intelligence for R

## Description

chatAI4R, chat-based Artificial Intelligence (AI) for R, is an R package designed to integrate the ChatGPT API and other APIs. This package aims to enable efficient data analysis and knowledge discovery based on a large language model (LLM)-based AI technique, ChatGPT. The package provides basic functions for the LLM usage and provides a set of functions capable of executing analysis methods for bioinformatics.

chatAI4R is an experimental effort that aims to build applications using the basic functions in the chatAI4R package, in addition to building R functions that implement various LLM functions. 

Bioinformatics解析への拡張性を考えて開発を進めています。

## About this project and future developments

- R language usage for AI API
  - OpenAI API (ChatGPT, Text embeddings)
  - DeepL API
- LLM-based technique for bioinformatics
  - Genome analysis, protein structure prediction, gene expression analysis
  - Automated Analysis: Analysis Design, Statistics, Data Visualization, Discussion, Question Answering
  - Linguistic modeling of technical texts: natural language question answering

## Installation of chatAI4R

1. Start R.app

2. Run the following commands in the R console.

```r
#CRAN-version (Not yet available)
install.packages("chatAI4R")
library(chatAI4R)

#Dev-version
devtools::install_github("kumeS/chatAI4R")
library(chatAI4R)
```

## R functions

### Basic functions

- chat4R: Interact with gpt-3.5-turbo-16k (default) using OpenAI API
- completions4R: Generate text using OpenAI's API
- textEmbedding:  Text Embedding from OpenAI API (model: text-embedding-ada-002)
- deepel: DeepL Translation Function

### Secondary Layer Functions

- chat4R_history: This function retrieves the chat history from OpenAI's GPT-3.5-turbo model.
- conversation4R: This function manages a conversation with OpenAI's GPT-3.5-turbo model.
- createFunction4R: Generate and Improve R Functions
- longTextSummary: 

### Functions for RIKEN press release

- get_riken_pressrelease_urls: Get URLs of RIKEN Press Releases
- riken_pressrelease_text_jpn: Extract text from RIKEN press-release (Japanese)
- riken_pressrelease_textEmbedding: Extract text and perform text embedding from RIKEN press-release

## Simple usage

### One-Shot Chatting

All runs using the chat4R function are One-Shot Chatting.
Conversation history is not carried over to the next conversation.

```{r}
#Set your API key
Sys.setenv(OPENAI_API_KEY = "Your API key")

#API: "https://api.openai.com/v1/chat/completions"
chat4R("Hello")

#API: "https://api.openai.com/v1/completions"
completions4R("Hello")
```

### Few-Shots/Chain-Shots Chatting

Executions using the conversation4R function will keep a history of conversations.
The number of previous messages to keep in memory defaults to 2.

```{r}
#Set your API key
Sys.setenv(OPENAI_API_KEY = "Your API key")

#First shot
conversation4R("Hello")

#Second shot
conversation4R("Hello")
```

### Text Embedding

Converts input text to a numeric vector. The model text-embedding-ada-002 results in a vector of 1536 floats.

```{r}
#Set your API key
Sys.setenv(OPENAI_API_KEY = "Your API key")

#Embedding
textEmbedding("Hello, world!")
```

## Applied use of the chatAI4R package

- vignette: AI-based chatting loaded with professional documents (RIKEN Pressrelease text)

## License

Copyright (c) 2023 Satoshi Kume released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2023) chatAI4R: Chat-based Artificial Intelligence for R.

```
#BibTeX
@misc{Kume2023chatAI4R,
  title={chatAI4R: Chat-based Artificial Intelligence for R},
  author={Kume, Satoshi}, year={2023},
  publisher={GitHub}, note={R Package},
  howpublished={\url{https://github.com/kumeS/chatAI4R}},
}
```

## Contributors

- Satoshi Kume

