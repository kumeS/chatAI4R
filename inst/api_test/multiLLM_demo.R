# chatAI4R Package - Multi-LLM via io.net API Demo
# ==================================================
# 
# This file demonstrates how to use the new multiLLMviaionet() function
# to execute multiple LLM models simultaneously via io.net API
#
# Author: Satoshi Kume
# Date: 2025-01-01

# Load the chatAI4R package
library(chatAI4R)

# ==============================================================================
# SETUP: API Key Configuration
# ==============================================================================

# Set your io.net API key (replace with your actual key)
# Sys.setenv(IONET_API_KEY = "your_ionet_api_key_here")

# Verify API key is set
if (Sys.getenv("IONET_API_KEY") == "") {
  stop("Please set your IONET_API_KEY environment variable first!")
}

# ==============================================================================
# EXAMPLE 1: List all available models
# ==============================================================================

cat("📋 Available io.net models:\n")
all_models <- list_ionet_models()
print(all_models)
cat("\nTotal models available:", length(all_models), "\n\n")

# ==============================================================================
# EXAMPLE 2: Show detailed model information
# ==============================================================================

cat("📊 Detailed model information:\n")
detailed_info <- list_ionet_models(detailed = TRUE)
print(detailed_info)

# ==============================================================================
# EXAMPLE 3: Basic multi-LLM execution with specific models
# ==============================================================================

cat("\n🎯 Example 3: Multi-LLM execution with selected models\n")
selected_models <- c(
  "deepseek-ai/DeepSeek-R1",               # Latest reasoning model
  "meta-llama/Llama-3.3-70B-Instruct",    # Meta's latest model
  "Qwen/Qwen3-235B-A22B-FP8",             # Alibaba's latest MoE model
  "microsoft/phi-4",                       # Microsoft's latest SLM
  "mistralai/Mistral-Large-Instruct-2411" # Mistral's latest model
)

prompt <- "Explain the concept of artificial intelligence in simple terms."

result <- multiLLMviaionet(
  prompt = prompt,
  models = selected_models,
  max_tokens = 200,
  temperature = 0.7,
  verbose = TRUE
)

# Display results
cat("\n📊 Execution Summary:\n")
print(result$summary)

cat("\n📝 Sample responses:\n")
for (i in 1:min(3, length(result$results))) {
  model_result <- result$results[[i]]
  if (model_result$success) {
    cat("\n🤖 Model:", model_result$model, "\n")
    cat("Response:", substr(model_result$response, 1, 200), "...\n")
    cat("Execution time:", round(model_result$execution_time, 2), "seconds\n")
  }
}

# ==============================================================================
# EXAMPLE 4: Coding Task with Specialized Models
# ==============================================================================

cat("\n\n🚀 EXAMPLE 4: Coding Task with Specialized Models\n")
cat("===============================================\n\n")

# Coding-focused prompt
prompt2 <- "Write a Python function to implement binary search with detailed comments and error handling."

# Select models good for coding
coding_models <- c(
  "Qwen/Qwen2.5-Coder-32B-Instruct",      # Specialized coding model
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",  # Reasoning model
  "microsoft/phi-4"                        # Compact high-performance
)

result2 <- multiLLMviaionet(
  prompt = prompt2,
  models = coding_models,
  max_tokens = 1500,
  temperature = 0.3,  # Lower temperature for more deterministic code
  streaming = FALSE,
  verbose = TRUE
)

print(result2)

# ==============================================================================
# EXAMPLE 5: Random Model Selection
# ==============================================================================

cat("\n\n🚀 EXAMPLE 5: Random Model Selection\n")
cat("==================================\n\n")

# Mathematical problem
prompt3 <- "Solve this step by step: If a train travels 120 km in 1.5 hours, and then 200 km in 2 hours, what is the average speed for the entire journey?"

# Let the function randomly select models
result3 <- multiLLMviaionet(
  prompt = prompt3,
  models = list_ionet_models(),  # All available models
  max_models = 4,
  random_selection = TRUE,
  temperature = 0.1,  # Very deterministic for math
  verbose = TRUE
)

print(result3)

# ==============================================================================
# EXAMPLE 6: Model Categories Exploration
# ==============================================================================

cat("\n\n🚀 EXAMPLE 6: Model Categories Exploration\n")
cat("========================================\n\n")

# Explore available models by category
cat("📋 Available Model Categories:\n\n")

categories <- c("llama", "deepseek", "qwen", "phi", "mistral", "specialized")

for (cat in categories) {
  models <- list_ionet_models(cat)
  cat("🔸", toupper(cat), "models (", length(models), "):\n")
  for (model in head(models, 3)) {  # Show first 3
    cat("   -", model, "\n")
  }
  if (length(models) > 3) {
    cat("   ... and", length(models) - 3, "more\n")
  }
  cat("\n")
}

# ==============================================================================
# EXAMPLE 7: Performance Comparison
# ==============================================================================

cat("\n\n🚀 EXAMPLE 7: Performance Comparison\n")
cat("==================================\n\n")

# Simple prompt for performance testing
prompt6 <- "List 5 benefits of renewable energy."

# Test small vs large models
performance_models <- c(
  "Qwen/Qwen2.5-1.5B-Instruct",           # Small model
  "microsoft/Phi-3.5-mini-instruct",      # Mini model  
  "meta-llama/Llama-3.3-70B-Instruct",    # Large model
  "Qwen/Qwen3-235B-A22B-FP8"              # Very large model
)

result6 <- multiLLMviaionet(
  prompt = prompt6,
  models = performance_models,
  max_tokens = 500,
  streaming = FALSE,
  parallel = TRUE,
  verbose = TRUE
)

# Analyze performance
cat("\n⚡ Performance Analysis:\n")
cat("=======================\n")

execution_times <- sapply(result6$results, function(x) {
  if (x$success) x$execution_time else NA
})

performance_df <- data.frame(
  Model = names(execution_times),
  ExecutionTime = round(execution_times, 2),
  Success = sapply(result6$results, function(x) x$success),
  TokensUsed = sapply(result6$results, function(x) {
    if (x$success) x$usage$total_tokens else 0
  })
)

print(performance_df)

# ==============================================================================
# UTILITY FUNCTIONS FOR RESULTS ANALYSIS
# ==============================================================================

#' Analyze Multi-LLM Results
#' 
#' Helper function to analyze and compare results from multiLLMviaionet
analyze_results <- function(result) {
  cat("🔍 RESULT ANALYSIS\n")
  cat("=================\n")
  
  successful <- Filter(function(x) x$success, result$results)
  failed <- Filter(function(x) !x$success, result$results)
  
  cat("✅ Successful models:", length(successful), "\n")
  cat("❌ Failed models:", length(failed), "\n")
  cat("🎯 Success rate:", result$summary$success_rate, "%\n")
  cat("⏱️  Total execution time:", round(result$summary$total_execution_time, 2), "seconds\n")
  cat("🎲 Average time per model:", round(result$summary$avg_model_time, 2), "seconds\n")
  cat("📊 Total tokens used:", result$summary$total_tokens_used, "\n")
  
  if (length(failed) > 0) {
    cat("\n❌ Failed models:\n")
    for (f in failed) {
      cat("   -", f$model, ":", f$error, "\n")
    }
  }
  
  if (length(successful) > 0) {
    cat("\n📝 Response lengths:\n")
    for (s in successful) {
      response_length <- nchar(s$response)
      cat("   -", s$model, ":", response_length, "characters\n")
    }
  }
}

# Example usage of analysis function
cat("\n\n🔍 ANALYSIS OF LAST RESULT:\n")
analyze_results(result6)

# ==============================================================================
# TIPS AND BEST PRACTICES
# ==============================================================================

cat("\n\n💡 TIPS AND BEST PRACTICES\n")
cat("=========================\n\n")

cat("🎯 Model Selection Tips:\n")
cat("  • Use diverse model families for comprehensive comparison\n")
cat("  • For coding tasks: Qwen2.5-Coder, DeepSeek-R1, Phi-4\n")
cat("  • For math problems: AceMath-7B, DeepSeek-R1, Qwen3-235B\n")
cat("  • For general tasks: Llama-3.3-70B, DeepSeek-R1, Mistral-Large\n")
cat("  • For efficiency: Phi-3.5-mini, Qwen2.5-1.5B, MiniCPM3-4B\n\n")

cat("⚙️ Parameter Tuning:\n")
cat("  • temperature = 0.1-0.3 for deterministic tasks (math, code)\n")
cat("  • temperature = 0.7-1.0 for creative tasks (writing, brainstorming)\n")
cat("  • max_tokens = 500-1000 for short answers\n")
cat("  • max_tokens = 1500-4000 for detailed explanations\n")
cat("  • Use parallel=TRUE for multiple models (faster)\n")
cat("  • Use streaming=TRUE for real-time feedback\n\n")

cat("🔧 API Key Management:\n")
cat("  • Set IONET_API_KEY environment variable\n")
cat("  • Add to .Rprofile for persistence:\n")
cat("    Sys.setenv(IONET_API_KEY = 'your_key_here')\n")
cat("  • Never commit API keys to version control\n\n")

cat("📊 Performance Optimization:\n")
cat("  • Use fewer models for quick testing\n")
cat("  • Increase timeout for complex prompts\n")
cat("  • Monitor token usage to manage costs\n")
cat("  • Use random_selection=TRUE to explore different models\n\n")

cat("✅ Demo completed successfully!\n")
cat("For more information, see the function documentation: ?multiLLMviaionet\n")