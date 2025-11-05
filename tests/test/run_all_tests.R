# =============================================================================
# Comprehensive Test Runner for chatAI4R Package
# =============================================================================
#
# Purpose: Test all chatAI4R functions systematically with explicit API key management
#
# Usage:
#   source("tests/test/run_all_tests.R")
#
#   # Run with API keys as arguments (recommended)
#   results <- run_all_chatai4r_tests(
#     openai_key = "sk-your-openai-key",
#     gemini_key = "your-gemini-key",
#     ionet_key = "your-ionet-key"
#   )
#
#   # Or use environment variables (fallback)
#   Sys.setenv(OPENAI_API_KEY = "sk-your-key")
#   results <- run_all_chatai4r_tests()
#
#   # Minimal test (no API keys)
#   results <- run_all_chatai4r_tests()
#
# =============================================================================

#' Run Comprehensive Tests for chatAI4R Package
#'
#' @param openai_key OpenAI API key (optional, defaults to OPENAI_API_KEY env var)
#' @param gemini_key Google Gemini API key (optional, defaults to GoogleGemini_API_KEY env var)
#' @param replicate_key Replicate API key (optional, defaults to Replicate_API_KEY env var)
#' @param ionet_key io.net API key (optional, defaults to IONET_API_KEY env var)
#' @param deepl_key DeepL API key (optional, defaults to DeepL_API_KEY env var)
#' @param verbose Logical, print detailed output (default: TRUE)
#'
#' @return List containing test results with detailed statistics
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Recommended: Explicit API keys
#' results <- run_all_chatai4r_tests(
#'   openai_key = "sk-your-openai-key",
#'   ionet_key = "your-ionet-key"
#' )
#'
#' # Using environment variables
#' Sys.setenv(OPENAI_API_KEY = "sk-your-key")
#' results <- run_all_chatai4r_tests()
#'
#' # Minimal test (utility functions only)
#' results <- run_all_chatai4r_tests()
#'
#' # Check results
#' print(results$summary)
#' print(results$failed_tests)
#' }
run_all_chatai4r_tests <- function(
  openai_key = NULL,
  gemini_key = NULL,
  replicate_key = NULL,
  ionet_key = NULL,
  deepl_key = NULL,
  verbose = TRUE
) {

  # =============================================================================
  # Setup API Keys
  # =============================================================================

  # Set API keys (arguments take precedence over environment variables)
  if (!is.null(openai_key)) {
    Sys.setenv(OPENAI_API_KEY = openai_key)
  }
  if (!is.null(gemini_key)) {
    Sys.setenv(GoogleGemini_API_KEY = gemini_key)
  }
  if (!is.null(replicate_key)) {
    Sys.setenv(Replicate_API_KEY = replicate_key)
  }
  if (!is.null(ionet_key)) {
    Sys.setenv(IONET_API_KEY = ionet_key)
  }
  if (!is.null(deepl_key)) {
    Sys.setenv(DeepL_API_KEY = deepl_key)
  }

  # Check which API keys are available
  has_openai <- nzchar(Sys.getenv("OPENAI_API_KEY"))
  has_gemini <- nzchar(Sys.getenv("GoogleGemini_API_KEY"))
  has_replicate <- nzchar(Sys.getenv("Replicate_API_KEY"))
  has_ionet <- nzchar(Sys.getenv("IONET_API_KEY"))
  has_deepl <- nzchar(Sys.getenv("DeepL_API_KEY"))
  has_rstudio <- !is.null(getOption("rstudio.version"))

  # =============================================================================
  # Initialize Test Tracking
  # =============================================================================

  test_results <- list()
  test_start_time <- Sys.time()

  # =============================================================================
  # Helper Function: Safe Test Execution
  # =============================================================================

  run_test_safely <- function(test_name, test_code, skip_reason = NULL) {
    if (!is.null(skip_reason)) {
      if (verbose) cat(sprintf("[SKIP] %s - %s\n", test_name, skip_reason))
      return(list(
        function_name = test_name,
        status = "skipped",
        reason = skip_reason,
        error = NULL,
        duration = 0
      ))
    }

    if (verbose) cat(sprintf("[TEST] Running: %s\n", test_name))
    start_time <- Sys.time()

    result <- tryCatch({
      eval(parse(text = test_code))
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

      if (verbose) cat(sprintf("[PASS] %s (%.2f sec)\n", test_name, duration))
      list(
        function_name = test_name,
        status = "passed",
        error = NULL,
        duration = duration
      )
    }, error = function(e) {
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

      if (verbose) cat(sprintf("[FAIL] %s - %s (%.2f sec)\n", test_name, e$message, duration))
      list(
        function_name = test_name,
        status = "failed",
        error = e$message,
        duration = duration
      )
    }, warning = function(w) {
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

      if (verbose) cat(sprintf("[WARN] %s - %s (%.2f sec)\n", test_name, w$message, duration))
      list(
        function_name = test_name,
        status = "warning",
        error = w$message,
        duration = duration
      )
    })

    return(result)
  }

  # =============================================================================
  # Print Header
  # =============================================================================

  if (verbose) {
    cat("=============================================================================\n")
    cat("chatAI4R Package - Comprehensive Test Suite\n")
    cat("=============================================================================\n\n")
    cat("Environment Check:\n")
    cat(sprintf("  OpenAI API Key: %s\n", ifelse(has_openai, "✓ Available", "✗ Not set")))
    cat(sprintf("  Gemini API Key: %s\n", ifelse(has_gemini, "✓ Available", "✗ Not set")))
    cat(sprintf("  Replicate API Key: %s\n", ifelse(has_replicate, "✓ Available", "✗ Not set")))
    cat(sprintf("  io.net API Key: %s\n", ifelse(has_ionet, "✓ Available", "✗ Not set")))
    cat(sprintf("  DeepL API Key: %s\n", ifelse(has_deepl, "✓ Available", "✗ Not set")))
    cat(sprintf("  RStudio: %s\n\n", ifelse(has_rstudio, "✓ Available", "✗ Not available")))

    cat("[INIT] Loading chatAI4R package...\n")
  }

  suppressPackageStartupMessages(library(chatAI4R))

  if (verbose) {
    cat("[INIT] Package loaded successfully\n\n")
    cat("=============================================================================\n")
    cat("Starting Test Execution\n")
    cat("=============================================================================\n\n")
  }

  # =============================================================================
  # Test Definitions
  # =============================================================================

  test_idx <- 1

  # ---------------------------------------------------------------------------
  # 1. Utility Functions (No API required)
  # ---------------------------------------------------------------------------

  # Test: ngsub
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. ngsub", test_idx),
    'result <- ngsub("Hello   World\\n\\n")
     stopifnot(grepl("Hello", result))
     stopifnot(grepl("World", result))'
  )
  test_idx <- test_idx + 1

  # Test: removeQuotations
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. removeQuotations", test_idx),
    'result <- removeQuotations("Hello \\"World\\"")
     stopifnot(is.character(result))'
  )
  test_idx <- test_idx + 1

  # Test: slow_print_v2
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. slow_print_v2", test_idx),
    'slow_print_v2("Test", delay = 0.01)'
  )
  test_idx <- test_idx + 1

  # ---------------------------------------------------------------------------
  # 2. Core API Functions (Require OpenAI API)
  # ---------------------------------------------------------------------------

  if (has_openai) {
    # Test: chat4R
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. chat4R", test_idx),
      'result <- chat4R(content = "Say hello", Model = "gpt-4o-mini")
       stopifnot(is.data.frame(result) || is.character(result))
       stopifnot(nrow(result) > 0 || length(result) > 0)'
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
      'result <- chat4Rv2(content = "Say hello", Model = "gpt-4o-mini")
       stopifnot(is.data.frame(result) || is.list(result))
       stopifnot(length(result) > 0)'
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
       result <- chat4R_history(history, Model = "gpt-4o-mini")
       stopifnot(!is.null(result))
       stopifnot(length(result) > 0)'
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
    # Test: conversation4R (prints conversation, returns NULL)
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. conversation4R", test_idx),
      'invisible(capture.output(
         result <- conversation4R("Hello", Model = "gpt-4o-mini", initialization = TRUE)
       ))
       stopifnot(exists("chat_history", envir = .GlobalEnv))'
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
    # Test: TextSummary (skipped - requires interactive menu)
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. TextSummary", test_idx),
      NULL,
      skip_reason = "Requires interactive menu selection"
    )
  } else {
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. TextSummary", test_idx),
      NULL,
      skip_reason = "OpenAI API key not set"
    )
  }
  test_idx <- test_idx + 1

  # ---------------------------------------------------------------------------
  # 3. Gemini API Functions
  # ---------------------------------------------------------------------------

  if (has_gemini) {
    # Test: gemini4R
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. gemini4R", test_idx),
      'result <- gemini4R(mode = "text", contents = "Say hello")
       stopifnot(is.list(result))
       stopifnot(!is.null(result$candidates))'
    )
  } else {
    test_results[[test_idx]] <- run_test_safely(
      sprintf("%02d. gemini4R", test_idx),
      NULL,
      skip_reason = "Gemini API key not set"
    )
  }
  test_idx <- test_idx + 1

  # ---------------------------------------------------------------------------
  # 4. io.net API Functions
  # ---------------------------------------------------------------------------

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

  # ---------------------------------------------------------------------------
  # 5. RStudio-specific Functions (Skip if not in RStudio)
  # ---------------------------------------------------------------------------

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

  if (verbose) {
    cat("\n=============================================================================\n")
    cat("Test Execution Complete\n")
    cat("=============================================================================\n\n")
  }

  # Calculate statistics
  total_tests <- length(test_results)
  passed_tests <- sum(sapply(test_results, function(x) x$status == "passed"))
  failed_tests <- sum(sapply(test_results, function(x) x$status == "failed"))
  skipped_tests <- sum(sapply(test_results, function(x) x$status == "skipped"))
  warning_tests <- sum(sapply(test_results, function(x) x$status == "warning"))

  # Summary statistics
  if (verbose) {
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
    } else if (failed_tests == 0 && passed_tests == 0) {
      cat("⚠ NO TESTS WERE EXECUTED (All skipped)\n")
    } else {
      cat(sprintf("✗ TESTS FAILED (%d/%d passed)\n", passed_tests, total_tests))
    }
    cat("=============================================================================\n\n")
  }

  # Prepare return object
  summary_stats <- list(
    total_tests = total_tests,
    passed = passed_tests,
    failed = failed_tests,
    skipped = skipped_tests,
    warnings = warning_tests,
    pass_rate = passed_tests / total_tests,
    total_duration = total_duration
  )

  failed_test_details <- test_results[sapply(test_results, function(x) x$status == "failed")]
  warning_test_details <- test_results[sapply(test_results, function(x) x$status == "warning")]

  return(invisible(list(
    test_results = test_results,
    summary = summary_stats,
    failed_tests = failed_test_details,
    warnings = warning_test_details,
    environment = list(
      has_openai = has_openai,
      has_gemini = has_gemini,
      has_replicate = has_replicate,
      has_ionet = has_ionet,
      has_deepl = has_deepl,
      has_rstudio = has_rstudio
    )
  )))
}

# -----------------------------------------------------------------------------
# Convenience wrapper with simpler name
# -----------------------------------------------------------------------------

run_all_tests <- function(
  openai_key = NULL,
  gemini_key = NULL,
  replicate_key = NULL,
  ionet_key = NULL,
  deepl_key = NULL,
  verbose = TRUE
) {
  run_all_chatai4r_tests(
    openai_key = openai_key,
    gemini_key = gemini_key,
    replicate_key = replicate_key,
    ionet_key = ionet_key,
    deepl_key = deepl_key,
    verbose = verbose
  )
}

# =============================================================================
# Backward Compatibility: Run tests when sourced directly
# =============================================================================

# Check if this script is being sourced (not run as a function call)
# Make functions available when sourced and print quick help
assign("run_all_chatai4r_tests", run_all_chatai4r_tests, envir = .GlobalEnv)
assign("run_all_tests", run_all_tests, envir = .GlobalEnv)

cat("=============================================================================\n")
cat("chatAI4R Test Runner Loaded\n")
cat("=============================================================================\n\n")
cat("Functions available: run_all_tests(), run_all_chatai4r_tests()\n\n")
cat("Quick usage:\n")
cat("  source('tests/test/run_all_tests.R')\n")
cat("  results <- run_all_tests(openai_key='sk-...', ionet_key='...')\n\n")
