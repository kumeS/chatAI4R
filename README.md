# chatAI4R: Chat-based Artificial Intelligence for R

## Description

chatAI4R is an R package designed to integrate the ChatGPT API and other APIs for artificial intelligence (AI) applications. The package leverages a large language model (LLM)-based AI technique, ChatGPT, enabling efficient data analysis and knowledge discovery. chatAI4R provides basic functions for LLM usage and a set of functions for executing bioinformatics analysis methods.

chatAI4R is an experimental project that aims to build applications using its basic functions and to implement various LLM functions in R. The package is continuously being developed with a focus on extending its capabilities for bioinformatics analysis.

## About this project and future developments

- AI API integration with R
  - OpenAI API (ChatGPT, txt2img, text embeddings)
  - DeepL API
- LLM-based techniques for bioinformatics (future developments)
  - Automated Analysis: Analysis Design, Statistics, Data Visualization, Discussion, Question Answering
  - Linguistic modeling of technical texts: natural language question answering

## Installation of chatAI4R package

1. Start R.app

2. Run the following commands in the R console:

```r
# CRAN-version (Not yet available)
install.packages("BiocManager")
BiocManager::install("EBImage")

install.packages("chatAI4R")
library(chatAI4R)

# Dev-version
install.packages(c("devtools", "BiocManager"), repos="http://cran.r-project.org")
BiocManager::install("EBImage")

devtools::install_github("kumeS/chatAI4R")
library(chatAI4R)
```

3. Set the API key according to each Web API.

```r
#Set your key for the OpenAI API
Sys.setenv(OPENAI_API_KEY = "Your API key")

#Set your key for the DeepL API
Sys.setenv(DeepL_API_KEY = "Your API key")
```

## Tutorial

- [How to use the chatAI4R's functions]()

## R functions

### Basic functions

- chat4R: Interact with gpt-3.5-turbo-16k (default) using OpenAI API
- completions4R: Generate text using OpenAI's API
- textEmbedding: Extract text embeddings from OpenAI API (model: - text-embedding-ada-002)
- deepel: DeepL Translation Function

### Secondary Layer Functions

- chat4R_history: Retrieve chat history from OpenAI's GPT-3.5-turbo model
- conversation4R: Manage a conversation with OpenAI's GPT-3.5-turbo model
- createFunction4R: Generate and Improve R Functions
- longTextSummary: Function description is missing.


### Functions for RIKEN press release

- get_riken_pressrelease_urls: Get URLs of RIKEN Press Releases
- riken_pressrelease_text_jpn: Extract text from RIKEN press-release (Japanese)
- riken_pressrelease_textEmbedding: Extract text and perform text embedding from RIKEN press-release

## Simple usage

### One-Shot Chatting

All runs using the chat4R function are One-Shot Chatting. Conversation history is not carried over to the next conversation.

```{r}
#Set your API key
Sys.setenv(OPENAI_API_KEY = "Your API key")

#API: "https://api.openai.com/v1/chat/completions"
chat4R("Hello")

#API: "https://api.openai.com/v1/completions"
completions4R("Hello")
```

### Few-Shots/Chain-Shots Chatting

Executions using the conversation4R function will keep a history of conversations. The number of previous messages to keep in memory defaults to 2.


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

- Vignette: AI-based chatting loaded with professional documents (RIKEN Pressrelease text)


## License

Copyright (c) 2023 Satoshi Kume. Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

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
