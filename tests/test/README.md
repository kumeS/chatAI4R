# chatAI4R Test Suite

Comprehensive automated testing framework for the chatAI4R package.

## Current Test Status

- **Coverage**: 52/52 functions testable (100% coverage target)
- **Base Tests**: 14 core functions (26.9% quick validation)
- **Extended Tests**: 50+ functions via Phase 1-5 (96% comprehensive coverage)
- **Success Rate**: 100% pass rate when API keys available
- **Test Files**: 6 test suites + 1 helper library

## Test File Overview

### Core Test Files

| File | Purpose | Functions Tested | Execution Time |
|------|---------|------------------|----------------|
| **`run_all_tests.R`** | Main test runner | 14 core functions | ~9 sec with APIs |
| **`phase1_tests.R`** | Phase 1: API & Vision | 17 functions | ~15 sec |
| **`phase2_tests.R`** | Phase 2: Code Gen & Text | 14 functions | ~12 sec |
| **`phase3_tests.R`** | Phase 3: Conversation & Utils | 9 functions | ~8 sec |
| **`phase4_tests.R`** | Phase 4: Error Detection | 5 functions | ~6 sec |
| **`phase5_tests.R`** | Phase 5: Advanced Features | 5 functions | ~10 sec |

### Support Files

| File | Purpose | Status |
|------|---------|--------|
| **`helper-mocks.R`** | Mock functions & test utilities | 📋 Available but not currently used in tests |

## What Are These Files For?

### `run_all_tests.R` - Main Test Runner 🎯

**Purpose**: Primary test suite that validates core chatAI4R functionality.

**What it tests**:
- **3 utility functions** (no API needed): `ngsub()`, `removeQuotations()`, `slow_print_v2()`
- **8 OpenAI functions**: `chat4R()`, `chat4Rv2()`, `chat4R_history()`, `textEmbedding()`, `conversation4R()`, `TextSummary()`, `addCommentCode()`, `addRoxygenDescription()`
- **2 multi-API functions**: `gemini4R()`, `multiLLMviaionet()`
- **1 utility function**: `list_ionet_models()`

**Total**: 14 functions covering core functionality

**When to use**:
- ✅ Before committing code changes
- ✅ In CI/CD pipelines
- ✅ Quick validation after installation
- ✅ Daily development testing

**Execution time**: ~9 seconds with API keys, <1 second without

### `phase1_tests.R` through `phase5_tests.R` - Extended Coverage 📦

**Purpose**: Comprehensive test suites providing 96%+ coverage of all package functions.

**Phase breakdown**:

| Phase | Category | Functions | Key Tests |
|-------|----------|-----------|-----------|
| **Phase 1** | API & Vision | 17 | `completions4R()`, `DifyChat4R()`, `vision4R()`, `geminiGrounding4R()`, TTS functions |
| **Phase 2** | Code Gen & Text | 14 | `createRcode()`, `OptimizeRcode()`, `chat4R_streaming()`, text conversion |
| **Phase 3** | Conversation & Utils | 9 | `discussion_flow_v2()`, `textFileInput4ai()`, keyword extraction |
| **Phase 4** | Error Detection | 5 | `checkErrorDet()`, `checkErrorDet_JP()`, proofreading |
| **Phase 5** | Advanced Features | 5 | `designPackage()`, `createSpecifications4R()`, package development |

**When to use**:
- ✅ Before major releases (comprehensive validation)
- ✅ When modifying API integrations
- ✅ For full regression testing
- ✅ To validate all function categories

**Execution time**: ~50 seconds total for all phases

### `helper-mocks.R` - Test Utilities 🛠️

**Purpose**: Support library providing mock functions and test helpers.

**What it provides**:
- `with_mock_clipboard()` - Mock clipboard operations for testing
- `with_mock_rstudio()` - Mock RStudio API for testing outside IDE
- `create_test_image()` - Generate temporary test images
- `cleanup_test_files()` - Clean up test artifacts

**Current status**:
- ⚠️ Mock functions are defined but **not currently used** in any test files
- Tests currently skip clipboard/RStudio-dependent functions instead of mocking
- Available for future test enhancements

## Quick Start

### Daily Development (Recommended)

```r
# Run core test suite (11 functions, ~9 seconds)
source("tests/test/run_all_tests.R")
results <- run_all_tests()
```

### With API Keys (Explicit)

```r
# Recommended: Pass API keys as arguments
source("tests/test/run_all_tests.R")
results <- run_all_tests(
  openai_key = "sk-your-openai-key",
  gemini_key = "your-gemini-key",
  ionet_key = "your-ionet-key"
)
```

### With API Keys (Environment Variables)

```r
# Alternative: Use environment variables
Sys.setenv(OPENAI_API_KEY = "sk-your-openai-key")
Sys.setenv(GoogleGemini_API_KEY = "your-gemini-key")
Sys.setenv(IONET_API_KEY = "your-ionet-key")

source("tests/test/run_all_tests.R")
results <- run_all_tests()
```

### Comprehensive Testing (All Phases)

```r
# Run base + all phase tests (52 functions, ~60 seconds)
source("tests/test/run_all_tests.R")
base_results <- run_all_tests()

source("tests/test/phase1_tests.R")
p1_results <- run_phase1_tests()

source("tests/test/phase2_tests.R")
p2_results <- run_phase2_tests()

source("tests/test/phase3_tests.R")
p3_results <- run_phase3_tests()

source("tests/test/phase4_tests.R")
p4_results <- run_phase4_tests()

source("tests/test/phase5_tests.R")
p5_results <- run_phase5_tests()
```

### Command Line Execution

```bash
# Run tests from command line
cd /path/to/chatAI4R
Rscript tests/test/run_all_tests.R

# Save output to file
Rscript tests/test/run_all_tests.R > test_results.txt 2>&1
```

## Example Output

```
=============================================================================
chatAI4R Package - Comprehensive Test Suite
=============================================================================

Environment Check:
  OpenAI API Key: ✓ Available
  Gemini API Key: ✓ Available
  Replicate API Key: ✗ Not set
  io.net API Key: ✓ Available
  DeepL API Key: ✗ Not set
  RStudio: ✗ Not available

[INIT] Loading chatAI4R package...
[INIT] Package loaded successfully

=============================================================================
Starting Test Execution
=============================================================================

[TEST] Running: 01. ngsub
[PASS] 01. ngsub (0.00 sec)
[TEST] Running: 02. removeQuotations
[PASS] 02. removeQuotations (0.00 sec)
[TEST] Running: 03. slow_print_v2
[PASS] 03. slow_print_v2 (0.05 sec)
[TEST] Running: 04. chat4R
[PASS] 04. chat4R (1.46 sec)
[TEST] Running: 05. chat4Rv2
[PASS] 05. chat4Rv2 (1.12 sec)
[TEST] Running: 06. chat4R_history
[PASS] 06. chat4R_history (1.18 sec)
[TEST] Running: 07. textEmbedding
[PASS] 07. textEmbedding (1.38 sec)
[TEST] Running: 08. conversation4R
[PASS] 08. conversation4R (0.72 sec)
[SKIP] 09. TextSummary - Requires interactive menu selection
[TEST] Running: 10. gemini4R
[PASS] 10. gemini4R (0.74 sec)
[TEST] Running: 11. list_ionet_models
[PASS] 11. list_ionet_models (0.00 sec)
[TEST] Running: 12. multiLLMviaionet
[PASS] 12. multiLLMviaionet (2.26 sec)
[SKIP] 13. addCommentCode - Requires RStudio and OpenAI API key
[SKIP] 14. addRoxygenDescription - Requires RStudio and OpenAI API key

=============================================================================
Test Execution Complete
=============================================================================

Summary Statistics:
===================
Total Tests:     14
Passed:          11 (78.6%)
Failed:          0 (0.0%)
Skipped:         3 (21.4%)
Warnings:        0 (0.0%)
Total Duration:  8.91 seconds

Performance Report (Top 5 Slowest Tests):
==========================================
1. 12. multiLLMviaionet - 2.26 sec
2. 04. chat4R - 1.46 sec
3. 07. textEmbedding - 1.38 sec
4. 06. chat4R_history - 1.18 sec
5. 05. chat4Rv2 - 1.12 sec

=============================================================================
✓ ALL TESTS PASSED
=============================================================================
```

## Test Features

### ✅ Comprehensive Coverage
- **Base tests**: 14 core functions (26.9% quick validation)
- **Phase tests**: 50+ functions across all categories (96% coverage)
- **Total**: 52/52 exported functions testable
- Covers utilities, APIs, text processing, code generation, conversation management

### ✅ Error Resilience
- Continues execution even when individual tests fail
- Captures detailed error messages for debugging
- Never stops entire suite due to one failure

### ✅ Smart Skipping
- Automatically detects available API keys
- Skips tests requiring unavailable resources
- Clear reporting of why tests were skipped

### ✅ Detailed Reporting
- Real-time status ([PASS]/[FAIL]/[SKIP])
- Summary statistics (pass rate, duration)
- Failed test details with error messages
- Performance metrics (top 5 slowest tests)

### ✅ CI/CD Ready
- Returns proper exit codes (0 = success, 1 = failure)
- Easy GitHub Actions integration
- Returns structured R list objects with detailed results

## API Key Configuration

### Required API Keys by Test Suite

| Test Suite | OpenAI | Gemini | io.net | Replicate | DeepL |
|------------|--------|--------|--------|-----------|-------|
| **Base Tests** | ✓ (6 tests) | ✓ (1 test) | ✓ (2 tests) | ✗ | ✗ |
| **Phase 1** | ✓ | ✓ | ✗ | ✓ | ✗ |
| **Phase 2** | ✓ | ✗ | ✓ | ✗ | ✗ |
| **Phase 3** | ✓ | ✗ | ✗ | ✗ | ✓ |
| **Phase 4** | ✓ | ✗ | ✗ | ✗ | ✗ |
| **Phase 5** | ✓ | ✓ | ✗ | ✓ | ✗ |

### Setting API Keys

**Method 1: Function Arguments (Recommended)**
```r
results <- run_all_tests(
  openai_key = "sk-your-key",
  gemini_key = "your-key",
  ionet_key = "your-key"
)
```

**Method 2: Environment Variables**
```r
Sys.setenv(OPENAI_API_KEY = "sk-your-key")
Sys.setenv(GoogleGemini_API_KEY = "your-key")
Sys.setenv(IONET_API_KEY = "your-key")
Sys.setenv(Replicate_API_KEY = "your-key")
Sys.setenv(DeepL_API_KEY = "your-key")
```

**Method 3: Persistent `.Renviron`**
```bash
# Add to ~/.Renviron
OPENAI_API_KEY=sk-your-key
GoogleGemini_API_KEY=your-key
IONET_API_KEY=your-key
```

## Analyzing Test Results

### Return Object Structure

```r
results <- run_all_tests()
str(results)
# List of 5
#  $ test_results  : List of detailed test results
#  $ summary       : List with pass/fail statistics  
#  $ failed_tests  : List of tests that failed
#  $ warnings      : List of tests with warnings
#  $ environment   : List of API key availability
```

### Access Summary

```r
# View summary
print(results$summary)
# $total_tests   : int 14
# $passed        : int 11
# $failed        : int 0
# $skipped       : int 3
# $pass_rate     : num 0.786
# $total_duration: num 8.91

# Check pass rate
cat(sprintf("Pass Rate: %.1f%%\n", results$summary$pass_rate * 100))
```

### Check Failed Tests

```r
if (length(results$failed_tests) > 0) {
  cat("Failed Tests:\n")
  for (test in results$failed_tests) {
    cat(sprintf("  %s: %s\n", test$function_name, test$error))
  }
} else {
  cat("✓ All tests passed!\n")
}
```

## CI/CD Integration

### GitHub Actions Example

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
      
      - name: Run tests
        run: Rscript tests/test/run_all_tests.R
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          GoogleGemini_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          IONET_API_KEY: ${{ secrets.IONET_API_KEY }}
```

## Troubleshooting

### Issue: All Tests Skipped

**Symptom**: `Skipped: 11 (78.6%)`

**Cause**: No API keys configured

**Solution**:
```r
Sys.setenv(OPENAI_API_KEY = "sk-your-key")
results <- run_all_tests()
```

### Issue: API Rate Limit Errors

**Symptom**: `[FAIL] chat4R - API rate limit exceeded`

**Solutions**:
- Wait a few minutes and retry
- Use different API key with higher limits
- Run tests less frequently

### Issue: Connection Timeouts

**Symptom**: `[FAIL] textEmbedding - Connection timeout`

**Solutions**:
- Check internet connection
- Verify API service status
- Retry later

## Best Practices

### Before Commits
```bash
# Always run base tests before committing
Rscript tests/test/run_all_tests.R
git add -A
git commit -m "Your commit message"
```

### Before Releases
```bash
# Run comprehensive tests
Rscript tests/test/run_all_tests.R > test_results.txt 2>&1

# Run all phases
Rscript -e "source('tests/test/phase1_tests.R'); run_phase1_tests()"
Rscript -e "source('tests/test/phase2_tests.R'); run_phase2_tests()"
# ... continue for all phases

# Review results
cat test_results.txt
```

## All Exported Functions (52 total)

<details>
<summary>Click to expand full function list</summary>

1. `ngsub()` ✅ Base
2. `removeQuotations()` ✅ Base
3. `slow_print_v2()` ✅ Base
4. `chat4R()` ✅ Base
5. `chat4Rv2()` ✅ Base
6. `chat4R_history()` ✅ Base
7. `textEmbedding()` ✅ Base
8. `conversation4R()` ✅ Base
9. `TextSummary()` ✅ Base
10. `gemini4R()` ✅ Base
11. `list_ionet_models()` ✅ Base
12. `multiLLMviaionet()` ✅ Base
13. `addCommentCode()` ✅ Base (RStudio)
14. `addRoxygenDescription()` ✅ Base (RStudio)
15. `completions4R()` 📦 Phase 1
16. `DifyChat4R()` 📦 Phase 1
17. `TextSummaryAsBullet()` 📦 Phase 1
18. `proofreadEnglishText()` 📦 Phase 1
19. `speakInEN()` 📦 Phase 1
20. `speakInJA()` 📦 Phase 1
21. `speakInJA_v2()` 📦 Phase 1
22. `createImagePrompt_v1()` 📦 Phase 1
23. `createImagePrompt_v2()` 📦 Phase 1
24. `geminiGrounding4R()` 📦 Phase 1
25. `interpretResult()` 📦 Phase 1
26. `discussion_flow_v1()` 📦 Phase 1
27. `textFileInput4ai()` 📦 Phase 1
28. `replicatellmAPI4R()` 📦 Phase 1
29. `vision4R()` 📦 Phase 1
30. `autocreateFunction4R()` 📦 Phase 1
31. `createRcode()` 📦 Phase 2
32. `createRfunction()` 📦 Phase 2
33. `OptimizeRcode()` 📦 Phase 2
34. `RcodeImprovements()` 📦 Phase 2
35. `extractKeywords()` 📦 Phase 2
36. `proofreadText()` 📦 Phase 2
37. `revisedText()` 📦 Phase 2
38. `enrichTextContent()` 📦 Phase 2
39. `refresh_ionet_models()` 📦 Phase 2
40. `searchFunction()` 📦 Phase 2
41. `supportIdeaGeneration()` 📦 Phase 2
42. `convertBullet2Sentence()` 📦 Phase 2
43. `chat4R_streaming()` 📦 Phase 2
44. `discussion_flow_v2()` 📦 Phase 2
45. `checkErrorDet()` 📦 Phase 4
46. `checkErrorDet_JP()` 📦 Phase 4
47. `convertRscript2Function()` 📦 Phase 4
48. `convertScientificLiterature()` 📦 Phase 4
49. `createEBAYdes()` 📦 Phase 4
50. `createSpecifications4R()` 📦 Phase 5
51. `designPackage()` 📦 Phase 5

</details>

## License

Same as chatAI4R package (Artistic License 2.0)

## Support

- GitHub Issues: https://github.com/kumeS/chatAI4R/issues
- Package Documentation: https://kumes.github.io/chatAI4R/
