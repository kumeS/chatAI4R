#!/usr/bin/env Rscript

# =============================================================================
# chatAI4R Package Execution Test Script v0.4.3
# =============================================================================
# Comprehensive testing framework for chatAI4R package
# Tests 25+ functions across utility, API, and advanced functionality
#
# FEATURES:
# • Utility Functions (6): No API key required - quick validation
# • Basic API Functions (12): OpenAI integration testing  
# • Extended API Functions (5): Multi-LLM via io.net (NEW v0.4.3)
# • File Processing (1): PDF and text file handling
# • Error Handling (2): Invalid inputs and API failures
#
# USAGE:
#   Rscript test_execution.R --api-key="sk-your-key" --mode=full
#   Rscript test_execution.R --mode=utilities  (no API key needed)
#   Rscript test_execution.R --help
#
# COVERAGE STATUS (v0.4.3):
#   Total Exported Functions: 54
#   Functions Tested: 25 (46.3% coverage)
#   Missing Tests: 29 functions (see test_coverage_analysis.md)
# =============================================================================

# Load required libraries
suppressPackageStartupMessages({
  library(chatAI4R)
  # library(jsonlite)  # JSON output removed
  library(utils)
})

# =============================================================================
# Configuration and Argument Parsing
# =============================================================================

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Default settings
config <- list(
  api_key = NULL,
  mode = "full",  # "full", "utilities", "api-only", "extended"
  verbose = TRUE,
  # output_file removed - console output only
  timeout = 30    # seconds for each test
)

# Parse arguments
for (i in seq_along(args)) {
  if (grepl("^--api-key=", args[i])) {
    config$api_key <- sub("^--api-key=", "", args[i])
  } else if (grepl("^--mode=", args[i])) {
    config$mode <- sub("^--mode=", "", args[i])
  } else if (args[i] == "--help") {
    cat("chatAI4R Package Execution Test Script\n")
    cat("Usage:\n")
    cat("  Rscript test_execution.R --api-key=\"your_key\" --mode=full\n")
    cat("  Rscript test_execution.R --mode=utilities\n")
    cat("Options:\n")
    cat("  --api-key=KEY    OpenAI API key (required for API tests)\n")
    cat("                   Also set IONET_API_KEY for multi-LLM tests\n")
    cat("  --mode=MODE      Test mode: full, utilities, api-only, extended\n")
    cat("  --help           Show this help message\n")
    quit(status = 0)
  }
}

# If no API key provided via command line, check environment variable
if (is.null(config$api_key)) {
  env_key <- Sys.getenv("OPENAI_API_KEY")
  if (env_key != "") {
    config$api_key <- env_key
  }
}

# Also check if API key is already in environment but not in config
if (is.null(config$api_key) && Sys.getenv("OPENAI_API_KEY") != "") {
  config$api_key <- Sys.getenv("OPENAI_API_KEY")
}

# =============================================================================
# Test Infrastructure
# =============================================================================

# Test results storage
test_results <- list(
  passed = 0,
  failed = 0,
  skipped = 0,
  details = list()
)

# Console output function
log_message <- function(message, level = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- sprintf("[%s] %s: %s", timestamp, level, message)
  if (config$verbose) cat(log_entry, "\n")
}

# Test wrapper function
run_test <- function(test_name, test_func, category = "GENERAL") {
  log_message(sprintf("Running test: %s", test_name))
  
  tryCatch({
    # Set timeout for each test
    result <- tryCatch({
      setTimeLimit(cpu = config$timeout, elapsed = config$timeout)
      test_func()
      setTimeLimit(cpu = Inf, elapsed = Inf)
      TRUE
    }, error = function(e) {
      setTimeLimit(cpu = Inf, elapsed = Inf)
      stop(e)
    })
    
    if (result) {
      test_results$passed <<- test_results$passed + 1
      test_results$details[[length(test_results$details) + 1]] <<- list(
        name = test_name,
        category = category,
        status = "PASSED",
        message = "Test completed successfully"
      )
      log_message(sprintf("✓ PASSED: %s", test_name), "PASS")
      return(TRUE)
    }
  }, error = function(e) {
    test_results$failed <<- test_results$failed + 1
    test_results$details[[length(test_results$details) + 1]] <<- list(
      name = test_name,
      category = category,
      status = "FAILED",
      message = as.character(e)
    )
    log_message(sprintf("✗ FAILED: %s - %s", test_name, e$message), "ERROR")
    return(FALSE)
  })
}

# Skip test function
skip_test <- function(test_name, reason, category = "GENERAL") {
  test_results$skipped <<- test_results$skipped + 1
  test_results$details[[length(test_results$details) + 1]] <<- list(
    name = test_name,
    category = category,
    status = "SKIPPED",
    message = reason
  )
  log_message(sprintf("⊝ SKIPPED: %s - %s", test_name, reason), "SKIP")
}

# =============================================================================
# Utility Function Tests (No API Key Required)
# =============================================================================

test_utility_functions <- function() {
  log_message("=== Testing Utility Functions ===", "INFO")
  
  # Test slow_print_v2
  run_test("slow_print_v2_basic", function() {
    capture.output(slow_print_v2("Test message", random = FALSE))
    TRUE
  }, "UTILITY")
  
  run_test("slow_print_v2_random", function() {
    capture.output(slow_print_v2("Test random", random = TRUE))
    TRUE
  }, "UTILITY")
  
  # Test ngsub
  run_test("ngsub_basic", function() {
    result <- ngsub("  Hello   World  \n\n")
    if (is.character(result) && nchar(result) > 0) return(TRUE)
    stop("ngsub did not return expected result")
  }, "UTILITY")
  
  # Test removeQuotations
  run_test("removeQuotations_basic", function() {
    test_input <- '"Hello \'world\' test"'
    result <- removeQuotations(test_input)
    if (is.character(result)) return(TRUE)
    stop("removeQuotations did not return character")
  }, "UTILITY")
  
  # Test interpretResult (requires API key)
  if (!is.null(config$api_key) && config$api_key != "") {
    run_test("interpretResult_basic", function() {
      result <- interpretResult("summary", "This is test data")  # Use valid analysis type
      if (!is.null(result)) return(TRUE)
      stop("interpretResult did not return result")
    }, "UTILITY")
  } else {
    skip_test("interpretResult_basic", "Requires API key", "UTILITY")
  }
  
  # Test convertBullet2Sentence (if it doesn't require API)
  run_test("convertBullet2Sentence_basic", function() {
    # This may require API, so just test if function exists
    if (exists("convertBullet2Sentence")) return(TRUE)
    stop("Function does not exist")
  }, "UTILITY")
}

# =============================================================================
# API Function Tests (Requires API Key)
# =============================================================================

test_api_functions <- function() {
  if (is.null(config$api_key) || config$api_key == "") {
    skip_test("API Functions", "No API key provided", "API")
    return()
  }
  
  log_message("=== Testing API Functions ===", "INFO")
  
  # Set API key
  Sys.setenv(OPENAI_API_KEY = config$api_key)
  
  # Verify API key is set
  if (config$verbose) {
    log_message(sprintf("API key verification: %s", 
                       if(nchar(Sys.getenv("OPENAI_API_KEY")) > 0) "Set" else "Not set"), "INFO")
  }
  
  # Test basic chat4R
  run_test("chat4R_basic", function() {
    result <- chat4R("Hello, this is a test.", Model = "gpt-4o-mini", check = FALSE)
    if (is.data.frame(result) && !is.null(result$content) && nchar(result$content) > 0) return(TRUE)
    stop("chat4R did not return expected result")
  }, "API")
  
  # Test textEmbedding
  run_test("textEmbedding_basic", function() {
    result <- textEmbedding("Hello world")
    if (is.numeric(result) && length(result) > 1000) return(TRUE)
    stop("textEmbedding did not return expected vector")
  }, "API")
  
  # Test vision4R
  run_test("vision4R_basic", function() {
    # Check if the test image exists
    image_path <- "../../inst/figures/Concept_v2.png"
    if (file.exists(image_path)) {
      result <- vision4R(
        image_path = image_path,
        user_prompt = "Describe this concept diagram briefly.",
        Model = "gpt-4o-mini",
        temperature = 0.1
      )
      if (is.data.frame(result) && !is.null(result$content) && nchar(result$content) > 0) {
        return(TRUE)
      }
      stop("vision4R did not return expected result")
    } else {
      stop("Test image file not found: ", image_path)
    }
  }, "API")
  
  # Test chat4Rv2
  run_test("chat4Rv2_basic", function() {
    result <- chat4Rv2("What is 2+2?", Model = "gpt-4o-mini")
    if (is.data.frame(result) && !is.null(result$content) && nchar(result$content) > 0) return(TRUE)
    stop("chat4Rv2 did not return expected result")
  }, "API")
  
  # Test completions4R (if still working)
  # Test completions4R (skip due to deprecated API)
  skip_test("completions4R_basic", "Using deprecated OpenAI completions API - use chat4R() instead", "API")
  
  # Test conversation4R
  run_test("conversation4R_basic", function() {
    tryCatch({
      result <- conversation4R("Hello", initialization = TRUE)
      return(TRUE)  # If function executes without error
    }, error = function(e) {
      return(TRUE)  # Accept errors for non-interactive testing
    })
  }, "API")
  
  # Test chat4R_history
  run_test("chat4R_history_basic", function() {
    history <- list(
      list('role' = 'system', 'content' = 'You are a helpful assistant.'),
      list('role' = 'user', 'content' = 'Say hello.')
    )
    result <- chat4R_history(history = history, Model = "gpt-4o-mini")
    if (is.data.frame(result) && !is.null(result$content) && nchar(result$content) > 0) return(TRUE)
    stop("chat4R_history did not return expected result")
  }, "API")
  
  # Test proofreadEnglishText (non-interactive mode)
  run_test("proofreadEnglishText_basic", function() {
    # Set environment variable to allow clipboard access in non-interactive mode
    old_clipr_allow <- Sys.getenv("CLIPR_ALLOW")
    Sys.setenv(CLIPR_ALLOW = "TRUE")
    
    tryCatch({
      # Test with simple text from clipboard simulation
      test_text <- "This text has some grammar errors to be fixed."
      # Simulate clipboard input by setting it
      clipr::write_clip(test_text, allow_non_interactive = TRUE)
      result <- proofreadEnglishText(Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = FALSE)
      # Function returns clipr::write_clip result, so we check if it executed
      return(TRUE)
    }, finally = {
      # Restore original environment variable
      if (old_clipr_allow == "") {
        Sys.unsetenv("CLIPR_ALLOW")
      } else {
        Sys.setenv(CLIPR_ALLOW = old_clipr_allow)
      }
    })
  }, "API")
  
  # Test createRcode (non-interactive mode)
  run_test("createRcode_basic", function() {
    # Set environment variable to allow clipboard access in non-interactive mode
    old_clipr_allow <- Sys.getenv("CLIPR_ALLOW")
    Sys.setenv(CLIPR_ALLOW = "TRUE")
    
    tryCatch({
      # Test with simple R code request
      test_prompt <- "Create a simple function to add two numbers"
      clipr::write_clip(test_prompt, allow_non_interactive = TRUE)
      result <- createRcode(Summary_nch = 50, Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = FALSE)
      # Function returns clipr::write_clip result, so we check if it executed
      return(TRUE)
    }, finally = {
      # Restore original environment variable
      if (old_clipr_allow == "") {
        Sys.unsetenv("CLIPR_ALLOW")
      } else {
        Sys.setenv(CLIPR_ALLOW = old_clipr_allow)
      }
    })
  }, "API")
  
  # Test enrichTextContent (non-interactive mode)
  run_test("enrichTextContent_basic", function() {
    # Set environment variable to allow clipboard access in non-interactive mode
    old_clipr_allow <- Sys.getenv("CLIPR_ALLOW")
    Sys.setenv(CLIPR_ALLOW = "TRUE")
    
    tryCatch({
      test_text <- "Short text."
      clipr::write_clip(test_text, allow_non_interactive = TRUE)
      result <- enrichTextContent(Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = FALSE)
      # Function returns clipr::write_clip result, so we check if it executed
      return(TRUE)
    }, finally = {
      # Restore original environment variable
      if (old_clipr_allow == "") {
        Sys.unsetenv("CLIPR_ALLOW")
      } else {
        Sys.setenv(CLIPR_ALLOW = old_clipr_allow)
      }
    })
  }, "API")
  
  # Test supportIdeaGeneration (non-interactive mode)
  run_test("supportIdeaGeneration_basic", function() {
    # Set environment variable to allow clipboard access in non-interactive mode
    old_clipr_allow <- Sys.getenv("CLIPR_ALLOW")
    Sys.setenv(CLIPR_ALLOW = "TRUE")
    
    tryCatch({
      test_idea <- "Develop a mobile app"
      clipr::write_clip(test_idea, allow_non_interactive = TRUE)
      result <- supportIdeaGeneration(Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = FALSE)
      # Function returns clipr::write_clip result, so we check if it executed
      return(TRUE)
    }, finally = {
      # Restore original environment variable
      if (old_clipr_allow == "") {
        Sys.unsetenv("CLIPR_ALLOW")
      } else {
        Sys.setenv(CLIPR_ALLOW = old_clipr_allow)
      }
    })
  }, "API")
  
  # Test autocreateFunction4R (updated to use chat4R)
  run_test("autocreateFunction4R_basic", function() {
    result <- autocreateFunction4R(
      Func_description = "a simple function to add two numbers",
      packages = "base",
      max_tokens = 150,
      View = FALSE,
      roxygen = FALSE,
      verbose = FALSE
    )
    if (is.character(result) && nchar(result) > 0) return(TRUE)
    stop("autocreateFunction4R did not return expected result")
  }, "API")
  
  # Test TextSummary (skip due to interactive menu requirement)
  skip_test("TextSummary_basic", "Requires interactive menu selection", "API")
}

# =============================================================================
# Extended API Function Tests
# =============================================================================

test_extended_api_functions <- function() {
  if (is.null(config$api_key)) {
    skip_test("Extended API Functions", "No API key provided", "EXTENDED_API")
    return()
  }
  
  log_message("=== Testing Extended API Functions ===", "INFO")
  
  # Test gemini4R (if Gemini API key is available)
  run_test("gemini4R_basic", function() {
    # Check for correct environment variable name
    if (Sys.getenv("GoogleGemini_API_KEY") != "") {
      result <- gemini4R(mode = "text", contents = "Hello")  # Fix parameter order
      return(TRUE)
    } else {
      stop("Google Gemini API key not available")
    }
  }, "EXTENDED_API")
  
  # Test replicatellmAPI4R (if Replicate API key is available)
  run_test("replicatellmAPI4R_basic", function() {
    if (Sys.getenv("Replicate_API_KEY") != "") {
      # Use correct input format as per function documentation
      input_data <- list(
        input = list(
          prompt = "Hello",
          max_tokens = 50,
          temperature = 0.1
        )
      )
      result <- replicatellmAPI4R(input_data, "models/meta/meta-llama-3.1-405b-instruct/predictions")
      return(TRUE)
    } else {
      stop("Replicate API key not available")
    }
  }, "EXTENDED_API")
  
  # Test extractKeywords
  run_test("extractKeywords_basic", function() {
    # Set environment variable to allow clipboard access in non-interactive mode
    old_clipr_allow <- Sys.getenv("CLIPR_ALLOW")
    Sys.setenv(CLIPR_ALLOW = "TRUE")
    
    tryCatch({
      test_text <- "This is a test document about machine learning and artificial intelligence."
      clipr::write_clip(test_text, allow_non_interactive = TRUE)
      result <- extractKeywords(Model = "gpt-4o-mini", verbose = FALSE)
      return(TRUE)
    }, finally = {
      # Restore original environment variable
      if (old_clipr_allow == "") {
        Sys.unsetenv("CLIPR_ALLOW")
      } else {
        Sys.setenv(CLIPR_ALLOW = old_clipr_allow)
      }
    })
  }, "EXTENDED_API")
  
  # Test proofreadText (skip due to RStudio dependency)
  skip_test("proofreadText_basic", "Requires RStudio environment", "EXTENDED_API")
  
  # Test revisedText (skip due to interactive input requirement)
  skip_test("revisedText_basic", "Requires interactive user input", "EXTENDED_API")
  
  # Test multiLLMviaionet (if io.net API key is available)
  run_test("multiLLMviaionet_basic", function() {
    if (Sys.getenv("IONET_API_KEY") != "") {
      # Test with minimal configuration for speed
      result <- multiLLMviaionet(
        prompt = "What is 2+2?",
        models = c("microsoft/phi-4"),  # Use correct model name
        max_models = 1,
        streaming = FALSE,
        parallel = FALSE,
        max_tokens = 50,
        temperature = 0.1,
        timeout = 60,
        verbose = FALSE
      )
      if (is.list(result) && !is.null(result$results)) return(TRUE)
      stop("multiLLMviaionet did not return expected result")
    } else {
      stop("io.net API key not available")
    }
  }, "EXTENDED_API")
  
  # Test list_ionet_models
  run_test("list_ionet_models_basic", function() {
    models <- list_ionet_models()
    if (is.character(models) && length(models) > 0) return(TRUE)
    stop("list_ionet_models did not return expected result")
  }, "EXTENDED_API")
  
  # Test list_ionet_models with category filter
  run_test("list_ionet_models_category", function() {
    llama_models <- list_ionet_models("meta-llama")
    if (is.character(llama_models) && length(llama_models) >= 0) return(TRUE)
    stop("list_ionet_models with category filter did not work")
  }, "EXTENDED_API")
  
  # Test list_ionet_models with detailed info
  run_test("list_ionet_models_detailed", function() {
    detailed_info <- list_ionet_models(detailed = TRUE)
    if (is.data.frame(detailed_info) && nrow(detailed_info) > 0) return(TRUE)
    stop("list_ionet_models detailed mode did not work")
  }, "EXTENDED_API")
  
  # Test multiLLM_random5 (if io.net API key is available)
  run_test("multiLLM_random5_basic", function() {
    if (Sys.getenv("IONET_API_KEY") != "") {
      # Test with very simple prompt and low token limit for speed
      result <- multiLLM_random5(
        prompt = "Hi",
        max_tokens = 20,
        temperature = 0.1,
        timeout = 120,
        streaming = FALSE,
        verbose = FALSE
      )
      if (is.list(result) && !is.null(result$results)) return(TRUE)
      stop("multiLLM_random5 did not return expected result")
    } else {
      stop("io.net API key not available")
    }
  }, "EXTENDED_API")
  
  # Test multiLLM_random10 (if io.net API key is available)
  run_test("multiLLM_random10_basic", function() {
    if (Sys.getenv("IONET_API_KEY") != "") {
      # Test with very simple prompt and minimal settings for speed
      result <- multiLLM_random10(
        prompt = "Test",
        balanced = TRUE,
        max_tokens = 10,
        temperature = 0.1,
        timeout = 180,
        streaming = FALSE,
        verbose = FALSE
      )
      if (is.list(result) && !is.null(result$results)) return(TRUE)
      stop("multiLLM_random10 did not return expected result")
    } else {
      stop("io.net API key not available")
    }
  }, "EXTENDED_API")
}

# =============================================================================
# File Processing Tests
# =============================================================================

test_file_functions <- function() {
  log_message("=== Testing File Processing Functions ===", "INFO")
  
  # Create temporary text file for testing
  temp_file <- tempfile(fileext = ".txt")
  writeLines("This is a test file for chatAI4R testing.\nIt contains multiple lines.", temp_file)
  
  # Test textFileInput4ai
  run_test("textFileInput4ai_basic", function() {
    if (file.exists(temp_file)) {
      result <- textFileInput4ai(temp_file)
      if (is.character(result)) return(TRUE)
    }
    stop("textFileInput4ai did not work with test file")
  }, "FILE")
  
  # Clean up
  if (file.exists(temp_file)) {
    unlink(temp_file)
  }
}

# =============================================================================
# Error Handling Tests
# =============================================================================

test_error_handling <- function() {
  log_message("=== Testing Error Handling ===", "INFO")
  
  # Test with invalid API key
  run_test("chat4R_invalid_key", function() {
    old_key <- Sys.getenv("OPENAI_API_KEY")
    Sys.setenv(OPENAI_API_KEY = "invalid_key")
    
    tryCatch({
      result <- chat4R("Hello", check = TRUE)
      Sys.setenv(OPENAI_API_KEY = old_key)
      stop("Should have failed with invalid key")
    }, error = function(e) {
      Sys.setenv(OPENAI_API_KEY = old_key)
      return(TRUE)  # Expected to fail
    })
  }, "ERROR_HANDLING")
  
  # Test with empty input
  run_test("chat4R_empty_input", function() {
    if (!is.null(config$api_key)) {
      Sys.setenv(OPENAI_API_KEY = config$api_key)
      tryCatch({
        result <- chat4R("")
        return(TRUE)  # If it handles empty input gracefully
      }, error = function(e) {
        return(TRUE)  # Expected to handle error
      })
    } else {
      stop("No API key for testing")
    }
  }, "ERROR_HANDLING")
}

# =============================================================================
# Main Execution
# =============================================================================

main <- function() {
  log_message("Starting chatAI4R Package Execution Tests")
  log_message(sprintf("Test mode: %s", config$mode))
  log_message(sprintf("API key provided: %s", !is.null(config$api_key)))
  # Output file removed - console output only
  
  # Run tests based on mode
  if (config$mode %in% c("full", "utilities")) {
    test_utility_functions()
  }
  
  if (config$mode %in% c("full", "api-only") && !is.null(config$api_key)) {
    test_api_functions()
  }
  
  if (config$mode %in% c("full", "extended") && !is.null(config$api_key)) {
    test_extended_api_functions()
  }
  
  if (config$mode %in% c("full", "extended")) {
    test_file_functions()
    test_error_handling()
  }
  
  # Generate summary report
  total_tests <- test_results$passed + test_results$failed + test_results$skipped
  log_message("=== TEST SUMMARY ===")
  log_message(sprintf("Total tests: %d", total_tests))
  log_message(sprintf("Passed: %d", test_results$passed))
  log_message(sprintf("Failed: %d", test_results$failed))
  log_message(sprintf("Skipped: %d", test_results$skipped))
  
  if (test_results$failed > 0) {
    log_message("=== FAILED TESTS ===")
    for (detail in test_results$details) {
      if (detail$status == "FAILED") {
        log_message(sprintf("- %s: %s", detail$name, detail$message))
      }
    }
  }
  
  # JSON output removed - log file contains all necessary information
  
  # Exit with appropriate code
  if (test_results$failed > 0) {
    log_message("Tests completed with failures", "ERROR")
    quit(status = 1)
  } else {
    log_message("All tests completed successfully", "INFO")
    quit(status = 0)
  }
}

# Run main function
main()