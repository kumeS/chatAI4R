# chatAI4RBI: Chat-based Artificial Intelligence for R and Bioinformatics

## Description

Chat-based Artificial Intelligence (AI) for R and Bioinformatics, "chatAI4RBI," is an R package designed to integrate the ChatGPT API and other APIs with bioinformatics. This package aims to enable efficient data analysis and knowledge discovery based on a large language model (LLM)-based AI technique, ChatGPT. The package provides basic functions for the LLM usage and provides a set of functions capable of executing analysis methods for bioinformatics.

chatAI4RBI is an experimental effort that aims to build applications using the basic functions in the chatAI4RBI package, in addition to building R functions that implement various LLM functions. 

## About this project and future developments

- R language usage for AI API
  - OpenAI API (ChatGPT, Text embeddings)
  - DeepL API
- LLM-based technique for bioinformatics
  - Genome analysis, protein structure prediction, gene expression analysis
  - Automated Analysis: Analysis Design, Statistics, Data Visualization, Discussion, Question Answering
  - Linguistic modeling of technical texts: natural language question answering

## Installation of chatAI4RBI

1. Start R.app

2. Run the following commands in the R console.

```r
#CRAN-version (Not yet available)
install.packages("chatAI4RBI")
library(chatAI4RBI)

#Dev-version
devtools::install_github("kumeS/chatAI4RBI")
library(chatAI4RBI)
```

## Basic functions

- chat4R: Interact with gpt-3.5-turbo-16k (default) using OpenAI API
- textEmbedding: Text Embedding from OpenAI API (model: text-embedding-ada-002)
- deepel: DeepL Translation Function

## Secondary Layer Functions

- chat4R_history:
- conversation4R: 

## Task-specific functions

### Functions for RIKEN press release

- get_riken_pressrelease_urls:
- riken_pressrelease_text_jpn: 
- riken_pressrelease_textEmbedding:

## Simple usage

### One-Shot Chatting

All runs using the chat4R function are One-Shot Chatting.
Conversation history is not carried over to the next conversation.

```{r}
#Set your API key
api_key <- "Your API key"

#First
chat4R("Hello", api_key)

#Second
chat4R("Hello", api_key)
```

### Few-Shots/Chain-Shots Chatting

Executions using the conversation4R function will keep a history of conversations.
The number of previous messages to keep in memory defaults to 2.

```{r}
#Set your API key
api_key <- "Your API key"

#First shot
conversation4R("Hello", api_key)

#Second shot
conversation4R("Hello", api_key)
```

## Applied usage for bioinformatics

- vignette: AI-based chatting loaded with professional documents (RIKEN Pressrelease text)

## License

Copyright (c) 2023 Satoshi Kume released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2023) chatAI4RBI: Chat-based Artificial Intelligence for R and Bioinformatics.

```
#BibTeX
@misc{Kume2023chatAI4RBI,
  title={chatAI4RBI: Chat-based Artificial Intelligence for R and Bioinformatics},
  author={Kume, Satoshi}, year={2023},
  publisher={GitHub}, note={R Package},
  howpublished={\url{https://github.com/kumeS/chatAI4RBI}},
}
```

## Contributors

- Satoshi Kume

