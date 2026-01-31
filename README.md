# chatAI4R: Chat-Based Interactive Artificial Intelligence for R <img src="inst/figures/chatAI4R_logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/kumeS/chatAI4R/workflows/R-CMD-check/badge.svg)](https://github.com/kumeS/chatAI4R/actions)
[![CRAN](https://www.r-pkg.org/badges/version/chatAI4R)](https://cran.r-project.org/web/packages/chatAI4R/index.html)
[![CRAN_latest_release_date](https://www.r-pkg.org/badges/last-release/chatAI4R)](https://cran.r-project.org/package=chatAI4R)
[![CRAN](https://cranlogs.r-pkg.org/badges/grand-total/chatAI4R)](https://www.datasciencemeta.com/rpackages)
[![:total status badge](https://kumes.r-universe.dev/badges/:total)](https://kumes.r-universe.dev)
[![chatAI4R status badge](https://kumes.r-universe.dev/badges/chatAI4R)](https://kumes.r-universe.dev)
<!-- badges: end -->

**Version 1.1.0** - Linux Installation Improvements & CI/CD Integration

[GitHub/chatAI4R](https://github.com/kumeS/chatAI4R)

## Description

**chatAI4R**, **Chat-based Interactive Artificial Intelligence for R**, is an R package designed to integrate the OpenAI API and other APIs for artificial intelligence (AI) applications. This package leverages large language model (LLM)-based AI techniques, enabling efficient knowledge discovery and data analysis. chatAI4R provides basic R functions for using LLM and a set of R functions to support the creation of prompts for using LLM. The LLMs allow us to extend the world of R. Additionally, I strongly believe that the LLM is becoming so generalized that "Are you searching Google?" is likely to evolve into "Are you LLMing?".

chatAI4R is an experimental project aimed at developing and implementing various LLM applications in R. Furthermore, the package is under continuous development with a focus on extending its capabilities for bioinformatics analysis.

## 🎯 Who is this for?

- R package developers - automate documentation (Roxygen2), generate functions, improve code quality
- Data analysts - interpret statistical results, process literature, extract insights

**Key Difference**: Beyond multi-functional API wrappers - provides a **4-layer architecture** from basic API access to expert-level workflows and domain-specific analysis tools.

## ✨ Key Features

### 🚀 Multi-API Support (6 AI Services)
- **OpenAI** (ChatGPT, GPT-4, Vision, Embeddings)
- **Google Gemini** (Gemini models with search grounding)
- **io.net** (23+ models including DeepSeek-R1, Llama-4, Qwen3, Mistral)
- **Replicate** (Open-source models)
- **Dify** (Workflow-based AI)
- **DeepL** (Professional translation)

### 🏗️ 4-Layer Architecture (Beyond Simple API Wrapper)

**Layer 1 - Core Functions**: Direct API access (`chat4R`, `gemini4R`, `multiLLMviaionet`)
**Layer 2 - Advanced Functions**: Intelligent processing and domain-specific analysis (`interpretResult`, `conversation4R`, `geminiGrounding4R`)
**Layer 3 - Workflow Functions**: Multi-agent collaboration and package automation (`discussion_flow_v2`, `autocreateFunction4R`)
**Layer 4 - Integration Functions**: Ecosystem connectivity (deploying R-based web APIs via `plumber` for backend embedding, and GUI support)

### 🔒 Production-Ready Security
- HTTP status validation and error handling
- Null-safe JSON parsing
- Input validation with informative error messages
- No credential exposure in logs

***Note**: Translation features separated to `deepRstudio` package. Image generation features in `stableDiffusion4R` package.*

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

## 🔧 Troubleshooting for instllation of this package

### Fix Corrupted Help Database Error

If you encounter: `Error in fetch(key): lazy-load database '...chatAI4R.rdb' is corrupt`

**Cause:** Package help database (.rdb file) corruption due to incomplete installation, system crash during loading, or R version upgrade.

**Quick Fix:**

```r
# Automated repair (removes corrupted install, reinstalls from GitHub, verifies)
system.file("rebuild_package.R", package = "chatAI4R") |> source()

# Then restart R
.rs.restartR()  # RStudio: or Session > Restart R (Ctrl+Shift+F10)
```

**Manual alternative:**

```r
remove.packages("chatAI4R")
remotes::install_github("kumeS/chatAI4R", force = TRUE)
.rs.restartR()
```

---

## 🚀 Quick Start

### Basic Usage

```r
library(chatAI4R)

# 1. One-shot chat
chat4R("Explain linear regression assumptions")

# 2. Conversation with memory
conversation4R("What's the best clustering algorithm for this data?")
conversation4R("It has 10,000 samples and 50 features")

# 3. R package development
autocreateFunction4R(
  Func_description = "Create a function to calculate log2 fold change with error handling"
)
# → Generates function + Roxygen2 documentation
```

**Note regarding output formatting**: Current AI models tend to emit many literal `\n` sequences in generated text. This package intentionally preserves `\n` so it formats as intended when displayed via `cat()` (rather than `print()`), which improves readability in typical console usage. It is recommended to use `cat()` to display the output.

### Advanced Features

**Statistical Interpretation** (13+ domains):

```r
model <- lm(mpg ~ wt + hp, data = mtcars)
interpretResult(analysis_type = "regression", result_text = summary(model))
```

### Multi-Agent Discussion

Collaborative problem-solving with multiple specialized agents:

```r
# Basic discussion
discussion_flow_v1(
  issue = "Optimize machine learning pipeline",
  Domain = "data science"
)

# Advanced discussion with custom settings
discussion_flow_v2(
  issue = "Optimize machine learning pipeline",
  Domain = "data science",
  Sentence_difficulty = 2,
  R_expert_setting = TRUE,
  rep_x = 3
)
```

### R Package Development Utils

Streamline package creation and documentation:

```r
# Add Roxygen2 documentation to selected code
# (Select the function definition in RStudio first)
addRoxygenDescription(Model = "gpt-5-nano", SelectedCode = TRUE)

# Create function from clipboard content
createRfunction(Model = "gpt-5", SelectedCode = FALSE)
```

## 💡 Use Cases

**R Package Development**: Design packages, generate functions with Roxygen2 docs, debug errors
**Data Analysis**: Interpret statistical results, process literature, extract insights
**Multi-Model Comparison**: Compare 23+ LLM responses for robust analysis

## Tutorial

### Basic usage

- [Usage of functions in the chatAI4R package](https://kumes.github.io/chatAI4R/inst/vignettes/HowToUse.html)

- [Multi-LLM Usage Examples](https://github.com/kumeS/chatAI4R/blob/main/R/multiLLMviaionet.R) (see function documentation)

## Testing

chatAI4R includes a comprehensive automated testing framework:

- **Test Coverage**: 52/52 functions testable (96%+ comprehensive coverage)
- **Base Tests**: 14 core functions for quick validation (~9 seconds)
- **Extended Tests**: Phase 1-5 suites covering all function categories (~50 seconds)
- **CI/CD Ready**: Automated testing on Windows, macOS, and Linux via GitHub Actions

## Prompts for chatGPT / GPT-4

|File|Description|Prompt|
|:---|:---|:---:|
|create_flowcharts|A prompt to create a flowchart|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_flowcharts.txt)|
|create_roxygen2_v01|A prompt to create a roxygen2 description|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_roxygen2_v01.txt)|
|create_roxygen2_v02|A prompt to create a roxygen2 description|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/create_roxygen2_v02.txt)|
|edit_DESCRIPTION|A prompt to edit DESCRIPTION|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/edit_DESCRIPTION.txt)|
|Img2txt_prompt_v01|A prompt to create a i2i prompt|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/Img2txt_prompt_v01.txt)|
|Img2txt_prompt_v02|A prompt to create a i2i prompt|[Prompt](https://github.com/kumeS/chatAI4R/blob/main/inst/chatGPT_prompts/Img2txt_prompt_v02.txt)|


## 📚 Function Reference

chatAI4R provides **54 functions** organized in a **4-layer architecture**. Below are the most commonly used functions. For a complete function list, see [Full Function Reference](#full-function-reference).

### 🎯 Most Used Functions

**Getting Started:**
- `chat4R()` - One-shot chat with GPT models (OpenAI)
- `conversation4R()` - Multi-turn conversations with memory
- `gemini4R()` - Chat with Google Gemini models
- `multiLLMviaionet()` - Compare 23+ models simultaneously

**Data Analysis:**
- `interpretResult()` - AI-powered statistical interpretation (13 domains)
- `TextSummary()` - Intelligent text summarization
- `extractKeywords()` - Extract key concepts from text

**R Development:**
- `autocreateFunction4R()` - Generate R functions with documentation
- `addRoxygenDescription()` - Add Roxygen2 documentation
- `checkErrorDet()` - Explain R error messages

**Advanced Workflows:**
- `discussion_flow_v1()` - Multi-expert AI discussion simulation
- `geminiGrounding4R()` - AI with Google Search grounding
- `textFileInput4ai()` - Process large text files

### 🔍 Full Function Reference

The chatAI4R package is structured as **4 Layered Functions** that provide increasingly sophisticated AI capabilities, from basic API access to expert-level data mining and analysis.

<details>
<summary><b>🟢 Layer 1: Core Functions (API Access) - Click to expand</b></summary>

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

</details>

<details>
<summary><b>🟡 Layer 2: Usage/Task Functions - Click to expand</b></summary>

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

</details>

<details>
<summary><b>🟠 Layer 3: Workflow Functions - Click to expand</b></summary>

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

</details>

<details>
<summary><b>🔴 Layer 4: Expertise Functions - Click to expand</b></summary>

### 🔴 4th Layered Functions (Expertise)
**Data mining & Advanced Analysis**

Expert-level functions that provide sophisticated data analysis, pattern recognition, and knowledge extraction capabilities.

|Function|Description|Script|
|:---|:---|:---:|
|interpretResult|Interpret analysis results across 13 analytical domains|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/interpretResult.R)|
|extractKeywords|Extract key concepts and terms from complex text|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/extractKeywords.R)|
|convertScientificLiterature|Convert text to scientific literature format|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/convertScientificLiterature.R)|
|geminiGrounding4R|Advanced AI with Google Search grounding|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/geminiGrounding4R.R)|
|textFileInput4ai|Large-scale text file analysis with chunking|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/textFileInput4ai.R)|
|searchFunction|Expert-level R function discovery and recommendation|[Script](https://github.com/kumeS/chatAI4R/blob/main/R/searchFunction.R)|

</details>

## 💻 Additional Examples

### Multi-LLM Execution via io.net

Execute multiple LLM models simultaneously for comprehensive AI responses across **23+ cutting-edge models**.

```r
# Set io.net API key
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")

# Basic multi-LLM execution (Randomly selects 3 models)
result <- multiLLMviaionet(
  prompt = "Explain quantum computing",
  max_models = 3,
  random_selection = TRUE
)

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
  streaming = FALSE,
  random_selection = TRUE,
  max_tokens = 2000,
  temperature = 0.3,        # More deterministic for technical tasks
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

## 📈 What's New

### 🐧 **Version 1.1.0** (October 2025) - Linux Installation Fix

**Breaking Change for Better Compatibility:**
- **Removed pdftools Dependency**: Eliminated the optional `pdftools` dependency that was causing Linux installation failures due to missing system libraries (`libqpdf-dev`)
- **Simplified Installation**: Linux users can now install chatAI4R without any system library dependencies
- **Function Removal**: `chatAI4pdf()` function has been removed from the package (available as standalone script in `inst/sh/`)

**CI/CD Integration:**
- **Multi-Platform Testing**: Added GitHub Actions workflow for automated testing on Windows, macOS, and Linux
- **Test Framework**: Comprehensive test suite with 6 test files covering 52/52 functions (96% coverage)
- **Continuous Integration**: R CMD check runs automatically on push/PR to main, master, and dev branches
- **Quality Assurance**: Ensures package builds correctly across all major platforms

**Installation Improvements:**
- ✅ **Before v1.1.0** (Linux): Required system libraries → Installation errors
- ✅ **After v1.1.0** (Linux): No system dependencies → Simple `install.packages("chatAI4R")`

**Impact:**
- **53 Core Functions**: All AI, LLM, and R development functions work normally
- **No Breaking Changes**: Only the optional PDF processing function was removed
- **Better User Experience**: Eliminates the most common Linux installation error

---

### 📊 **Version 1.0.0** (January 2025) - Security & Multi-LLM

**🔒 Security Enhancements**
- **Critical Security Fixes**: Resolved HTTP status validation issues across all API functions
- **Safe Data Access**: Implemented null-safe nested JSON parsing to prevent runtime crashes
- **Enhanced Error Handling**: Comprehensive error messages without API key exposure
- **Input Validation**: Standardized parameter validation using assertthat patterns
- **Security Score**: Improved from C+ (60/100) to **A- (85/100)**

**🚀 New Multi-LLM Capabilities**
- **io.net Integration**: Execute 23+ models simultaneously via io.net API
- **Advanced Model Selection**: Random balanced selection across model families
- **True Async Processing**: Parallel execution using future package
- **Comprehensive Testing**: Enhanced test suite with 52 functions testable (96% coverage)

**🛠️ Developer Experience**
- **54 Functions**: Complete AI toolkit for R with enhanced coverage
- **Enhanced Documentation**: Comprehensive examples and usage patterns
- **CRAN Ready**: Production-quality codebase with consistent patterns
- **25 RStudio Addins**: Integrated development workflow

**📊 Function Categories**
- **Core Layer**: 19 functions for direct API access and utilities
- **Usage/Task Layer**: 8 functions for conversation management and text processing
- **Workflow Layer**: 18 functions for R package development and content creation
- **Expertise Layer**: 7 functions for advanced data analysis and knowledge mining (PDF function removed in v1.1.0)

## License

Copyright (c) 2025 Satoshi Kume. Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## Cite

Kume S. (2025) chatAI4R: Chat-based Interactive Artificial Intelligence for R. Version 1.1.0.

```
#BibTeX
@misc{Kume2025chatAI4R,
  title={chatAI4R: Chat-Based Interactive Artificial Intelligence for R},
  author={Kume, Satoshi},
  year={2026},
  version={1.3.1},
  publisher={GitHub},
  note={R Package with Multi-LLM Capabilities},
  howpublished={\url{https://github.com/kumeS/chatAI4R}},
}
```

## Contributors

- Satoshi Kume
