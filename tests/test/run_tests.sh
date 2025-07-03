#!/bin/bash

# =============================================================================
# chatAI4R Package Test Runner v1.0.0
# =============================================================================
# Comprehensive testing tool for chatAI4R package with multi-API support
# Tests 25+ functions across utility, API, and advanced functionality
# 
# Features:
# • No-API utility testing for quick validation
# • OpenAI API integration testing (chat4R, textEmbedding, vision4R, etc.)
# • Multi-LLM testing via io.net API (NEW in v1.0.0)
# • Extended API testing (Gemini, Replicate, Dify)
# • Comprehensive error handling and logging
# 
# Usage: ./run_tests.sh --help
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
API_KEY=""
GEMINI_KEY=""
REPLICATE_KEY=""
DIFY_KEY=""
DEEPL_KEY=""
IONET_KEY=""
MODE="utilities"
VERBOSE=true

# Help function
show_help() {
    echo "=========================================="
    echo "  chatAI4R Package Test Runner v1.0.0"
    echo "=========================================="
    echo ""
    echo "DESCRIPTION:"
    echo "  Comprehensive testing tool for chatAI4R package with multi-API support."
    echo "  Tests 25+ functions across utility, API, and advanced functionality."
    echo ""
    echo "USAGE:"
    echo "  $0 [OPTIONS]"
    echo ""
    echo "API KEY OPTIONS:"
    echo "  -k, --api-key KEY      🔑 OpenAI API key (sk-...)"
    echo "                         └── Required for: chat4R, textEmbedding, vision4R, etc."
    echo "  -g, --gemini-key KEY   🔑 Google Gemini API key"  
    echo "                         └── Required for: gemini4R, geminiGrounding4R"
    echo "  -r, --replicate-key KEY 🔑 Replicate API token"
    echo "                         └── Required for: replicatellmAPI4R (Llama models)"
    echo "  -d, --dify-key KEY     🔑 Dify API key"
    echo "                         └── Required for: DifyChat4R (workflow AI)"
    echo "  -l, --deepl-key KEY    🔑 DeepL API key"
    echo "                         └── Required for: discussion flow translation"
    echo "  -i, --ionet-key KEY    🔑 io.net API key (NEW in v1.0.0)"
    echo "                         └── Required for: multiLLMviaionet, multiLLM_random5/10"
    echo ""
    echo "TEST MODE OPTIONS:"
    echo "  -m, --mode MODE        Test execution mode:"
    echo "    utilities            📦 Utility functions only (no API key needed)"
    echo "                         └── Tests: ngsub, removeQuotations, slow_print_v2"
    echo "    api-only             🌐 Basic API functions only (OpenAI key required)" 
    echo "                         └── Tests: chat4R, textEmbedding, vision4R, etc."
    echo "    full                 🚀 All utility + API functions (recommended)"
    echo "                         └── Tests: 25+ functions with OpenAI integration"
    echo "    extended             ⭐ Full + multi-API + advanced features"
    echo "                         └── Tests: Multi-LLM, Gemini, Replicate, file processing"
    echo ""
    echo "OTHER OPTIONS:"
    echo "  -q, --quiet            🔇 Quiet mode (minimal output)"
    echo "  -h, --help             ❓ Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  # Quick start - utility tests only (no API key needed)"
    echo "  $0"
    echo ""
    echo "  # Basic API testing with OpenAI"
    echo "  $0 --api-key sk-your-openai-key --mode full"
    echo ""
    echo "  # Advanced multi-API testing (v1.0.0 features)"
    echo "  $0 --api-key sk-openai-key \\"
    echo "     --ionet-key your-ionet-key \\"
    echo "     --gemini-key your-gemini-key \\"
    echo "     --mode extended"
    echo ""
    echo "  # Multi-LLM testing only (NEW: io.net integration)"
    echo "  $0 --api-key sk-openai-key \\"
    echo "     --ionet-key your-ionet-key \\"
    echo "     --mode extended"
    echo ""
    echo "  # Silent execution for CI/CD"
    echo "  $0 --api-key sk-your-key --mode full --quiet"
    echo ""
    echo "NOTES:"
    echo "  • Set API keys as environment variables for persistence"
    echo "  • Extended mode requires multiple API keys for full coverage"
    echo "  • Test results are logged with timestamps and detailed error info"
    echo "  • Use utilities mode for quick package validation without API costs"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--api-key)
            API_KEY="$2"
            shift 2
            ;;
        -g|--gemini-key)
            GEMINI_KEY="$2"
            shift 2
            ;;
        -r|--replicate-key)
            REPLICATE_KEY="$2"
            shift 2
            ;;
        -d|--dify-key)
            DIFY_KEY="$2"
            shift 2
            ;;
        -l|--deepl-key)
            DEEPL_KEY="$2"
            shift 2
            ;;
        -i|--ionet-key)
            IONET_KEY="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -q|--quiet)
            VERBOSE=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Print banner
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  chatAI4R Package Test Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo -e "${RED}Error: R is not installed or not in PATH${NC}"
    echo "Please install R and try again."
    exit 1
fi

# Check if Rscript is available
if ! command -v Rscript &> /dev/null; then
    echo -e "${RED}Error: Rscript is not available${NC}"
    echo "Please ensure R is properly installed."
    exit 1
fi

# Check if test script exists
if [ ! -f "test_execution.R" ] && [ ! -f "tests/test_execution.R" ]; then
    echo -e "${RED}Error: test_execution.R not found${NC}"
    echo "Please ensure you are in the project root directory or tests directory."
    exit 1
fi

# Determine the correct test script path
if [ -f "test_execution.R" ]; then
    TEST_SCRIPT="test_execution.R"
elif [ -f "tests/test_execution.R" ]; then
    TEST_SCRIPT="tests/test_execution.R"
else
    echo -e "${RED}Error: test_execution.R not found${NC}"
    exit 1
fi

# Validate mode
case $MODE in
    utilities|api-only|full|extended)
        ;;
    *)
        echo -e "${RED}Error: Invalid mode '$MODE'${NC}"
        echo "Valid modes: utilities, api-only, full, extended"
        exit 1
        ;;
esac

# Show configuration
echo -e "${YELLOW}Configuration:${NC}"
echo "  Mode: $MODE"

# Show API key status
if [ -n "$API_KEY" ]; then
    echo "  OpenAI API Key: ${API_KEY:0:10}... (provided)"
else
    echo "  OpenAI API Key: Not provided"
fi

if [ -n "$GEMINI_KEY" ]; then
    echo "  Gemini API Key: ${GEMINI_KEY:0:10}... (provided)"
else
    echo "  Gemini API Key: Not provided"
fi

if [ -n "$REPLICATE_KEY" ]; then
    echo "  Replicate API Key: ${REPLICATE_KEY:0:10}... (provided)"
else
    echo "  Replicate API Key: Not provided"
fi

if [ -n "$DIFY_KEY" ]; then
    echo "  Dify API Key: ${DIFY_KEY:0:10}... (provided)"
else
    echo "  Dify API Key: Not provided"
fi

if [ -n "$DEEPL_KEY" ]; then
    echo "  DeepL API Key: ${DEEPL_KEY:0:10}... (provided)"
else
    echo "  DeepL API Key: Not provided"
fi

if [ -n "$IONET_KEY" ]; then
    echo "  io.net API Key: ${IONET_KEY:0:10}... (provided)"
else
    echo "  io.net API Key: Not provided"
fi

echo "  Verbose: $VERBOSE"
echo ""

# Validate API key format if provided
if [ -n "$API_KEY" ]; then
    if [[ ! $API_KEY =~ ^sk- ]]; then
        echo -e "${YELLOW}Warning: API key doesn't start with 'sk-'${NC}"
        echo "OpenAI API keys typically start with 'sk-'"
        echo ""
    fi
fi

# Set environment variables for API keys
if [ -n "$API_KEY" ]; then
    export OPENAI_API_KEY="$API_KEY"
fi

if [ -n "$GEMINI_KEY" ]; then
    export GoogleGemini_API_KEY="$GEMINI_KEY"
fi

if [ -n "$REPLICATE_KEY" ]; then
    export Replicate_API_KEY="$REPLICATE_KEY"
fi

if [ -n "$DIFY_KEY" ]; then
    export DIFY_API_KEY="$DIFY_KEY"
fi

if [ -n "$DEEPL_KEY" ]; then
    export DeepL_API_KEY="$DEEPL_KEY"
fi

if [ -n "$IONET_KEY" ]; then
    export IONET_API_KEY="$IONET_KEY"
fi

# Build Rscript command
CMD="Rscript $TEST_SCRIPT --mode=$MODE"
if [ -n "$API_KEY" ]; then
    CMD="$CMD --api-key=\"$API_KEY\""
fi

# Show what will be executed
if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Executing:${NC} $CMD"
    echo ""
fi

# Run the test
echo -e "${GREEN}Starting tests...${NC}"
echo ""

# Execute the test script
if eval $CMD; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Tests completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Show log file location
    LATEST_LOG=$(ls -t test_results_*.log 2>/dev/null | head -n1)
    if [ -n "$LATEST_LOG" ]; then
        echo -e "${BLUE}Log file:${NC} $LATEST_LOG"
    fi
    
    LATEST_JSON=$(ls -t test_results_*_details.json 2>/dev/null | head -n1)
    if [ -n "$LATEST_JSON" ]; then
        echo -e "${BLUE}Details:${NC} $LATEST_JSON"
    fi
    
    exit 0
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  Tests completed with failures!${NC}"
    echo -e "${RED}========================================${NC}"
    
    # Show log file location
    LATEST_LOG=$(ls -t test_results_*.log 2>/dev/null | head -n1)
    if [ -n "$LATEST_LOG" ]; then
        echo -e "${BLUE}Check log file:${NC} $LATEST_LOG"
        echo ""
        echo -e "${YELLOW}Last few lines of log:${NC}"
        tail -10 "$LATEST_LOG"
    fi
    
    exit 1
fi