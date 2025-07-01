# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**chatAI4R** is an R package that provides a Chat-based Interactive Artificial Intelligence interface for R, primarily integrating OpenAI API and other AI services. The package enables LLM-based AI techniques for knowledge discovery, data analysis, and R development assistance.

## Key Commands

### Package Development
```r
# Install development version
devtools::install_github("kumeS/chatAI4R")

# Load the package
library(chatAI4R)

# Run tests (legacy minimal test)
testthat::test_file("tests/testthat/test_chatAI4R.R")

# Run comprehensive test suite (recommended)
source("tests/test_execution.R")
```

### R Package Build Commands
```bash
# Check package
R CMD check chatAI4R/

# Build package
R CMD build chatAI4R/

# Install from source
R CMD INSTALL chatAI4R/

# CRAN-style check
R CMD check --as-cran chatAI4R/
```

### Comprehensive Testing Commands
```bash
# Run from tests/ directory

# Quick utility tests (no API key required)
./run_basic_tests.sh

# Full test suite with API key
./run_basic_tests.sh -k "sk-your-openai-key" -m full

# API functions only
./run_basic_tests.sh -k "sk-your-openai-key" -m api-only

# Alternative: Direct R script execution
Rscript test_execution.R --mode=utilities
Rscript test_execution.R --api-key="sk-key" --mode=full
```

### API Key Configuration
API keys must be set as environment variables before using the package:
```r
# Required for most functions
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-api-key")

# Optional for additional services
Sys.setenv(GEMINI_API_KEY = "your-gemini-api-key")
Sys.setenv(REPLICATE_API_TOKEN = "your-replicate-token")

# NEW: Required for multi-LLM via io.net (50+ models)
Sys.setenv(IONET_API_KEY = "your-ionet-api-key")

# Add to .Rprofile for persistence
file.create("~/.Rprofile")
# Add: Sys.setenv(OPENAI_API_KEY = "your_api_key_here")
# Add: Sys.setenv(IONET_API_KEY = "your_ionet_api_key_here")
```

## Architecture Overview

### Core Function Categories

1. **Basic AI Functions** (`R/chat4R.R`, `R/completions4R.R`, `R/textEmbedding.R`)
   - `chat4R()`: One-shot chatting with GPT models (default: gpt-4o-mini)
   - `completions4R()`: Text completion using OpenAI completions API
   - `textEmbedding()`: Convert text to embeddings using text-embedding-ada-002

2. **Conversation Management** (`R/conversation4R.R`, `R/chat4R_history.R`)
   - `conversation4R()`: Maintains conversation history with configurable memory window
   - `chat4R_history()`: Chat with persistent history functionality

3. **R Development Assistant Functions** (Multiple files in `R/`)
   - `createRfunction()`, `createRcode()`: Generate R functions and code
   - `addRoxygenDescription()`, `addCommentCode()`: Documentation assistance
   - `OptimizeRcode()`, `checkErrorDet()`: Code optimization and debugging
   - `designPackage()`, `createSpecifications4R()`: Package development support

4. **Text Processing Functions**
   - `TextSummary()`, `TextSummaryAsBullet()`: Text summarization
   - `proofreadEnglishText()`, `revisedText()`: Text revision and proofreading
   - `extractKeywords()`, `convertScientificLiterature()`: Content processing

5. **Advanced Features**
   - `discussion_flow_v1()`, `discussion_flow_v2()`: Multi-bot conversations
   - `gemini4R()`, `replicateAPI4R()`: Alternative AI service integrations
   - `vision4R()`: Image analysis capabilities

6. **NEW: Multi-LLM Platform** (`R/multiLLMviaionet.R`)
   - `multiLLMviaionet()`: Execute multiple LLM models simultaneously via io.net API
   - `list_ionet_models()`: Browse 50+ available models by category
   - **Supported Models**: Meta Llama, DeepSeek, Qwen, Microsoft Phi, Mistral, specialized models
   - **Key Features**: Parallel execution, streaming support, random selection, comprehensive error handling

### Package Structure
- `R/`: Core function implementations (52+ functions)
- `man/`: Auto-generated Roxygen documentation files
- `tests/`: Comprehensive test suite with performance monitoring
  - `test_execution.R`: Main test script (40+ functions tested)
  - `test_utilities.R`: Test helper functions
  - `run_basic_tests.sh`: One-command test runner
  - `testthat/`: Legacy minimal test suite
- `inst/`: Additional resources including prompts, examples, and vignettes
  - `rstudio/addins.dcf`: 25 RStudio addins configuration
- `DESCRIPTION`: Package metadata (v0.4.2, 16 dependencies)
- `NAMESPACE`: Auto-generated export declarations

### Dependencies
Primary dependencies include `httr`, `jsonlite`, `assertthat`, `clipr`, `rstudioapi`, and `deepRstudio` for various functionality including API calls, JSON processing, input validation, and RStudio integration.

### Key Design Patterns

1. **API Integration**: Functions consistently use OpenAI API patterns with proper error handling
2. **Input Validation**: Extensive use of `assertthat` for parameter validation
3. **Environment Variables**: API keys managed through system environment variables
4. **RStudio Integration**: Many functions integrate with RStudio API for clipboard and editor operations
5. **Conversation Memory**: Conversation functions maintain state using environment variables

### Testing Approach
- **Comprehensive Test Suite**: 40+ functions tested across 5 categories
  - Utility Functions (12): No API key required
  - Basic API Functions (15): OpenAI API key required  
  - Extended API Functions (8): Additional API keys required
  - File Processing (5): File-based operations
  - GUI Functions (15): Excluded from automated testing (RStudio-dependent)
- **Test Features**: Performance monitoring, timeout protection, detailed reporting
- **Quick Start**: Use `./tests/run_basic_tests.sh` for utilities-only testing
- **Legacy Tests**: Minimal coverage in `tests/testthat/test_chatAI4R.R`

## Important Notes

- This package requires valid API keys for OpenAI and other services
- Many functions require internet connectivity for API calls
- Several functions integrate with RStudio API and work best within RStudio environment
- The package supports multiple AI models including GPT-4, GPT-3.5-turbo, and Gemini
- Text embedding functions return 1536-dimensional vectors using Ada-002 model
- **25 RStudio Addins** are available for enhanced development workflow
- **System Requirements**: R >= 4.2.0, internet connectivity, RStudio (optional but recommended)

## Development Quality Notes

### Known Issues (from code analysis)
- **API Error Handling**: Missing HTTP status code validation in API functions
- **Null Pointer Safety**: Insufficient null checks before accessing nested API responses  
- **Deprecated APIs**: Using old OpenAI completions endpoint and embedding models
- **Security**: Potential API key exposure in logging

### Recommended Development Workflow
1. **Start with Testing**: Run `./tests/run_basic_tests.sh` to understand current state
2. **API Key Setup**: Configure all required API keys before development
3. **Use Comprehensive Tests**: Leverage the new test suite for validation
4. **Follow Patterns**: Use existing Roxygen2 documentation and assertthat validation patterns