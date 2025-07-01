# =============================================================================
# Test Utilities and Helper Functions for chatAI4R
# =============================================================================
# This file contains utility functions for testing chatAI4R package
# =============================================================================

# Load required libraries
suppressPackageStartupMessages({
  library(jsonlite)
  library(httr)
})

# =============================================================================
# Mock Response Generators
# =============================================================================

# Generate mock OpenAI chat response
mock_openai_chat_response <- function(content = "This is a mock response.", model = "gpt-4o-mini") {
  list(
    choices = list(
      list(
        message = list(
          role = "assistant",
          content = content
        ),
        finish_reason = "stop"
      )
    ),
    usage = list(
      prompt_tokens = 10,
      completion_tokens = 20,
      total_tokens = 30
    ),
    model = model
  )
}

# Generate mock OpenAI embedding response
mock_openai_embedding_response <- function(dimension = 1536) {
  list(
    data = list(
      list(
        embedding = runif(dimension, -1, 1),
        index = 0
      )
    ),
    model = "text-embedding-ada-002",
    usage = list(
      prompt_tokens = 5,
      total_tokens = 5
    )
  )
}

# Generate mock error response
mock_error_response <- function(error_type = "invalid_api_key", message = "Invalid API key") {
  list(
    error = list(
      type = error_type,
      message = message,
      code = "invalid_api_key"
    )
  )
}

# =============================================================================
# Test Data Generators
# =============================================================================

# Generate test text of various lengths
generate_test_text <- function(type = "short") {
  switch(type,
    "short" = "This is a short test text.",
    "medium" = paste(rep("This is a medium length test text for evaluation.", 5), collapse = " "),
    "long" = paste(rep("This is a long test text that should be sufficient for testing various text processing functions in the chatAI4R package.", 20), collapse = " "),
    "multilingual" = "Hello world. こんにちは世界。Hola mundo. Bonjour le monde.",
    "special_chars" = "Text with special characters: @#$%^&*()_+-=[]{}|;':\",./<>?",
    "empty" = "",
    "whitespace" = "   \n\t  \r\n   ",
    "numeric" = "123 456 789 3.14159 -42 1e6",
    "code" = "function hello() { console.log('Hello, World!'); }",
    "bullets" = "• First bullet point\n• Second bullet point\n• Third bullet point"
  )
}

# Generate test image data (base64)
generate_test_image_base64 <- function() {
  # Create a simple 1x1 PNG image in base64
  # This is a valid minimal PNG file
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
}

# =============================================================================
# Test Validation Functions
# =============================================================================

# Validate chat response format
validate_chat_response <- function(response) {
  if (!is.character(response)) {
    return(list(valid = FALSE, message = "Response is not character"))
  }
  if (nchar(response) == 0) {
    return(list(valid = FALSE, message = "Response is empty"))
  }
  if (nchar(response) > 10000) {
    return(list(valid = FALSE, message = "Response is too long"))
  }
  return(list(valid = TRUE, message = "Valid response"))
}

# Validate embedding response format
validate_embedding_response <- function(response) {
  if (!is.numeric(response)) {
    return(list(valid = FALSE, message = "Response is not numeric"))
  }
  if (length(response) < 100) {
    return(list(valid = FALSE, message = "Embedding vector too short"))
  }
  if (any(is.na(response))) {
    return(list(valid = FALSE, message = "Embedding contains NA values"))
  }
  return(list(valid = TRUE, message = "Valid embedding"))
}

# Validate function existence
validate_function_exists <- function(func_name) {
  if (!exists(func_name)) {
    return(list(valid = FALSE, message = paste("Function", func_name, "does not exist")))
  }
  if (!is.function(get(func_name))) {
    return(list(valid = FALSE, message = paste(func_name, "is not a function")))
  }
  return(list(valid = TRUE, message = "Function exists"))
}

# =============================================================================
# Performance Testing Functions
# =============================================================================

# Measure execution time
measure_execution_time <- function(func, ...) {
  start_time <- Sys.time()
  tryCatch({
    result <- func(...)
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    list(
      success = TRUE,
      result = result,
      execution_time = execution_time,
      message = paste("Execution completed in", round(execution_time, 3), "seconds")
    )
  }, error = function(e) {
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    list(
      success = FALSE,
      result = NULL,
      execution_time = execution_time,
      message = paste("Error after", round(execution_time, 3), "seconds:", e$message)
    )
  })
}

# Memory usage monitoring
measure_memory_usage <- function(func, ...) {
  # Get initial memory usage
  gc_start <- gc()
  mem_start <- sum(gc_start[, 2])
  
  tryCatch({
    result <- func(...)
    
    # Get final memory usage
    gc_end <- gc()
    mem_end <- sum(gc_end[, 2])
    
    list(
      success = TRUE,
      result = result,
      memory_used = mem_end - mem_start,
      message = paste("Memory used:", round(mem_end - mem_start, 2), "MB")
    )
  }, error = function(e) {
    gc_end <- gc()
    mem_end <- sum(gc_end[, 2])
    
    list(
      success = FALSE,
      result = NULL,
      memory_used = mem_end - mem_start,
      message = paste("Error, memory used:", round(mem_end - mem_start, 2), "MB:", e$message)
    )
  })
}

# =============================================================================
# Batch Testing Functions
# =============================================================================

# Test multiple functions with same input
batch_test_functions <- function(func_names, test_input, ...) {
  results <- list()
  
  for (func_name in func_names) {
    results[[func_name]] <- tryCatch({
      func <- get(func_name)
      result <- func(test_input, ...)
      list(
        status = "success",
        result = result,
        message = "Function executed successfully"
      )
    }, error = function(e) {
      list(
        status = "error",
        result = NULL,
        message = e$message
      )
    })
  }
  
  return(results)
}

# Test function with multiple inputs
test_function_multiple_inputs <- function(func_name, test_inputs, ...) {
  results <- list()
  func <- get(func_name)
  
  for (i in seq_along(test_inputs)) {
    input_name <- names(test_inputs)[i]
    if (is.null(input_name)) input_name <- paste("input", i)
    
    results[[input_name]] <- tryCatch({
      result <- func(test_inputs[[i]], ...)
      list(
        status = "success",
        result = result,
        message = "Function executed successfully"
      )
    }, error = function(e) {
      list(
        status = "error",
        result = NULL,
        message = e$message
      )
    })
  }
  
  return(results)
}

# =============================================================================
# Report Generation Functions
# =============================================================================

# Generate HTML test report
generate_html_report <- function(test_results, output_file = "test_report.html") {
  html_content <- paste0(
    "<!DOCTYPE html>\n",
    "<html><head><title>chatAI4R Test Report</title>",
    "<style>",
    "body { font-family: Arial, sans-serif; margin: 20px; }",
    ".summary { background-color: #f0f0f0; padding: 15px; border-radius: 5px; }",
    ".passed { color: green; }",
    ".failed { color: red; }",
    ".skipped { color: orange; }",
    ".test-detail { margin: 10px 0; padding: 10px; border-left: 3px solid #ccc; }",
    ".test-passed { border-left-color: green; }",
    ".test-failed { border-left-color: red; }",
    ".test-skipped { border-left-color: orange; }",
    "</style></head><body>"
  )
  
  # Summary section
  total_tests <- test_results$passed + test_results$failed + test_results$skipped
  html_content <- paste0(html_content,
    "<h1>chatAI4R Test Report</h1>",
    "<div class='summary'>",
    "<h2>Summary</h2>",
    "<p>Total Tests: ", total_tests, "</p>",
    "<p class='passed'>Passed: ", test_results$passed, "</p>",
    "<p class='failed'>Failed: ", test_results$failed, "</p>",
    "<p class='skipped'>Skipped: ", test_results$skipped, "</p>",
    "<p>Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "</p>",
    "</div>"
  )
  
  # Details section
  html_content <- paste0(html_content, "<h2>Test Details</h2>")
  
  for (detail in test_results$details) {
    css_class <- switch(detail$status,
      "PASSED" = "test-passed",
      "FAILED" = "test-failed",
      "SKIPPED" = "test-skipped",
      "test-detail"
    )
    
    html_content <- paste0(html_content,
      "<div class='test-detail ", css_class, "'>",
      "<h3>", detail$name, " [", detail$category, "]</h3>",
      "<p><strong>Status:</strong> ", detail$status, "</p>",
      "<p><strong>Message:</strong> ", detail$message, "</p>",
      "</div>"
    )
  }
  
  html_content <- paste0(html_content, "</body></html>")
  
  writeLines(html_content, output_file)
  return(output_file)
}

# Generate CSV summary report
generate_csv_report <- function(test_results, output_file = "test_summary.csv") {
  # Convert test details to data frame
  details_df <- do.call(rbind, lapply(test_results$details, function(x) {
    data.frame(
      Name = x$name,
      Category = x$category,
      Status = x$status,
      Message = x$message,
      stringsAsFactors = FALSE
    )
  }))
  
  write.csv(details_df, output_file, row.names = FALSE)
  return(output_file)
}

# =============================================================================
# Configuration Validation
# =============================================================================

# Validate API key format
validate_api_key <- function(api_key, service = "openai") {
  if (is.null(api_key) || api_key == "") {
    return(list(valid = FALSE, message = "API key is empty"))
  }
  
  if (service == "openai") {
    if (!grepl("^sk-", api_key)) {
      return(list(valid = FALSE, message = "OpenAI API key should start with 'sk-'"))
    }
    if (nchar(api_key) < 40) {
      return(list(valid = FALSE, message = "OpenAI API key is too short"))
    }
  }
  
  return(list(valid = TRUE, message = "API key format is valid"))
}

# Test internet connectivity
test_internet_connection <- function() {
  tryCatch({
    response <- GET("https://httpbin.org/get", timeout(5))
    if (status_code(response) == 200) {
      return(list(connected = TRUE, message = "Internet connection is available"))
    } else {
      return(list(connected = FALSE, message = "Internet connection test failed"))
    }
  }, error = function(e) {
    return(list(connected = FALSE, message = paste("Internet connection error:", e$message)))
  })
}

# =============================================================================
# Cleanup Functions
# =============================================================================

# Clean up temporary files
cleanup_temp_files <- function(file_patterns = c("temp_", "test_")) {
  temp_dir <- tempdir()
  all_files <- list.files(temp_dir, full.names = TRUE)
  
  for (pattern in file_patterns) {
    matching_files <- all_files[grepl(pattern, basename(all_files))]
    for (file in matching_files) {
      if (file.exists(file)) {
        unlink(file)
      }
    }
  }
}

# Reset environment variables
reset_env_vars <- function() {
  # Reset API keys to empty (using correct variable names)
  Sys.setenv(OPENAI_API_KEY = "")
  Sys.setenv(GoogleGemini_API_KEY = "")  # Correct name used by functions
  Sys.setenv(Replicate_API_KEY = "")     # Correct name used by functions
  Sys.setenv(DIFY_API_KEY = "")
  Sys.setenv(DeepL_API_KEY = "")
  Sys.setenv(IONET_API_KEY = "")         # io.net API key
}

# =============================================================================
# End of Test Utilities
# =============================================================================