# =============================================================================
# Phase 2: Code Generation & Text Processing Functions (Combined)
# =============================================================================
#
# Phase 2 Tests - Unified file covering all Phase 2 functions
# Functions tested: 14 total
# Target: 63.5% coverage (33/52 functions)
#
# Functions tested:
#   01. chat4R_streaming() - Streaming chat responses (existence test)
#   02. convertBullet2Sentence() - Convert bullet points to sentences (existence test)
#   03. convertRscript2Function() - Convert R script to function (existence test)
#   04. convertScientificLiterature() - Convert scientific text (existence test)
#   05. createEBAYdes() - eBay description generator (existence test)
#   06. createRcode() - R code generation (existence test)
#   07. createRfunction() - R function creation (existence test)
#   08. createSpecifications4R() - Specification generator (existence test)
#   09. designPackage() - Package design helper (existence test)
#   10. discussion_flow_v2() - Discussion flow v2 (existence test)
#   11. enrichTextContent() - Text content enrichment (existence test)
#   12. list_ionet_models() - io.net model listing (existence test)
#   13. OptimizeRcode() - R code optimization (existence test)
#   14. RcodeImprovements() - R code improvements (existence test)
#
# =============================================================================

#' Run Phase 2 Tests (Combined)
#'
#' @param verbose Logical, print detailed output
#' @return Test results
#' @export
run_phase2_tests <- function(verbose = TRUE) {
  
  # Check environment
  has_openai <- nzchar(Sys.getenv("OPENAI_API_KEY"))
  has_ionet <- nzchar(Sys.getenv("IONET_API_KEY"))
  
  test_results <- list()
  test_start_time <- Sys.time()
  
  # Helper function
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
      list(function_name = test_name, status = "passed", error = NULL, duration = duration)
    }, error = function(e) {
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
      if (verbose) cat(sprintf("[FAIL] %s - %s (%.2f sec)\n", test_name, e$message, duration))
      list(function_name = test_name, status = "failed", error = e$message, duration = duration)
    })
    
    return(result)
  }
  
  if (verbose) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("Phase 2 Test Suite (Combined) - Code Generation & Text Processing\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
  }
  
  suppressPackageStartupMessages(library(chatAI4R))
  
  test_idx <- 1
  
  # ═════════════════════════════════════════════════════════════════════════
  # SECTION 1: Code Generation & Processing Functions (14 functions)
  # ═════════════════════════════════════════════════════════════════════════
  
  if (verbose) cat("\n--- Code Generation & Text Processing Functions ---\n")
  
  # Test 1: chat4R_streaming
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. chat4R_streaming", test_idx),
    'stopifnot(exists("chat4R_streaming"))
     stopifnot(is.function(chat4R_streaming))
     stopifnot(length(formals(chat4R_streaming)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 2: convertBullet2Sentence
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. convertBullet2Sentence", test_idx),
    'stopifnot(exists("convertBullet2Sentence"))
     stopifnot(is.function(convertBullet2Sentence))
     stopifnot(length(formals(convertBullet2Sentence)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 3: convertRscript2Function
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. convertRscript2Function", test_idx),
    'stopifnot(exists("convertRscript2Function"))
     stopifnot(is.function(convertRscript2Function))
     stopifnot(length(formals(convertRscript2Function)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 4: convertScientificLiterature
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. convertScientificLiterature", test_idx),
    'stopifnot(exists("convertScientificLiterature"))
     stopifnot(is.function(convertScientificLiterature))
     stopifnot(length(formals(convertScientificLiterature)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 5: createEBAYdes
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. createEBAYdes", test_idx),
    'stopifnot(exists("createEBAYdes"))
     stopifnot(is.function(createEBAYdes))
     stopifnot(length(formals(createEBAYdes)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 6: createRcode
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. createRcode", test_idx),
    'stopifnot(exists("createRcode"))
     stopifnot(is.function(createRcode))
     stopifnot(length(formals(createRcode)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 7: createRfunction
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. createRfunction", test_idx),
    'stopifnot(exists("createRfunction"))
     stopifnot(is.function(createRfunction))
     stopifnot(length(formals(createRfunction)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 8: createSpecifications4R
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. createSpecifications4R", test_idx),
    'stopifnot(exists("createSpecifications4R"))
     stopifnot(is.function(createSpecifications4R))
     stopifnot(length(formals(createSpecifications4R)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 9: designPackage
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. designPackage", test_idx),
    'stopifnot(exists("designPackage"))
     stopifnot(is.function(designPackage))
     stopifnot(length(formals(designPackage)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 10: discussion_flow_v2
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. discussion_flow_v2", test_idx),
    'stopifnot(exists("discussion_flow_v2"))
     stopifnot(is.function(discussion_flow_v2))
     stopifnot(length(formals(discussion_flow_v2)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 11: enrichTextContent
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. enrichTextContent", test_idx),
    'stopifnot(exists("enrichTextContent"))
     stopifnot(is.function(enrichTextContent))
     stopifnot(length(formals(enrichTextContent)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 12: list_ionet_models
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. list_ionet_models", test_idx),
    'stopifnot(exists("list_ionet_models"))
     stopifnot(is.function(list_ionet_models))
     stopifnot(length(formals(list_ionet_models)) >= 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 13: OptimizeRcode
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. OptimizeRcode", test_idx),
    'stopifnot(exists("OptimizeRcode"))
     stopifnot(is.function(OptimizeRcode))
     stopifnot(length(formals(OptimizeRcode)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # Test 14: RcodeImprovements
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. RcodeImprovements", test_idx),
    'stopifnot(exists("RcodeImprovements"))
     stopifnot(is.function(RcodeImprovements))
     stopifnot(length(formals(RcodeImprovements)) > 0)'
  )
  test_idx <- test_idx + 1
  
  # ═════════════════════════════════════════════════════════════════════════
  # FINAL SUMMARY
  # ═════════════════════════════════════════════════════════════════════════
  
  test_end_time <- Sys.time()
  total_duration <- as.numeric(difftime(test_end_time, test_start_time, units = "secs"))
  
  passed <- sum(sapply(test_results, function(x) x$status == "passed"))
  failed <- sum(sapply(test_results, function(x) x$status == "failed"))
  skipped <- sum(sapply(test_results, function(x) x$status == "skipped"))
  total <- length(test_results)
  
  if (verbose) {
    cat("\n═══════════════════════════════════════════════════════════════════════════\n")
    cat("Phase 2 Test Results\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
    cat(sprintf("Total Tests:     %d\n", total))
    cat(sprintf("Passed:          %d (%.1f%%)\n", passed, passed/total*100))
    cat(sprintf("Failed:          %d (%.1f%%)\n", failed, failed/total*100))
    cat(sprintf("Skipped:         %d (%.1f%%)\n", skipped, skipped/total*100))
    cat(sprintf("Total Duration:  %.2f seconds\n\n", total_duration))
    
    if (failed > 0) {
      cat("Failed Tests:\n")
      for (result in test_results) {
        if (result$status == "failed") {
          cat(sprintf("  - %s: %s\n", result$function_name, result$error))
        }
      }
      cat("\n")
    }
    
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    if (failed == 0) {
      cat("✓ ALL PHASE 2 TESTS PASSED\n")
    } else {
      cat("✗ SOME TESTS FAILED\n")
    }
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
  }
  
  return(invisible(list(
    test_results = test_results,
    summary = list(
      total = total,
      passed = passed,
      failed = failed,
      skipped = skipped,
      pass_rate = ifelse(total > 0, passed/total*100, 0),
      total_duration = total_duration
    ),
    failed_tests = test_results[sapply(test_results, function(x) x$status == "failed")]
  )))
}

# Run tests if sourced directly
if (sys.nframe() == 0) {
  results <- run_phase2_tests()
}
