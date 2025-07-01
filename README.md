# chatAI4R: Chat-Based Interactive Artificial Intelligence for R <img src="inst/figures/chatAI4R_logo.png" align="right" height="139" />

<!-- badges: start -->
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

- **Multi-API AI Integration with R**
  - [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) (ChatGPT, GPT-4, text embeddings, vision)
  - [Google Gemini API](https://ai.google.dev/) (Gemini models, search grounding)
  - [Replicate API](https://replicate.com/) (Llama, other open-source models)
  - [Dify API](https://dify.ai/) (Workflow-based AI applications)
  - [io.net API](https://io.net/) (Multi-LLM parallel execution, 23 models)
  - [DeepL API](https://www.deepl.com/translator-api) (Professional translation)

- **4-Layer Architecture for Progressive AI Capabilities**
  - **Core Layer**: Direct API access and basic utilities
  - **Usage/Task Layer**: Conversation management, text processing, proofreading
  - **Workflow Layer**: Multi-bot systems, R package development automation
  - **Expertise Layer**: Advanced data mining, pattern recognition, expert analysis

- **LLM-assisted R Package Development**
  - Complete package design and architecture planning
  - Automated R function creation with documentation
  - Code optimization and error analysis
  - Professional text proofreading and enhancement

- **Advanced Data Analysis and Knowledge Discovery**
  - Multi-domain statistical analysis interpretation (13+ domains)
  - Scientific literature processing and knowledge extraction
  - Web data mining and intelligent summarization
  - Expert-level discussion simulation and peer review processes
  
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

### 3. Set the API keys for Multi-API Support

chatAI4R supports multiple AI APIs. Configure the APIs you want to use:

#### **Required: OpenAI API** (for most functions)
Register at [OpenAI website](https://platform.openai.com/account/api-keys) and obtain your API key.

```r
# Set your OpenAI API key (required)
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-api-key")
```

#### **Optional: Additional AI APIs** (for extended functions)

```r
# Google Gemini API (for gemini4R, geminiGrounding4R)
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-api-key")

# Replicate API (for replicatellmAPI4R)
Sys.setenv(Replicate_API_KEY = "your-replicate-api-key")

# Dify API (for DifyChat4R)
Sys.setenv(DIFY_API_KEY = "your-dify-api-key")

# DeepL API (for discussion_flow functions with translation)
Sys.setenv(DeepL_API_KEY = "your-deepl-api-key")

# io.net API (for multiLLMviaionet functions)
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")
```

#### **Permanent Configuration**
Create an .Rprofile file in your home directory and add your API keys:

```r
# Create a file
file.create("~/.Rprofile") 

# Add all your API keys to the file
cat('
# chatAI4R API Keys Configuration
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-api-key")
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-api-key")
Sys.setenv(Replicate_API_KEY = "your-replicate-api-key")
Sys.setenv(DIFY_API_KEY = "your-dify-api-key")
Sys.setenv(DeepL_API_KEY = "your-deepl-api-key")
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")
', file = "~/.Rprofile", append = TRUE)

# [MacOS X] Open the file and edit it
system("open ~/.Rprofile")
```

Note: Please be aware of newline character inconsistencies across different operating systems.

## Tutorial

### Basic usage

- [Usage of functions in the chatAI4R package](https://kumes.github.io/chatAI4R/inst/vignettes/HowToUse.html)

- [Multi-LLM Demo: io.net API Examples](https://github.com/kumeS/chatAI4R/blob/main/examples/multiLLM_demo.R)

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

The chatAI4R package is structured as **4 Layered Functions** that provide increasingly sophisticated AI capabilities, from basic API access to expert-level data mining and analysis.

### 🟢 Core Functions (1st Layer)
**Access to LLM API / Multi-APIs**

Core functions provide direct access to multiple AI APIs, enabling basic AI operations.

|Function|Description|API Service|Script|Flowchart|
|:---|:---|:---|:---:|:---:|
|chat4R|Chat with GPT models using OpenAI API (One-shot)|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/chat4R.png)|
|chat4R_history|Use chat history for OpenAI's GPT model|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4R_history.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/chat4R_history.png)|
|textEmbedding|Text Embedding from OpenAI Embeddings API (1536-dimensional)|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/textEmbedding.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/textEmbedding.png)|
|vision4R|Advanced image analysis and interpretation|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/vision4R.R)||
|gemini4R|Chat with Google Gemini AI models|Google Gemini|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/gemini4R.R)||
|replicatellmAPI4R|Access various LLM models through Replicate platform|Replicate|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/replicateAPI4R.R)||
|DifyChat4R|Chat and completion endpoints through Dify platform|Dify|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/DifyChat4R.R)||
|multiLLMviaionet|Execute multiple LLM models simultaneously via io.net API|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|list_ionet_models|List available LLM models on io.net platform|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|multiLLM_random10|Quick execution of 10 randomly selected models via io.net|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|multiLLM_random5|Quick execution of 5 randomly selected models via io.net|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|completions4R|Generate text using OpenAI completions API (deprecated)|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/completions4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/completions4R.png)|

**Utility Functions (Non-API)**

|Function|Description|Script|
|:---|:---|:---:|
|slow_print_v2|Slowly print text with typewriter effect|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/slow_print_v2.R)|
|ngsub|Remove extra spaces and newline characters|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/ngsub.R)|
|removeQuotations|Remove all types of quotations from text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/removeQuotations.R)|

### 🟡 2nd Layered Functions (Usage/Task)
**Execution of simple LLM tasks: Chat memory, translation, proofreading, etc.**

These functions combine core APIs to perform specific tasks and maintain conversation context.

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|conversation4R|Manage conversation with persistent history|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/conversation4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/conversation4R.png)|
|TextSummary|Summarize long texts with intelligent chunking|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummary.R)||
|TextSummaryAsBullet|Summarize selected text into bullet points|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummaryAsBullet.R)||
|revisedText|Revision for scientific text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/revisedText.R)||
|proofreadEnglishText|Proofread English text via RStudio API|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/proofreadEnglishText.R)||
|proofreadText|Proofread text with grammar and style correction|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/proofreadText.R)||
|enrichTextContent|Enrich text content with additional information|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/enrichTextContent.R)||
|convertBullet2Sentence|Convert bullet points to sentences|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertBullet2Sentence.R)||

### 🟠 3rd Layered Functions (Workflow)
**LLM Workflow, LLM Bots, R Packaging Supports**

Advanced workflow functions that orchestrate multiple AI operations and support complex development tasks.

|Function|Description|Script|
|:---|:---|:---:|
|discussion_flow_v1|Multi-agent expert system simulation (3 roles)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/discussion_flow_v1.R)|
|discussion_flow_v2|Enhanced multi-bot conversation system|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/discussion_flow_v2.R)|
|createSpecifications4R|Create detailed specifications for R functions|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createSpecifications4R.R)|
|createRfunction|Create R functions from selected text or clipboard|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createRfunction.R)|
|createRcode|Generate R code from clipboard content|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createRcode.R)|
|convertRscript2Function|Convert R script to structured R function|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertRscript2Function.R)|
|addRoxygenDescription|Add Roxygen documentation to R functions|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/addRoxygenDescription.R)|
|OptimizeRcode|Optimize and complete R code|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/OptimizeRcode.R)|
|designPackage|Design complete R packages|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/designPackage.R)|
|addCommentCode|Add intelligent comments to R code|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/addCommentCode.R)|
|checkErrorDet|Analyze and explain R error messages|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet.R)|
|autocreateFunction4R|Generate and improve R functions (experimental)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/autocreateFunction4R.R)|
|supportIdeaGeneration|Support idea generation from text input|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/supportIdeaGeneration.R)|

### 🔴 4th Layered Functions (Expertise)
**Data mining & Advanced Analysis**

Expert-level functions that provide sophisticated data analysis, pattern recognition, and knowledge extraction capabilities.

|Function|Description|Script|
|:---|:---|:---:|
|interpretResult|Interpret analysis results across 13 analytical domains|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/interpretResult.R)|
|extractKeywords|Extract key concepts and terms from complex text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/extractKeywords.R)|
|convertScientificLiterature|Convert text to scientific literature format|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertScientificLiterature.R)|
|summaryWebScrapingText|Web scraping with intelligent summarization|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/summaryWebScrapingText.R)|
|geminiGrounding4R|Advanced AI with Google Search grounding|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/geminiGrounding4R.R)|
|chatAI4pdf|Intelligent PDF document analysis and summarization|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chatAI4pdf.R)|
|textFileInput4ai|Large-scale text file analysis with chunking|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/textFileInput4ai.R)|
|searchFunction|Expert-level R function discovery and recommendation|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/searchFunction.R)|


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

### Multi-LLM Execution via io.net

Execute multiple LLM models simultaneously for comprehensive AI responses.

```r
# Set io.net API key
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")

# Basic multi-LLM execution with latest models
result <- multiLLMviaionet(
  prompt = "Explain quantum computing",
  models = c("deepseek-ai/DeepSeek-R1-0528",            # Latest DeepSeek reasoning
             "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8",  # Llama 4 multimodal
             "Qwen/Qwen3-235B-A22B-FP8")               # Latest Qwen3 MoE
)

# Quick random 10 model comparison (from 23 available models)
result <- multiLLM_random10("What is artificial intelligence?")

# Quick random 5 model comparison
result <- multiLLM_random5("Write a Python function")

# List available models (23 total as of 2025)
models <- list_ionet_models()

# List by category
llama_models <- list_ionet_models("llama")      # 3 models
deepseek_models <- list_ionet_models("deepseek")  # 4 models
mistral_models <- list_ionet_models("mistral")    # 4 models
compact_models <- list_ionet_models("compact")    # 4 models
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
