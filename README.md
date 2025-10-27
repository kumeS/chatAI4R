# chatAI4R: Chat-Based Interactive Artificial Intelligence for R <img src="inst/figures/chatAI4R_logo.png" align="right" height="139" />

<!-- badges: start -->
[![CRAN](https://www.r-pkg.org/badges/version/chatAI4R)](https://cran.r-project.org/web/packages/chatAI4R/index.html)
[![CRAN_latest_release_date](https://www.r-pkg.org/badges/last-release/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![CRAN](https://cranlogs.r-pkg.org/badges/grand-total/chatAI4R)](https://www.datasciencemeta.com/rpackages)
[![:total status badge](https://kumes.r-universe.dev/badges/:total)](https://kumes.r-universe.dev)
[![chatAI4R status badge](https://kumes.r-universe.dev/badges/chatAI4R)](https://kumes.r-universe.dev)
<!-- badges: end -->

**Version 1.0.0** - Enhanced Security & Multi-LLM Capabilities

[GitHub/chatAI4R](https://github.com/kumeS/chatAI4R)

## Description

**chatAI4R**, **Chat-based Interactive Artificial Intelligence for R**, is an R package designed to integrate the OpenAI API and other APIs for artificial intelligence (AI) applications. This package leverages large language model (LLM)-based AI techniques, enabling efficient knowledge discovery and data analysis. chatAI4R provides basic R functions for using LLM and a set of R functions to support the creation of prompts for using LLM. The LLMs allow us to extend the world of R. Additionally, I strongly believe that the LLM is becoming so generalized that "Are you searching Google?" is likely to evolve into "Are you LLMing?".

chatAI4R is an experimental project aimed at developing and implementing various LLM applications in R. Furthermore, the package is under continuous development with a focus on extending its capabilities for bioinformatics analysis.

## About this project and future developments

- **🚀 Multi-API AI Integration with R** *(v1.0.0 Features)*
  - [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) (ChatGPT, GPT-4, text embeddings, vision) ✅ **Enhanced Security**
  - [Google Gemini API](https://ai.google.dev/) (Gemini models, search grounding) ✅ **Enhanced Security**
  - [Replicate API](https://replicate.com/) (Llama, other open-source models) ✅ **Enhanced Security**
  - [Dify API](https://dify.ai/) (Workflow-based AI applications) ✅ **Enhanced Security**
  - [**NEW**: io.net API](https://io.net/) (Multi-LLM parallel execution, **23+ models**)
  - [DeepL API](https://www.deepl.com/translator-api) (Professional translation)

- **🔒 Security Enhancements (v1.0.0)**
  - **HTTP Status Validation**: All API functions now validate HTTP response codes
  - **Safe Data Access**: Null-safe nested JSON parsing across all functions  
  - **Enhanced Error Handling**: Comprehensive error messages without credential exposure
  - **Input Validation**: Standardized parameter validation using assertthat patterns

- **4-Layer Architecture for Progressive AI Capabilities**
  - **Core Layer**: Direct API access and basic utilities
  - **Usage/Task Layer**: Conversation management, text processing, proofreading
  - **Workflow Layer**: Multi-bot systems, R package development automation
  - **Expertise Layer**: Advanced data mining, pattern recognition, expert analysis

- **LLM-assisted R Package Development**
  - Complete package design and architecture planning
  - Automated R function creation with documentation (✨ **Updated**: `autocreateFunction4R` now uses modern `chat4R` API)
  - Code optimization and error analysis
  - Professional text proofreading and enhancement

- **Advanced Data Analysis and Knowledge Discovery**
  - Multi-domain statistical analysis interpretation (13+ domains)
  - Scientific literature processing and knowledge extraction
  - Web data mining and intelligent summarization
  - Expert-level discussion simulation and peer review processes
  
***The functionality for interlanguage translation using DeepL has been separated as the 'deepRstudio' package. Functions related to text-to-image generation were separated as the 'stableDiffusion4R' package.***

## Installation of the chatAI4R package

### 🐧 **LINUX USERS: Read This First!**

On Linux systems, you **MUST** install system dependencies **BEFORE** installing the R package. The package includes PDF processing functionality that requires system libraries.

**Step 1: Install System Dependencies**

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install libqpdf-dev
```

**CentOS/RHEL:**
```bash
sudo yum install qpdf-devel
```

**Rocky Linux/Fedora:**
```bash
sudo dnf install qpdf-devel
```

**Step 2: Install pdftools in R (Optional but Recommended)**
```r
# After installing libqpdf-dev, install pdftools
install.packages("pdftools")
```

**Step 3: Install chatAI4R**
```r
# Now you can install chatAI4R
install.packages("chatAI4R")
```

**💡 Alternative: Install without PDF functionality**

If you don't need PDF processing (`chatAI4pdf()` function), you can install without pdftools:
```r
install.packages("chatAI4R", dependencies = FALSE)
```
All other functions will work normally. The package will show a helpful message if you try to use `chatAI4pdf()` without pdftools installed.

---

### 🍎 **macOS Users**

**With Homebrew (Recommended):**
```bash
brew install qpdf
```

Then install the R package:
```r
install.packages("chatAI4R")
```

---

### 🪟 **Windows Users**

Windows users can install directly:
```r
install.packages("chatAI4R")
```

---

### General Installation Instructions

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

### 4. Set the API keys for Multi-API Support

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

- [Multi-LLM Usage Examples](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R) (see function documentation)

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
|chat4R_streaming|Chat with GPT models using streaming response|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4R_streaming.R)||
|chat4Rv2|Enhanced chat interface with system prompt support|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/chat4Rv2.R)||
|textEmbedding|Text Embedding from OpenAI Embeddings API (1536-dimensional)|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/textEmbedding.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/textEmbedding.png)|
|vision4R|Advanced image analysis and interpretation|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/vision4R.R)||
|gemini4R|Chat with Google Gemini AI models|Google Gemini|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/gemini4R.R)||
|replicatellmAPI4R|Access various LLM models through Replicate platform|Replicate|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/replicateAPI4R.R)||
|DifyChat4R|Chat and completion endpoints through Dify platform|Dify|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/DifyChat4R.R)||
|multiLLMviaionet|Execute multiple LLM models simultaneously via io.net API|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|list_ionet_models|List available LLM models on io.net platform|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|multiLLM_random10|Quick execution of 10 randomly selected models via io.net|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|multiLLM_random5|Quick execution of 5 randomly selected models via io.net|io.net|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R)||
|completions4R|⚠️ **DEPRECATED** - Generate text using OpenAI completions API (scheduled for removal)|OpenAI|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/completions4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/completions4R.png)|

**Utility Functions (Non-API)**

|Function|Description|Script|
|:---|:---|:---:|
|slow_print_v2|Slowly print text with typewriter effect|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/slow_print_v2.R)|
|ngsub|Remove extra spaces and newline characters|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/ngsub.R)|
|removeQuotations|Remove all types of quotations from text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/removeQuotations.R)|
|speakInEN|Text-to-speech functionality for English|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/speakInEN.R)|
|speakInJA|Text-to-speech functionality for Japanese|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/speakInJA.R)|
|speakInJA_v2|Enhanced text-to-speech functionality for Japanese|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/speakInJA_v2.R)|

### 🟡 2nd Layered Functions (Usage/Task)
**Execution of simple LLM tasks: Chat memory, translation, proofreading, etc.**

These functions combine core APIs to perform specific tasks and maintain conversation context.

|Function|Description|Script|Flowchart|
|:---|:---|:---:|:---:|
|conversation4R|Manage conversation with persistent history|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/conversation4R.R)|[Flowchart](https://github.com/kumeS/chatAI4R/blob/main/inst/flowchart/conversation4R.png)|
|TextSummary|Summarize long texts with intelligent chunking|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummary.R)||
|TextSummaryAsBullet|Summarize selected text into bullet points|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/TextSummaryAsBullet.R)||
|revisedText|Revision for scientific text with AI assistance|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/RevisedText.R)||
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
|RcodeImprovements|Suggest improvements for R code from clipboard|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/RcodeImprovements.R)|
|designPackage|Design complete R packages|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/designPackage.R)|
|addCommentCode|Add intelligent comments to R code (supports OpenAI & Gemini)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/addCommentCode.R)|
|checkErrorDet|Analyze and explain R error messages|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet.R)|
|checkErrorDet_JP|Analyze and explain R error messages (Japanese)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/checkErrorDet_JP.R)|
|autocreateFunction4R|✨ **UPDATED** - Generate and improve R functions (now uses chat4R)|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/autocreateFunction4R.R)|
|supportIdeaGeneration|Support idea generation from text input|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/supportIdeaGeneration.R)|
|createEBAYdes|Create professional eBay product descriptions|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/create_eBay_Description.R)|
|createImagePrompt_v1|Create image generation prompts|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createImagePrompt_v1.R)|
|createImagePrompt_v2|Enhanced image generation prompts|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/createImagePrompt_v2.R)|

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

#⚠️ DEPRECATED: OpenAI completions API (scheduled for removal)
# completions4R("Hello")  # Use chat4R() instead
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

### 🌟 NEW: Multi-LLM Execution via io.net (v1.0.0)

Execute multiple LLM models simultaneously for comprehensive AI responses across **23+ cutting-edge models**.

```r
# Set io.net API key
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")

# Basic multi-LLM execution with latest 2025 models
result <- multiLLMviaionet(
  prompt = "Explain quantum computing",
  models = c("deepseek-ai/DeepSeek-R1-0528",                    # Latest reasoning model
             "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8", # Llama 4 multimodal
             "Qwen/Qwen3-235B-A22B-FP8",                      # Latest Qwen3 MoE
             "mistralai/Magistral-Small-2506",                # Advanced multilingual
             "microsoft/phi-4")                               # Compact powerhouse
)

# 🎲 Quick random 10 model comparison (balanced across families)
result <- multiLLM_random10("What is artificial intelligence?")

# ⚡ Quick random 5 model comparison (for faster testing)
result <- multiLLM_random5("Write a Python function")

# 📋 Explore available models (23+ total as of 2025)
all_models <- list_ionet_models()
print(paste("Total models available:", length(all_models)))

# 🏷️ Browse by category
llama_models <- list_ionet_models("llama")        # Meta Llama series (3 models)
deepseek_models <- list_ionet_models("deepseek")  # DeepSeek reasoning (4 models)  
qwen_models <- list_ionet_models("qwen")          # Alibaba Qwen series (2 models)
mistral_models <- list_ionet_models("mistral")    # Mistral AI series (4 models)
compact_models <- list_ionet_models("compact")    # Efficient models (4 models)
reasoning_models <- list_ionet_models("reasoning") # Math/logic specialists (2 models)

# 📊 Detailed model information
detailed_info <- list_ionet_models(detailed = TRUE)
View(detailed_info)

# 🚀 Advanced usage with custom parameters
result <- multiLLMviaionet(
  prompt = "Design a machine learning pipeline for time series forecasting",
  max_models = 8,
  random_selection = TRUE,
  temperature = 0.3,        # More deterministic for technical tasks
  max_tokens = 2000,        # Longer responses
  streaming = FALSE,        # Wait for complete responses
  parallel = TRUE,          # True async execution
  verbose = TRUE           # Monitor progress
)

# Access comprehensive results
print(result$summary)                    # Execution statistics
lapply(result$results, function(x) {     # Individual model responses
  if(x$success) cat(x$model, ":", substr(x$response, 1, 200), "...\n\n")
})
```

**🔥 Featured Models (2025)**:
- **DeepSeek-R1-0528**: Latest reasoning model with o1-like capabilities
- **Llama-4-Maverick**: Multimodal model with 128 experts architecture
- **Qwen3-235B**: Advanced MoE with 235B parameters
- **Magistral-Small-2506**: European AI with multilingual support
- **Phi-4**: Microsoft's efficient 14B parameter model

## 📈 What's New in v1.0.0 (January 2025)

### 🔒 **Security Enhancements**
- **Critical Security Fixes**: Resolved HTTP status validation issues across all API functions
- **Safe Data Access**: Implemented null-safe nested JSON parsing to prevent runtime crashes
- **Enhanced Error Handling**: Comprehensive error messages without API key exposure
- **Input Validation**: Standardized parameter validation using assertthat patterns
- **Security Score**: Improved from C+ (60/100) to **A- (85/100)**

### 🚀 **New Multi-LLM Capabilities** 
- **io.net Integration**: Execute 23+ models simultaneously via io.net API
- **Advanced Model Selection**: Random balanced selection across model families
- **True Async Processing**: Parallel execution using future package
- **Comprehensive Testing**: Enhanced test suite with 40+ functions tested

### 🛠️ **Developer Experience**
- **54 Functions**: Complete AI toolkit for R with enhanced coverage
- **Enhanced Documentation**: Comprehensive examples and usage patterns
- **CRAN Ready**: Production-quality codebase with consistent patterns
- **25 RStudio Addins**: Integrated development workflow

### 📊 **Function Categories**
- **Core Layer**: 19 functions for direct API access and utilities
- **Usage/Task Layer**: 8 functions for conversation management and text processing
- **Workflow Layer**: 18 functions for R package development and content creation
- **Expertise Layer**: 8 functions for advanced data analysis and knowledge mining

## License

Copyright (c) 2025 Satoshi Kume. Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2025) chatAI4R: Chat-based Interactive Artificial Intelligence for R. Version 1.0.0.

```
#BibTeX
@misc{Kume2025chatAI4R,
  title={chatAI4R: Chat-Based Interactive Artificial Intelligence for R},
  author={Kume, Satoshi}, 
  year={2025},
  version={1.0.0},
  publisher={GitHub}, 
  note={R Package with Multi-LLM Capabilities},
  howpublished={\url{https://github.com/kumeS/chatAI4R}},
}
```

## Contributors

- Satoshi Kume
