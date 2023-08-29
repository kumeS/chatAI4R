# chatAI4R <img src="inst/figures/chatAI4R_logo.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN](https://www.r-pkg.org/badges/version/chatAI4R)](https://cran.r-project.org/web/packages/chatAI4R/index.html)
[![CRAN_latest_release_date](https://www.r-pkg.org/badges/last-release/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![CRAN](https://cranlogs.r-pkg.org/badges/grand-total/chatAI4R)](http://www.datasciencemeta.com/rpackages)
[![CRAN downloads last month](http://cranlogs.r-pkg.org/badges/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![CRAN downloads last week](http://cranlogs.r-pkg.org/badges/last-week/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![:total status badge](https://kumes.r-universe.dev/badges/:total)](https://kumes.r-universe.dev)
[![chatAI4R status badge](https://kumes.r-universe.dev/badges/chatAI4R)](https://kumes.r-universe.dev)
<!-- badges: end -->

[GitHub/chatAI4R](https://github.com/kumeS/chatAI4R)

## Description

**chatAI4R**, **Chat-based Interactive Artificial Intelligence for R**, is an R package designed to integrate the OpenAI API and other APIs for artificial intelligence (AI) applications. This package leverages large language model (LLM)-based AI techniques, enabling efficient knowledge discovery and data analysis. chatAI4R provides basic R functions for using LLM and a set of R functions to support the creation of prompts for using LLM. The LLMs allow us to extend the world of R. Additionally, I strongly believe that the LLM is becoming so generalized that "Are you searching Google?" is likely to evolve into "Are you LLMing?".

chatAI4R is an experimental project aimed at developing and implementing various LLM applications in R. Furthermore, the package is under continuous development with a focus on extending its capabilities for bioinformatics analysis.

## About this project and future developments

- AI integration with R
  - [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) (ChatGPT, GPT-3.5, GPT-4, text embeddings)

- AI-assisted package development
  - Package design, create R function, proofread English text, etc.

- LLM-based data analysis (future developments)
  - Automated Analysis: Analysis Design, Statistics, Data Visualization, Discussion, Question Answering
  - Highly-technical texts modeling and natural language question answering
  - Bioinformatics analysis
  
**The functionality for interlanguage translation using DeepL has been separated as the 'deepRstudio' package.**

**Functions related to text-to-image generation were separated as the 'stableDiffusion4R' package.**

## Installation of the chatAI4R package

### 1. Start R / RStudio console.

### 2. Run the following commands in the R console:

#### CRAN-version installation

```r
# CRAN-version installation
install.packages("chatAI4R")
library(chatAI4R)
```

#### Dev-version installation (Recommended)

```r
# Dev-version installation
devtools::install_github("kumeS/chatAI4R")
library(chatAI4R)
```

#### Installation from source

```r
#For MacOS X, installation from source
system("wget https://github.com/kumeS/chatAI4R/archive/refs/tags/v0.0.11.tar.gz")
system("R CMD INSTALL chatAI4R-0.0.11.tar.gz")
```

### 3. Set the API key according to each Web API.

For example, to obtain an OpenAI API key, please register as a member on the OpenAI website (https://platform.openai.com/account/api-keys) and obtain your API key.

```r
#Set your key for the OpenAI API
Sys.setenv(OPENAI_API_KEY = "Your API key")
```

Create an .Rprofile file in your home directory and add your API key (using the code above) into it.

```{r}
# Create a file
file.create("~/.Rprofile") 

# [MacOS X] Open the file and edit it
system(paste("open ~/.Rprofile"))
```

Note: Please be aware of newline character inconsistencies across different operating systems.

## Tutorial

### Basic usage

- [Usage of functions in the chatAI4R package](https://kumes.github.io/chatAI4R/inst/vignettes/HowToUse.html)

- [Some examples of use via Video tutorial](https://youtu.be/VJaltAS9Ef8)

###  Applied usage of the chatAI4R package

- AI-based chatting loaded with highly-technical documents (RIKEN Pressrelease text)

## Prompts for chatGPT / GPT-4

|File|Description|Prompt|
|:---|:---|:---:|
|create_flowcharts|A prompt to create a flowchart|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_flowcharts.txt)|
|create_roxygen2_v01|A prompt to create a roxygen2 description|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_roxygen2_v01.txt)|
|create_roxygen2_v02|A prompt to create a roxygen2 description|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_roxygen2_v02.txt)|
|edit_DESCRIPTION|A prompt to edit DESCRIPTION|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/edit_DESCRIPTION.txt)|
|Img2txt_prompt_v01|A prompt to create a i2i prompt|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/Img2txt_prompt_v01.txt)|
|Img2txt_prompt_v02|A prompt to create a i2i prompt|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/Img2txt_prompt_v02.txt)|


## R functions

Flowcharts of the R functions were created by GPT-4 + Skrive plugin.

### Basic functions

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|chat4R|Chat4R: Interact with GPT-3.5 (default) using OpenAI API (One-shot)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/chat4R.png)|
|chat4R_history|Use chat history for OpenAI's GPT model|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4R_history.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/chat4R_history.png)|
|completions4R|Generate text using OpenAI completions API (One-shot)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/completions4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/completions4R.png)|
|textEmbedding|Text Embedding from OpenAI Embeddings API (model: text-embedding-ada-002)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/textEmbedding.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/textEmbedding.png)|
|slow_print|Slowly Print Text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/slow_print.R)||


### Secondary Layer Functions

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|conversation4R|Manage a conversation using a chatting history|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/conversation4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/conversation4R.png)|
|createFunction4R|Generate and improve R functions (experimental)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createFunction4R.R)||
|TextSummary| Summarize a long text (experimental)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummary.R)||
|createRcode|Create R Code from Clipboard Content and Output into the R Console|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createRcode.R)||

### Functions for R package developments

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|proofreadEnglishText|Proofread English Text During R Package Development via RStudio API|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/proofreadEnglishText.R)||
|checkErrorDet|Check Error Details|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet.R)||
|checkErrorDet_JP|Check Error Details in Japanese via RStudio API|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet_JP.R)||

### Interactions and Flow Control Between LLM-based Bots (LLBs)

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|discussion_flow_v1|Simulates interactions and flow control between three different roles of LLM-based bots (LLBs)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/discussion_flow_v1.R)||


### Functions for RIKEN press release (future developments)

- get_riken_pressrelease_urls: Get URLs of RIKEN Press Releases
- riken_pressrelease_text_jpn: Extract text from RIKEN press-release (Japanese)
- riken_pressrelease_textEmbedding: Extract text and perform text embedding from RIKEN press-release

## Simple usage

### One-Shot Chatting

All runs using the chat4R function are One-Shot Chatting. Conversation history is not carried over to the next conversation.

```r
#API: "https://api.openai.com/v1/chat/completions"
chat4R("Hello")

#API: "https://api.openai.com/v1/completions"
completions4R("Hello")
```

### Few-Shots/Chain-Shots Chatting

Executions using the conversation4R function will keep a history of conversations. The number of previous messages to keep in memory defaults to 2.

```r
#First shot
conversation4R("Hello")

#Second shot
conversation4R("Hello")
```

### Text Embedding

Converts input text to a numeric vector. The model text-embedding-ada-002 results in a vector of 1536 floats.

```r
#Embedding
textEmbedding("Hello, world!")
```

## License

Copyright (c) 2023 Satoshi Kume. Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2023) chatAI4R: Chat-based Interactive Artificial Intelligence for R.

```
#BibTeX
@misc{Kume2023chatAI4R,
  title={chatAI4R: Chat-Based Interactive Artificial Intelligence for R},
  author={Kume, Satoshi}, year={2023},
  publisher={GitHub}, note={R Package},
  howpublished={\url{https://github.com/kumeS/chatAI4R}},
}
```

## Contributors

- Satoshi Kume
