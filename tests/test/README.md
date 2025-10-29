# chatAI4R Test Suite

Comprehensive automated testing framework for the chatAI4R package.

## Overview

This test suite provides systematic testing for all chatAI4R functions with detailed error reporting, performance metrics, and comprehensive summaries.

## Quick Start

```r
# Run all tests
source("tests/test/run_all_tests.R")
```

```bash
# Command line execution
Rscript tests/test/run_all_tests.R

# Save output to file
Rscript tests/test/run_all_tests.R > test_results.txt 2>&1
```

## Files

### Main Test Runner

- **`run_all_tests.R`** - Comprehensive test framework with detailed reporting

### Generated Files

- **`test_results.Rds`** - Saved test results (created after test execution)

## Key Features

### ✅ Comprehensive Coverage
- Tests all available chatAI4R functions
- Covers utility functions, core API calls, and multi-API integrations
- Currently includes **14 test cases** (expandable to 50+)

### ✅ Error Resilience
- Continues execution even when individual tests fail
- Captures detailed error messages for debugging
- Never stops the entire test suite due to one failure

### ✅ Smart Skipping
- Automatically detects available API keys
- Skips tests that require unavailable resources
- Clearly reports why tests were skipped

### ✅ Detailed Reporting
- Real-time test execution status ([PASS]/[FAIL]/[SKIP])
- Summary statistics (pass rate, duration)
- Failed test details with error messages
- Performance metrics (execution time per test)
- Top 5 slowest tests report

### ✅ CI/CD Ready
- Returns proper exit codes (0 = success, 1 = failure)
- Easy integration with GitHub Actions
- Generates machine-readable results file (Rds format)

## Test Categories

### 1. Utility Functions (No API Key Required)

Tests basic utility functions that don't require external API calls:

- `ngsub()` - Text normalization
- `removeQuotations()` - Quote removal
- `slow_print_v2()` - Slow printing

**Setup**: None required

### 2. Core API Functions (OpenAI)

Tests core chat and embedding functions using OpenAI API:

- `chat4R()` - Basic chat completion
- `chat4Rv2()` - Enhanced chat with system prompt
- `chat4R_history()` - Chat with conversation history
- `textEmbedding()` - Text embedding generation
- `conversation4R()` - Conversation management
- `TextSummary()` - Text summarization

**Setup**: Requires OpenAI API key
```r
Sys.setenv(OPENAI_API_KEY = "your-api-key")
```

### 3. Multi-API Functions

Tests integration with additional AI services:

- `gemini4R()` - Google Gemini chat (requires Gemini API key)
- `list_ionet_models()` - List available io.net models (requires io.net API key)
- `multiLLMviaionet()` - Multi-LLM execution (requires io.net API key)

**Setup**: Requires respective API keys
```r
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-key")
Sys.setenv(IONET_API_KEY = "your-ionet-key")
```

### 4. RStudio-Specific Functions

Tests functions that require RStudio environment:

- `addCommentCode()` - Add code comments
- `addRoxygenDescription()` - Add Roxygen documentation

**Setup**: Requires RStudio IDE (automatically skipped in non-RStudio environments)

## Example Output

```
=============================================================================
chatAI4R Package - Comprehensive Test Suite
=============================================================================

Environment Check:
  OpenAI API Key: ✓ Available
  Gemini API Key: ✗ Not set
  Replicate API Key: ✗ Not set
  io.net API Key: ✗ Not set
  RStudio: ✗ Not available

[INIT] Loading chatAI4R package...
[INIT] Package loaded successfully

=============================================================================
Starting Test Execution
=============================================================================

[TEST] Running: 01. ngsub
[PASS] 01. ngsub (0.01 sec)

[TEST] Running: 02. removeQuotations
[PASS] 02. removeQuotations (0.00 sec)

[TEST] Running: 03. slow_print_v2
[PASS] 03. slow_print_v2 (0.02 sec)

[TEST] Running: 04. chat4R
[PASS] 04. chat4R (1.23 sec)

[TEST] Running: 05. chat4Rv2
[PASS] 05. chat4Rv2 (1.15 sec)

[TEST] Running: 06. chat4R_history
[PASS] 06. chat4R_history (0.89 sec)

[TEST] Running: 07. textEmbedding
[PASS] 07. textEmbedding (0.45 sec)

[TEST] Running: 08. conversation4R
[PASS] 08. conversation4R (0.67 sec)

[TEST] Running: 09. TextSummary
[PASS] 09. TextSummary (1.02 sec)

[SKIP] 10. gemini4R - Gemini API key not set
[SKIP] 11. list_ionet_models - io.net API key not set
[SKIP] 12. multiLLMviaionet - io.net API key not set
[SKIP] 13. addCommentCode - Requires RStudio and OpenAI API key
[SKIP] 14. addRoxygenDescription - Requires RStudio and OpenAI API key

=============================================================================
Test Execution Complete
=============================================================================

Summary Statistics:
===================
Total Tests:     14
Passed:          9 (64.3%)
Failed:          0 (0.0%)
Skipped:         5 (35.7%)
Warnings:        0 (0.0%)
Total Duration:  5.44 seconds

Performance Report (Top 5 Slowest Tests):
==========================================
1. 04. chat4R - 1.23 sec
2. 05. chat4Rv2 - 1.15 sec
3. 09. TextSummary - 1.02 sec
4. 06. chat4R_history - 0.89 sec
5. 08. conversation4R - 0.67 sec

=============================================================================
✓ ALL TESTS PASSED
=============================================================================

Test results saved to: tests/test/test_results.Rds
```

## Test Result Statuses

| Status | Symbol | Meaning |
|--------|--------|---------|
| **PASS** | ✓ | Test executed successfully |
| **FAIL** | ✗ | Test failed with error |
| **SKIP** | ⊘ | Test skipped (missing requirements) |
| **WARN** | ⚠ | Test passed but generated warnings |

## Exit Codes

- **0** - All tests passed (success)
- **1** - One or more tests failed, or no tests were executed (failure)

## Analyzing Test Results

### Load Saved Results

```r
# Load test results
results <- readRDS("tests/test/test_results.Rds")

# View structure
str(results[[1]])
# $function_name: chr "01. ngsub"
# $status: chr "passed"
# $error: NULL
# $duration: num 0.01
```

### Extract Failed Tests

```r
# Get all failed tests
failed <- Filter(function(x) x$status == "failed", results)

# Print failure details
for (test in failed) {
  cat(sprintf("%s: %s\n", test$function_name, test$error))
}
```

### Calculate Statistics

```r
# Pass rate
pass_rate <- sum(sapply(results, function(x) x$status == "passed")) / length(results)
cat(sprintf("Pass Rate: %.1f%%\n", pass_rate * 100))

# Average duration
avg_duration <- mean(sapply(results, function(x) x$duration))
cat(sprintf("Average Test Duration: %.2f sec\n", avg_duration))

# Total duration
total_duration <- sum(sapply(results, function(x) x$duration))
cat(sprintf("Total Test Duration: %.2f sec\n", total_duration))
```

## Setup Instructions

### Minimal Setup (Utility Tests Only)

No API keys required. Run utility tests immediately:

```r
source("tests/test/run_all_tests.R")
```

**Expected**: 3 tests passed, 11 tests skipped

### Standard Setup (OpenAI Tests)

Set OpenAI API key for core functionality tests:

```r
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-key")
source("tests/test/run_all_tests.R")
```

**Expected**: 9 tests passed, 5 tests skipped

### Full Setup (All Tests)

Set all API keys for complete test coverage:

```r
# Required for core tests
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-key")

# Optional for extended tests
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-key")
Sys.setenv(IONET_API_KEY = "your-ionet-key")

source("tests/test/run_all_tests.R")
```

**Expected**: 12 tests passed, 2 tests skipped (RStudio functions)

### Persistent API Keys

Add to `~/.Renviron` for automatic loading:

```bash
OPENAI_API_KEY=sk-your-openai-key
GoogleGemini_API_KEY=your-gemini-key
IONET_API_KEY=your-ionet-key
```

Restart R session after editing `.Renviron`.

## CI/CD Integration

### GitHub Actions

Add to `.github/workflows/test.yml`:

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup R
        uses: r-lib/actions/setup-r@v2

      - name: Install dependencies
        run: |
          install.packages("remotes")
          remotes::install_deps(dependencies = TRUE)
        shell: Rscript {0}

      - name: Run comprehensive tests
        run: Rscript tests/test/run_all_tests.R
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          IONET_API_KEY: ${{ secrets.IONET_API_KEY }}
```

### Local CI Simulation

```bash
# Simulate CI environment
export OPENAI_API_KEY="your-key"
Rscript tests/test/run_all_tests.R
echo "Exit code: $?"
```

## Troubleshooting

### Issue: All Tests Skipped

**Symptom**:
```
Total Tests:     14
Skipped:         14 (100.0%)
```

**Cause**: No API keys configured

**Solution**:
```r
Sys.setenv(OPENAI_API_KEY = "sk-your-key")
source("tests/test/run_all_tests.R")
```

### Issue: API Rate Limit Errors

**Symptom**:
```
[FAIL] 04. chat4R - API rate limit exceeded (0.45 sec)
```

**Cause**: Too many API calls in short period

**Solutions**:
- Wait a few minutes and retry
- Use different API key with higher rate limits
- Run tests less frequently

### Issue: Connection Timeouts

**Symptom**:
```
[FAIL] 05. textEmbedding - Connection timeout (30.00 sec)
```

**Cause**: Network issues or API server problems

**Solutions**:
- Check internet connection
- Verify API service status
- Increase timeout in test code
- Retry later

### Issue: Tests Run But Don't Complete

**Symptom**: Script hangs without output

**Cause**: Interactive prompts or blocking operations

**Solution**: Run in non-interactive mode:
```bash
Rscript --vanilla tests/test/run_all_tests.R
```

## Extending the Test Suite

### Adding New Tests

1. Open `run_all_tests.R`
2. Add new test following this pattern:

```r
# Test: your_new_function
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. your_new_function", test_idx),
  'result <- your_new_function(arg1 = "value")
   stopifnot(is.character(result))
   stopifnot(nchar(result) > 0)'
)
test_idx <- test_idx + 1
```

3. For API-dependent tests, wrap in conditional:

```r
if (has_openai) {
  # Your test code here
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. your_new_function", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1
```

### Testing Multiple Scenarios

```r
# Test: function with multiple scenarios
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. myfunction (scenario 1)", test_idx),
  'result <- myfunction(param = "value1")
   stopifnot(result == "expected1")'
)
test_idx <- test_idx + 1

test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. myfunction (scenario 2)", test_idx),
  'result <- myfunction(param = "value2")
   stopifnot(result == "expected2")'
)
test_idx <- test_idx + 1
```

## Best Practices

### Before Commits

```bash
# Run full test suite before committing
Rscript tests/test/run_all_tests.R
git add -A
git commit -m "Your commit message"
```

### Before Releases

```bash
# Run with all API keys configured
export OPENAI_API_KEY="your-key"
export IONET_API_KEY="your-key"
Rscript tests/test/run_all_tests.R > release_test_results.txt 2>&1

# Review results
cat release_test_results.txt
```

### Performance Monitoring

```r
# Load and compare historical results
results_today <- readRDS("tests/test/test_results.Rds")
results_yesterday <- readRDS("tests/test/test_results_2025-10-28.Rds")

# Compare durations
compare_performance(results_today, results_yesterday)
```

## Architecture

### Test Runner Design

```
run_all_tests.R
├── Initialization
│   ├── Load chatAI4R package
│   ├── Check environment (API keys, RStudio)
│   └── Initialize result tracking
│
├── Test Execution
│   ├── run_test_safely() wrapper
│   │   ├── Error handling (tryCatch)
│   │   ├── Timing measurement
│   │   └── Result recording
│   │
│   └── Test categories
│       ├── Utility tests (no dependencies)
│       ├── Core API tests (OpenAI)
│       ├── Extended API tests (multi-API)
│       └── RStudio tests (conditional)
│
└── Reporting
    ├── Summary statistics
    ├── Failure details
    ├── Performance metrics
    ├── Save results (Rds)
    └── Exit with appropriate code
```

### Result Data Structure

```r
list(
  function_name = "01. ngsub",
  status = "passed",  # or "failed", "skipped", "warning"
  error = NULL,       # or error message string
  duration = 0.01     # execution time in seconds
)
```

## Version History

- **v1.1.0** (2025-10-29): Comprehensive test runner with detailed reporting
- **v1.0.0** (2025-07-01): Initial test examples (deprecated)

## License

Same as chatAI4R package (Artistic License 2.0)

## Support

For issues or questions:
- GitHub Issues: https://github.com/kumeS/chatAI4R/issues
- Package Documentation: https://kumes.github.io/chatAI4R/
