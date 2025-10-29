# chatAI4R Test Suite

Comprehensive testing framework for the chatAI4R package.

## Overview

This test suite provides automated testing for all chatAI4R functions with detailed reporting and error tracking.

## Files

- **`run_all_tests.R`**: Main test runner script with comprehensive reporting
- **`all_examples_combined.R`**: Original combined examples file (reference)
- **`test_results.Rds`**: Saved test results (generated after running tests)

## Features

✅ **Comprehensive Testing**: Tests all available functions systematically
✅ **Error Resilience**: Continues execution even when tests fail
✅ **Detailed Reporting**: Shows exactly which tests passed/failed and why
✅ **Performance Metrics**: Tracks execution time for each test
✅ **Smart Skipping**: Automatically skips tests that require unavailable API keys or RStudio
✅ **Summary Statistics**: Provides clear pass/fail rates and counts

## Usage

### Basic Usage

```r
# From R console
source("tests/test/run_all_tests.R")
```

### From Command Line

```bash
# Run tests from command line
Rscript tests/test/run_all_tests.R

# Run tests and save output
Rscript tests/test/run_all_tests.R > test_output.txt 2>&1
```

### With CI/CD

```yaml
# GitHub Actions example
- name: Run chatAI4R tests
  run: |
    Rscript tests/test/run_all_tests.R
```

## Requirements

### Required

- R (>= 4.2.0)
- chatAI4R package installed

### Optional (for full test coverage)

API Keys (set as environment variables):

```r
Sys.setenv(OPENAI_API_KEY = "your-openai-key")
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-key")
Sys.setenv(Replicate_API_KEY = "your-replicate-key")
Sys.setenv(IONET_API_KEY = "your-ionet-key")
```

Or set in `.Renviron`:

```bash
OPENAI_API_KEY=your-openai-key
GoogleGemini_API_KEY=your-gemini-key
Replicate_API_KEY=your-replicate-key
IONET_API_KEY=your-ionet-key
```

## Output Format

### Console Output

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

[TEST] Running: 03. chat4R
[PASS] 03. chat4R (1.23 sec)

[TEST] Running: 04. textEmbedding
[FAIL] 04. textEmbedding - API rate limit exceeded (0.45 sec)

[SKIP] 05. gemini4R - Gemini API key not set

=============================================================================
Test Execution Complete
=============================================================================

Summary Statistics:
===================
Total Tests:     15
Passed:          10 (66.7%)
Failed:          2 (13.3%)
Skipped:         3 (20.0%)
Warnings:        0 (0.0%)
Total Duration:  12.34 seconds

Failed Tests Details:
=====================

[04] 04. textEmbedding
     Error: API rate limit exceeded
     Duration: 0.45 sec

[08] 08. vision4R
     Error: Invalid image URL
     Duration: 0.32 sec

Performance Report (Top 5 Slowest Tests):
==========================================
1. 03. chat4R - 1.23 sec
2. 07. chat4R_history - 0.89 sec
3. 05. conversation4R - 0.67 sec
4. 04. textEmbedding - 0.45 sec
5. 02. removeQuotations - 0.00 sec

=============================================================================
✗ TESTS FAILED (10/15 passed)
=============================================================================

Test results saved to: tests/test/test_results.Rds
```

## Test Categories

### 1. Utility Functions (No API Required)
- `ngsub()` - Text normalization
- `removeQuotations()` - Quote removal
- `slow_print_v2()` - Slow printing

### 2. Core API Functions (OpenAI)
- `chat4R()` - Basic chat
- `chat4Rv2()` - Enhanced chat
- `chat4R_history()` - Chat with history
- `textEmbedding()` - Text embeddings
- `conversation4R()` - Conversation management
- `TextSummary()` - Text summarization

### 3. Multi-API Functions
- `gemini4R()` - Google Gemini (requires Gemini API key)
- `multiLLMviaionet()` - io.net multi-LLM (requires io.net API key)
- `list_ionet_models()` - List io.net models

### 4. RStudio-Specific Functions
- `addCommentCode()` - Add code comments (RStudio only)
- `addRoxygenDescription()` - Add Roxygen docs (RStudio only)

## Interpreting Results

### Exit Codes

- **0**: All tests passed
- **1**: One or more tests failed or no tests were executed

### Test Statuses

- **PASS**: Test executed successfully
- **FAIL**: Test failed with an error
- **SKIP**: Test skipped (missing requirements)
- **WARN**: Test passed but generated warnings

## Analyzing Test Results

Load saved results for analysis:

```r
# Load test results
results <- readRDS("tests/test/test_results.Rds")

# View specific test result
results[[1]]  # First test

# Get all failed tests
failed <- Filter(function(x) x$status == "failed", results)
lapply(failed, function(x) c(x$function_name, x$error))

# Calculate pass rate
pass_rate <- sum(sapply(results, function(x) x$status == "passed")) / length(results)
print(sprintf("Pass Rate: %.1f%%", pass_rate * 100))
```

## Troubleshooting

### All Tests Skipped

**Problem**: No API keys are set

**Solution**: Set at least the OpenAI API key:
```r
Sys.setenv(OPENAI_API_KEY = "your-api-key")
```

### API Rate Limit Errors

**Problem**: Too many API calls in short time

**Solution**:
- Wait a few minutes and try again
- Reduce number of tests
- Use different API keys for different test runs

### RStudio Function Tests Fail

**Problem**: Tests requiring RStudio fail outside RStudio

**Solution**: These tests are automatically skipped when not in RStudio. This is expected behavior.

## Adding New Tests

To add tests for new functions:

1. Open `run_all_tests.R`
2. Add new test block following the pattern:

```r
# Test: your_function
test_results[[test_idx]] <- run_test_safely(
  sprintf("%02d. your_function", test_idx),
  'result <- your_function(param = "value")
   stopifnot(is.character(result))'
)
test_idx <- test_idx + 1
```

3. For functions requiring API keys, wrap in conditional:

```r
if (has_openai) {
  # Your test here
} else {
  test_results[[test_idx]] <- run_test_safely(
    sprintf("%02d. your_function", test_idx),
    NULL,
    skip_reason = "OpenAI API key not set"
  )
}
test_idx <- test_idx + 1
```

## Best Practices

1. **Set API Keys**: Configure API keys for comprehensive testing
2. **Run Regularly**: Run tests before commits and releases
3. **Check Results**: Review failed tests and fix issues
4. **Update Tests**: Keep tests synchronized with function changes
5. **Monitor Performance**: Watch for performance regressions

## Integration with GitHub Actions

The test runner integrates seamlessly with the R-CMD-check workflow:

```yaml
- name: Run comprehensive tests
  run: Rscript tests/test/run_all_tests.R
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

## License

Same as chatAI4R package (Artistic License 2.0)
