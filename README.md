# chatAI4R <img src="inst/figures/chatAI4R_logo.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN](https://www.r-pkg.org/badges/version/chatAI4R)](https://cran.r-project.org/web/packages/chatAI4R/index.html)
[![CRAN_latest_release_date](https://www.r-pkg.org/badges/last-release/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![CRAN](https://cranlogs.r-pkg.org/badges/grand-total/chatAI4R)](https://www.datasciencemeta.com/rpackages)
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

- LLM-assisted R Package Development
  - Package design, create R function, proofread English text, etc.

- LLM-Based Data Analysis and Integration (future developments)
  - Automated Analysis: Analysis Design, Statistics, Data Visualization, Discussion, Question Answering
  - Highly-technical texts modeling and natural language question answering
  - Bioinformatics analysis
  
***The functionality for interlanguage translation using DeepL has been separated as the 'deepRstudio' package. Functions related to text-to-image generation were separated as the 'stableDiffusion4R' package.***

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

# Release v0.2.3
devtools::install_github("kumeS/chatAI4R", ref = "v0.2.3")
library(chatAI4R)
```

#### Installation from source

```r
#For MacOS X, installation from source
system("wget https://github.com/kumeS/chatAI4R/archive/refs/tags/v0.2.3.tar.gz")
#or system("wget https://github.com/kumeS/chatAI4R/archive/refs/tags/v0.2.3.tar.gz --no-check-certificate")
system("R CMD INSTALL v0.2.3.tar.gz")
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

- [Roxygen2 (GPT-4 UI)](https://youtu.be/wTMZfLMXYH0?si=50aV1V_yv8_t-1zZ)

- [R / LLM demo (1) search R function and error message](https://youtu.be/O9QLMv1DJuY?si=3zcQPZmWzDkJedym) 

- [R / LLM demo (2) create R function](https://youtu.be/dIUkCqCS0Tw?si=xApdb9vJ9ILudqU7) 

- [R / LLM demo (3) Discussion among LLM Bots](https://youtu.be/qJTblkU0dI4?si=HyK_-LIUhzn-vFqu) 

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
|slow_print_v2|Slowly Print Text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/slow_print_v2.R)||
|ngsub|Remove Extra Spaces and Newline Characters|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/ngsub.R)||
|removeQuotations|Remove All Types of Quotations from Text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/removeQuotations.R)||

### Basic Secondary Layer Functions

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|conversation4R|Manage a conversation using a chatting history|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/conversation4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/conversation4R.png)|
|autocreateFunction4R|Generate and Improve R Functions (experimental)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/autocreateFunction4R.R)||
|revisedText|Revision for a scientific text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/revisedText.R)||

### Functions for R package developments

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|designPackage|Design Package for R|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/designPackage.R)||
|supportIdeaGeneration|Support Idea Generation from Selected Text or Clipboard Input|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/supportIdeaGeneration.R)||
|enrichTextContent|Enrich Text Content|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/enrichTextContent.R)||
|createSpecifications4R|Create Specifications for R Function|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createSpecifications4R.R)||
|createRcode|Create R Code from Clipboard Content and Output into the R Console|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createRcode.R)||
|createRfunction|Create R Function from Selected Text or Clipboard Content |[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createRfunction.R)||
|convertRscript2Function|Convert Selected R Script to R Function|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertRscript2Function.R)||
|OptimizeRcode|Optimize and Complete R Code|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/OptimizeRcode.R)||
|addCommentCode|Add Comments to R Code|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/addCommentCode.R)||
|addRoxygenDescription|Add Roxygen Description to R Function|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/addRoxygenDescription.R)||
|proofreadEnglishText|Proofread English Text During R Package Development via RStudio API|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/proofreadEnglishText.R)||
|checkErrorDet|Check Error Details|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet.R)||
|checkErrorDet_JP|Check Error Details in Japanese via RStudio API|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet_JP.R)||
|convertScientificLiterature|Convert to Scientific Literature|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertScientificLiterature.R)||
|searchFunction|Search the R function based on the provided text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/searchFunction.R)||

### Functions for Text Summary

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|TextSummary| Summarize a long text (experimental)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummary.R)||
|summaryWebScrapingText|Summarize Text via Web Scraping of Google Search|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/summaryWebScrapingText.R)||
|TextSummaryAsBullet|Summarize Selected Text into Bullet Points|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummaryAsBullet.R)||
|convertBullet2Sentence|Convert Bullet Points to Sentences|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertBullet2Sentence.R)||
|chatAI4pdf|Summarize PDF Text via LLM|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chatAI4pdf.R)||
|extractKeywords|Extract Keywords from Text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/extractKeywords.R)||

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
