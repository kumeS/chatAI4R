# =============================================================================
# Comprehensive Test Runner for chatAI4R Package
# =============================================================================
#
# Purpose: Test all chatAI4R functions systematically
# Features:
#   - Runs all function tests without stopping on errors
#   - Tracks success/failure for each function
#   - Provides detailed error messages for failed tests
#   - Generates comprehensive summary report
#
# Usage:
#   source("tests/test/run_all_tests.R")
#
# Requirements:
#   - API keys must be set (optional, tests will skip if not available)
#   - RStudio not required (clipboard tests will be skipped)
#
# =============================================================================

# Initialize test tracking
test_results <- list()
test_start_time <- Sys.time()

# Function to safely run a test and capture results
run_test_safely <- function(test_name, test_code, skip_reason = NULL) {
  if (!is.null(skip_reason)) {
    cat(sprintf("[SKIP] %s - %s\n", test_name, skip_reason))
    return(list(
      function_name = test_name,
      status = "skipped",
      reason = skip_reason,
      error = NULL,
      duration = 0
    ))
  }

  cat(sprintf("[TEST] Running: %s\n", test_name))
  start_time <- Sys.time()

  result <- tryCatch({
    eval(parse(text = test_code))
    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    cat(sprintf("[PASS] %s (%.2f sec)\n", test_name, duration))
    list(
      function_name = test_name,
      status = "passed",
      error = NULL,
      duration = duration
    )
  }, error = function(e) {
    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    cat(sprintf("[FAIL] %s - %s (%.2f sec)\n", test_name, e$message, duration))
    list(
      function_name = test_name,
      status = "failed",
      error = e$message,
      duration = duration
    )
  }, warning = function(w) {
    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    cat(sprintf("[WARN] %s - %s (%.2f sec)\n", test_name, w$message, duration))
    list(
      function_name = test_name,
      status = "warning",
      error = w$message,
      duration = duration
    )
  })

  return(result)
}

# Check if API keys are available
has_openai <- nzchar(Sys.getenv("OPENAI_API_KEY"))
has_gemini <- nzchar(Sys.getenv("GoogleGemini_API_KEY"))
has_replicate <- nzchar(Sys.getenv("Replicate_API_KEY"))
has_ionet <- nzchar(Sys.getenv("IONET_API_KEY"))
has_rstudio <- !is.null(getOption("rstudio.version"))

cat("=============================================================================\n")
cat("chatAI4R Package - Comprehensive Test Suite\n")
cat("=============================================================================\n\n")
cat("Environment Check:\n")
cat(sprintf("  OpenAI API Key: %s\n", ifelse(has_openai, "✓ Available", "✗ Not set")))
cat(sprintf("  Gemini API Key: %s\n", ifelse(has_gemini, "✓ Available", "✗ Not set")))
cat(sprintf("  Replicate API Key: %s\n", ifelse(has_replicate, "✓ Available", "✗ Not set")))
cat(sprintf("  io.net API Key: %s\n", ifelse(has_ionet, "✓ Available", "✗ Not set")))
cat(sprintf("  RStudio: %s\n\n", ifelse(has_rstudio, "✓ Available", "✗ Not available")))

# Load the package
cat("[INIT] Loading chatAI4R package...\n")
suppressPackageStartupMessages(library(chatAI4R))
cat("[INIT] Package loaded successfully\n\n")

cat("=============================================================================\n")
cat("Starting Test Execution\n")
cat("=============================================================================\n\n")

# =============================================================================
# Test Definitions
# =============================================================================

test_idx <- 1

# -----------------------------------------------------------------------------
# 1. Utility Functions (No API required)
# -----------------------------------------------------------------------------

# Test: ngsub
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. ngsub", test_idx),
  'result <- ngsub("Hello   World\\n\\n")
   stopifnot(result == "Hello World")'
)
test_idx <- test_idx + 1

# Test: removeQuotations
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. removeQuotations", test_idx),
  'result <- removeQuotations(\\"Hello \\"World\\"\\"")
   stopifnot(is.character(result))'
)
test_idx <- test_idx + 1

# Test: slow_print_v2
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. slow_print_v2", test_idx),
  'slow_print_v2("Test", delay = 0.01)'
)
test_idx <- test_idx + 1

# -----------------------------------------------------------------------------
# 2. Core API Functions (Require OpenAI API)
# -----------------------------------------------------------------------------

if (has_openai) {
  # Test: chat4R
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4R", test_idx),
    'result <- chat4R(content = "Say hello", Model = "gpt-4o-mini", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4R", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

if (has_openai) {
  # Test: chat4Rv2
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4Rv2", test_idx),
    'result <- chat4Rv2(content = "Say hello", Model = "gpt-4o-mini", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4Rv2", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

if (has_openai) {
  # Test: chat4R_history
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4R_history", test_idx),
    'history <- list(
       list(role = "system", content = "You are a helpful assistant."),
       list(role = "user", content = "Say hello")
     )
     result <- chat4R_history(history, Model = "gpt-4o-mini", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4R_history", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

if (has_openai) {
  # Test: textEmbedding
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. textEmbedding", test_idx),
    'result <- textEmbedding("Hello world")
     stopifnot(is.numeric(result))
     stopifnot(length(result) == 1536)'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. textEmbedding", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

if (has_openai) {
  # Test: conversation4R
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. conversation4R", test_idx),
    'result <- conversation4R("Hello", Model = "gpt-4o-mini", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. conversation4R", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

if (has_openai) {
  # Test: TextSummary
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. TextSummary", test_idx),
    'result <- TextSummary("This is a long text that needs summarization",
                           nch = 50, Model = "gpt-4o-mini", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. TextSummary", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1

# -----------------------------------------------------------------------------
# 3. Gemini API Functions
# -----------------------------------------------------------------------------

if (has_gemini) {
  # Test: gemini4R
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. gemini4R", test_idx),
    'result <- gemini4R(content = "Say hello", verbose = FALSE)
     stopifnot(is.character(result))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. gemini4R", test_idx),
    NULL,
    skip_reason = "Gemini API key not set"
  )
}
test_idx <- test_idx + 1

# -----------------------------------------------------------------------------
# 4. io.net API Functions
# -----------------------------------------------------------------------------

if (has_ionet) {
  # Test: list_ionet_models
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. list_ionet_models", test_idx),
    'result <- list_ionet_models()
     stopifnot(is.character(result))
     stopifnot(length(result) > 0)'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. list_ionet_models", test_idx),
    NULL,
    skip_reason = "io.net API key not set"
  )
}
test_idx <- test_idx + 1

if (has_ionet) {
  # Test: multiLLMviaionet (basic)
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. multiLLMviaionet", test_idx),
    'result <- multiLLMviaionet(
       prompt = "Say hello",
       max_models = 2,
       max_tokens = 50,
       verbose = FALSE
     )
     stopifnot(is.list(result))
     stopifnot(!is.null(result$results))'
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. multiLLMviaionet", test_idx),
    NULL,
    skip_reason = "io.net API key not set"
  )
}
test_idx <- test_idx + 1

# -----------------------------------------------------------------------------
# 5. RStudio-specific Functions (Skip if not in RStudio)
# -----------------------------------------------------------------------------

if (has_rstudio && has_openai) {
  # Test: addCommentCode
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. addCommentCode", test_idx),
    NULL,
    skip_reason = "Requires interactive RStudio session"
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. addCommentCode", test_idx),
    NULL,
    skip_reason = "Requires RStudio and OpenAI API key"
  )
}
test_idx <- test_idx + 1

if (has_rstudio && has_openai) {
  # Test: addRoxygenDescription
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. addRoxygenDescription", test_idx),
    NULL,
    skip_reason = "Requires interactive RStudio session"
  )
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. addRoxygenDescription", test_idx),
    NULL,
    skip_reason = "Requires RStudio and OpenAI API key"
  )
}
test_idx <- test_idx + 1

# =============================================================================
# Generate Summary Report
# =============================================================================

test_end_time <- Sys.time()
total_duration <- as.numeric(difftime(test_end_time, test_start_time, units = "secs"))

cat("\n=============================================================================\n")
cat("Test Execution Complete\n")
cat("=============================================================================\n\n")

# Calculate statistics
total_tests <- length(test_results)
passed_tests <- sum(sapply(test_results, function(x) x$status == "passed"))
failed_tests <- sum(sapply(test_results, function(x) x$status == "failed"))
skipped_tests <- sum(sapply(test_results, function(x) x$status == "skipped"))
warning_tests <- sum(sapply(test_results, function(x) x$status == "warning"))

# Summary statistics
cat("Summary Statistics:\n")
cat("===================\n")
cat(sprintf("Total Tests:     %d\n", total_tests))
cat(sprintf("Passed:          %d (%.1f%%)\n", passed_tests, 100 * passed_tests / total_tests))
cat(sprintf("Failed:          %d (%.1f%%)\n", failed_tests, 100 * failed_tests / total_tests))
cat(sprintf("Skipped:         %d (%.1f%%)\n", skipped_tests, 100 * skipped_tests / total_tests))
cat(sprintf("Warnings:        %d (%.1f%%)\n", warning_tests, 100 * warning_tests / total_tests))
cat(sprintf("Total Duration:  %.2f seconds\n\n", total_duration))

# Detailed failure report
if (failed_tests > 0) {
  cat("Failed Tests Details:\n")
  cat("=====================\n")
  for (i in seq_along(test_results)) {
    result <- test_results[[i]]
    if (result$status == "failed") {
      cat(sprintf("\n[%02d] %s\n", i, result$function_name))
      cat(sprintf("     Error: %s\n", result$error))
      cat(sprintf("     Duration: %.2f sec\n", result$duration))
    }
  }
  cat("\n")
}

# Warning report
if (warning_tests > 0) {
  cat("Tests with Warnings:\n")
  cat("====================\n")
  for (i in seq_along(test_results)) {
    result <- test_results[[i]]
    if (result$status == "warning") {
      cat(sprintf("\n[%02d] %s\n", i, result$function_name))
      cat(sprintf("     Warning: %s\n", result$error))
      cat(sprintf("     Duration: %.2f sec\n", result$duration))
    }
  }
  cat("\n")
}

# Performance report (top 5 slowest tests)
cat("Performance Report (Top 5 Slowest Tests):\n")
cat("==========================================\n")
passed_with_duration <- test_results[sapply(test_results, function(x) x$status == "passed")]
if (length(passed_with_duration) > 0) {
  sorted_by_duration <- passed_with_duration[order(sapply(passed_with_duration, function(x) x$duration), decreasing = TRUE)]
  top_5 <- head(sorted_by_duration, 5)
  for (i in seq_along(top_5)) {
    result <- top_5[[i]]
    cat(sprintf("%d. %s - %.2f sec\n", i, result$function_name, result$duration))
  }
} else {
  cat("No passed tests to analyze\n")
}
cat("\n")

# Final verdict
cat("=============================================================================\n")
if (failed_tests == 0 && passed_tests > 0) {
  cat("✓ ALL TESTS PASSED\n")
  exit_code <- 0
} else if (failed_tests == 0 && passed_tests == 0) {
  cat("⚠ NO TESTS WERE EXECUTED (All skipped)\n")
  exit_code <- 1
} else {
  cat(sprintf("✗ TESTS FAILED (%d/%d passed)\n", passed_tests, total_tests))
  exit_code <- 1
}
cat("=============================================================================\n\n")

# Save results to file
results_file <- "tests/test/test_results.Rds"
saveRDS(test_results, results_file)
cat(sprintf("Test results saved to: %s\n", results_file))

# Return exit code (0 = success, 1 = failure)
quit(status = exit_code, save = "no")
