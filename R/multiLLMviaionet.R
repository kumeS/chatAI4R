#' Multi-LLM via io.net API
#'
#' @title multiLLMviaionet: Execute ALL available LLM models simultaneously via io.net API
#' @description This function automatically runs the same prompt across ALL currently available 
#'   LLM models on the io.net API. It supports running all models in parallel with streaming 
#'   responses and comprehensive error handling.
#'   
#'   The function dynamically fetches the current list of available models from the io.net API
#'   and executes ALL of them by default (unless limited by max_models parameter). Results are 
#'   cached for 1 hour to improve performance. If the API is unavailable, it falls back to a static model list.
#'   
#'   Supported model categories include:
#'   - Meta Llama series (Llama-4-Maverick, Llama-3.3-70B, etc.)
#'   - DeepSeek series (DeepSeek-R1, DeepSeek-R1-Distill variants)
#'   - Qwen series (Qwen3-235B, QwQ-32B, Qwen2.5-Coder, etc.)
#'   - Specialized models (AceMath-7B, watt-tool-70B, ReaderLM-v2)
#'   - Microsoft Phi, Mistral, Google Gemma, and more
#'
#' @param prompt A string containing the input prompt to send to all selected models.
#' @param max_models Integer specifying maximum number of models to run (1-50). Default is all available models.
#' @param streaming Logical indicating whether to use streaming responses. Default is FALSE.
#' @param random_selection Logical indicating whether to randomly select models from all available models. 
#'   If TRUE, randomly selects up to max_models from all available models.
#'   If FALSE, uses all available models in order (up to max_models limit). Default is FALSE.
#' @param api_key A string containing the io.net API key. 
#'   Defaults to the environment variable "IONET_API_KEY".
#' @param max_tokens Integer specifying maximum tokens to generate per model. Default is 1024.
#' @param temperature Numeric value controlling randomness (0-2). Default is 0.7.
#' @param timeout Numeric value in seconds for request timeout per model. Default is 300.
#' @param parallel Logical indicating whether to run models in parallel. Default is TRUE.
#' @param verbose Logical indicating whether to show detailed progress. Default is TRUE.
#'
#' @importFrom httr POST GET add_headers content status_code timeout
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom parallel makeCluster stopCluster parLapply detectCores
#' @importFrom future future multisession plan resolved value
#' @importFrom assertthat assert_that is.string is.count is.flag noNA
#' @return A list containing:
#'   \describe{
#'     \item{results}{List of responses from each model with metadata}
#'     \item{summary}{Summary statistics including execution times and token usage}
#'     \item{errors}{Any errors encountered during execution}
#'     \item{models_used}{Character vector of models that were actually executed}
#'   }
#' @export multiLLMviaionet
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Set your io.net API key
#'   Sys.setenv(IONET_API_KEY = "your_ionet_api_key_here")
#'   
#'   # Basic usage - automatically runs on ALL available models
#'   result <- multiLLMviaionet(
#'     prompt = "Explain quantum computing in simple terms"
#'   )
#'   
#'   # Limit to first 5 models in order
#'   result <- multiLLMviaionet(
#'     prompt = "What is machine learning?",
#'     max_models = 5
#'   )
#'   
#'   # Random selection of 10 models from all available
#'   result <- multiLLMviaionet(
#'     prompt = "Write a Python function to calculate fibonacci numbers",
#'     max_models = 10,
#'     random_selection = TRUE,
#'     temperature = 0.3,
#'     streaming = FALSE
#'   )
#'   
#'   # Quick random 10 model comparison
#'   result <- multiLLM_random10(
#'     prompt = "Explain machine learning in simple terms"
#'   )
#'   
#'   # Access results
#'   print(result$summary)
#'   lapply(result$results, function(x) cat(x$model, ":\n", x$response, "\n\n"))
#' }

multiLLMviaionet <- function(prompt,
                             max_models = NULL,
                             streaming = FALSE,
                             random_selection = FALSE,
                             api_key = Sys.getenv("IONET_API_KEY"),
                             max_tokens = 1024,
                             temperature = 0.7,
                             timeout = 300,
                             parallel = TRUE,
                             verbose = TRUE) {
  
  # Input validation
  assertthat::assert_that(
    assertthat::is.string(prompt),
    assertthat::noNA(prompt),
    nchar(prompt) > 0,
    assertthat::is.flag(streaming),
    assertthat::is.flag(random_selection),
    assertthat::is.string(api_key),
    nchar(api_key) > 0,
    assertthat::is.count(max_tokens),
    max_tokens >= 1,
    max_tokens <= 8192,
    is.numeric(temperature),
    temperature >= 0,
    temperature <= 2,
    is.numeric(timeout),
    timeout > 0,
    assertthat::is.flag(parallel),
    assertthat::is.flag(verbose)
  )
  
  # Validate max_models if provided
  if (!is.null(max_models)) {
    assertthat::assert_that(
      assertthat::is.count(max_models),
      max_models >= 1,
      max_models <= 50
    )
  }
  
  if (verbose) {
    cat(">> Starting multi-LLM execution on ALL available models via io.net API\n")
    cat("** Prompt:", substr(prompt, 1, 100), if(nchar(prompt) > 100) "..." else "", "\n")
  }
  
  # Get list of available models (with dynamic API fetching)
  available_models <- .get_ionet_available_models(api_key = api_key, verbose = verbose)
  
  if (length(available_models) == 0) {
    stop("No models available from io.net API")
  }
  
  # Set max_models to all available if not specified
  if (is.null(max_models)) {
    max_models <- length(available_models)
    if (verbose) {
      cat("** Using all available models (", max_models, " models)\n")
    }
  }
  
  # Use all available models as the base set
  models <- available_models
  
  # Validate and process model selection
  processed_models <- .validate_and_process_models(
    models, available_models, max_models, random_selection, verbose
  )
  
  if (length(processed_models) == 0) {
    stop("No valid models found after processing")
  }
  
  if (verbose) {
    cat("** Selected models (", length(processed_models), "):\n")
    for (i in seq_along(processed_models)) {
      cat("  ", i, ". ", processed_models[i], "\n")
    }
  }
  
  # Execute models
  start_time <- Sys.time()
  
  if (parallel && length(processed_models) > 1) {
    results <- .execute_models_parallel(
      prompt, processed_models, api_key, max_tokens, temperature, 
      timeout, streaming, verbose
    )
  } else {
    results <- .execute_models_sequential(
      prompt, processed_models, api_key, max_tokens, temperature,
      timeout, streaming, verbose
    )
  }
  
  end_time <- Sys.time()
  total_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Process and summarize results
  summary_data <- .summarize_results(results, total_time, verbose)
  
  # Compile final output
  output <- list(
    results = results,
    summary = summary_data,
    errors = Filter(function(x) !is.null(x$error), results),
    models_used = processed_models,
    execution_time = total_time,
    timestamp = Sys.time()
  )
  
  if (verbose) {
    cat(">> Multi-LLM execution completed in", round(total_time, 2), "seconds\n")
    cat("** Success rate:", summary_data$success_rate, "%\n")
  }
  
  class(output) <- c("multiLLM_result", "list")
  return(output)
}

# Helper function: Get available io.net models dynamically
.get_ionet_available_models <- function(api_key = NULL, force_refresh = FALSE, verbose = FALSE) {
  
  # Use provided api_key or get from environment
  if (is.null(api_key)) {
    api_key <- Sys.getenv("IONET_API_KEY")
  }
  
  # Check if we should use cached results
  cache_key <- "ionet_models_cache"
  cache_time_key <- "ionet_models_cache_time"
  cache_duration <- 3600  # Cache for 1 hour
  
  # Get cached data if available and not forcing refresh
  if (!force_refresh && exists(cache_key, envir = .GlobalEnv) && exists(cache_time_key, envir = .GlobalEnv)) {
    cached_time <- get(cache_time_key, envir = .GlobalEnv)
    if (as.numeric(difftime(Sys.time(), cached_time, units = "secs")) < cache_duration) {
      cached_models <- get(cache_key, envir = .GlobalEnv)
      if (verbose) {
        cat("** Using cached model list (", length(cached_models), " models, cached ", 
            round(as.numeric(difftime(Sys.time(), cached_time, units = "mins"))), " minutes ago)\n")
      }
      return(cached_models)
    }
  }
  
  # Try to fetch models from API
  api_models <- NULL
  if (nchar(api_key) > 0) {
    api_models <- tryCatch({
      .fetch_ionet_models_from_api(api_key, verbose)
    }, error = function(e) {
      if (verbose) {
        cat("!! Failed to fetch models from API:", e$message, "\n")
        cat("** Falling back to static model list\n")
      }
      NULL
    })
  }
  
  # Use API models if available, otherwise fall back to static list
  final_models <- if (!is.null(api_models) && length(api_models) > 0) {
    if (verbose) {
      cat("** Successfully fetched", length(api_models), "models from io.net API\n")
    }
    
    # Cache the API results
    assign(cache_key, api_models, envir = .GlobalEnv)
    assign(cache_time_key, Sys.time(), envir = .GlobalEnv)
    
    api_models
  } else {
    if (verbose) {
      cat("** Using static fallback model list\n")
    }
    .get_ionet_static_models()
  }
  
  return(final_models)
}

# Helper function: Fetch models from io.net API
.fetch_ionet_models_from_api <- function(api_key, verbose = FALSE) {
  
  if (verbose) {
    cat("** Fetching current model list from io.net API...\n")
  }
  
  # Make API request to get models
  response <- httr::GET(
    url = "https://api.intelligence.io.solutions/api/v1/models",
    httr::add_headers(
      `Authorization` = paste("Bearer", api_key)
    ),
    httr::timeout(30)  # 30 second timeout for model list
  )
  
  # Check response status
  if (httr::status_code(response) != 200) {
    error_content <- tryCatch(httr::content(response, "parsed"), error = function(e) NULL)
    error_msg <- if (!is.null(error_content$error)) {
      error_content$error$message %||% "Unknown API error"
    } else {
      paste("HTTP", httr::status_code(response), "error")
    }
    stop("API request failed: ", error_msg)
  }
  
  # Parse response
  parsed_response <- httr::content(response, "parsed")
  
  # Extract model names from API response
  model_names <- character(0)
  
  # Handle different possible response formats
  if (!is.null(parsed_response$data) && is.list(parsed_response$data)) {
    # Format: {"data": [{"id": "model-name", ...}, ...]}
    for (model_info in parsed_response$data) {
      if (!is.null(model_info$id)) {
        model_names <- c(model_names, model_info$id)
      }
    }
  } else if (is.list(parsed_response) && length(parsed_response) > 0) {
    # Format: [{"id": "model-name", ...}, ...]
    for (model_info in parsed_response) {
      if (!is.null(model_info$id)) {
        model_names <- c(model_names, model_info$id)
      }
    }
  } else {
    stop("Unexpected API response format")
  }
  
  # Filter out empty or invalid model names
  model_names <- model_names[nchar(trimws(model_names)) > 0]
  
  if (length(model_names) == 0) {
    stop("No valid models found in API response")
  }
  
  if (verbose) {
    cat("** Found", length(model_names), "models from API\n")
  }
  
  return(unique(model_names))
}

# Helper function: Static model list (fallback)
.get_ionet_static_models <- function() {
  c(
    # Meta Llama series - Multimodal and instruction-tuned models
    "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8",  # Llama 4 with 128 experts, multimodal
    "meta-llama/Llama-3.3-70B-Instruct",                  # Llama 3.3 optimized transformer
    "meta-llama/Llama-3.2-90B-Vision-Instruct",          # Vision-capable Llama model
    
    # DeepSeek series - Advanced reasoning and inference models
    "deepseek-ai/DeepSeek-R1-0528",                       # Latest DeepSeek R1 version with improved reasoning
    "deepseek-ai/DeepSeek-R1",                            # Original DeepSeek reasoning model
    "deepseek-ai/DeepSeek-R1-Distill-Llama-70B",         # DeepSeek distilled to Llama 3.3 70B
    "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",          # DeepSeek distilled to Qwen-32B
    
    # Qwen series - Comprehensive large language models
    "Qwen/Qwen3-235B-A22B-FP8",                          # Latest Qwen3 with MoE architecture
    "Qwen/Qwen2.5-VL-32B-Instruct",                      # Vision-language model
    
    # Google models
    "google/gemma-3-27b-it",                             # Google's lightweight multimodal model
    
    # Mistral AI models - European AI with multilingual support
    "mistralai/Devstral-Small-2505",                     # Agentic LLM for software engineering
    "mistralai/Magistral-Small-2506",                    # Advanced reasoning with multilingual support
    "mistralai/Mistral-Large-Instruct-2411",             # Advanced dense LLM with 123B parameters
    "mistralai/Ministral-8B-Instruct-2410",              # Compact instruct model
    
    # NetEase Youdao model
    "netease-youdao/Confucius-o1-14B",                   # o1-like reasoning model on single GPU
    
    # NVIDIA specialized model
    "nvidia/AceMath-7B-Instruct",                        # Specialized for mathematical problems
    
    # Microsoft model
    "microsoft/phi-4",                                    # 14B parameter small language model
    
    # Bespoke Labs model
    "bespokelabs/Bespoke-Stratos-32B",                   # Fine-tuned Qwen2.5-32B variant
    
    # THUDM model
    "THUDM/glm-4-9b-chat",                              # Open-source GLM-4 series model
    
    # CohereForAI model
    "CohereForAI/aya-expanse-32b",                       # Advanced multilingual capabilities
    
    # OpenBMB model
    "openbmb/MiniCPM3-4B",                              # 32k context window with LLMxMapReduce
    
    # IBM model
    "ibm-granite/granite-3.1-8b-instruct",              # Long-context instruct model
    
    # BAAI embedding model
    "BAAI/bge-multilingual-gemma2"                       # Multilingual embedding model
  )
}

# Helper function: Validate and process model selection
.validate_and_process_models <- function(models, available_models, max_models, 
                                        random_selection, verbose) {
  
  # Remove duplicates from input
  models <- unique(models)
  
  # Validate models against available list
  valid_models <- models[models %in% available_models]
  invalid_models <- models[!models %in% available_models]
  
  if (length(invalid_models) > 0) {
    if (verbose) {
      cat("!! Invalid/unavailable models (skipped):\n")
      for (model in invalid_models) {
        cat("   - ", model, "\n")
        
        # Suggest similar available models
        suggestions <- .suggest_similar_models(model, available_models)
        if (length(suggestions) > 0) {
          cat("     >> Similar available models: ", paste(suggestions[1:min(2, length(suggestions))], collapse = ", "), "\n")
        }
      }
      cat("\n")
    }
    
    # Provide helpful error context
    if (length(valid_models) == 0) {
      cat("!! No valid models found from your selection.\n")
      cat("** Available models on io.net (", length(available_models), " total):\n")
      
             # Group by category for better display
       categories <- list(
         "Meta Llama" = available_models[grepl("meta-llama", available_models)],
         "DeepSeek" = available_models[grepl("deepseek-ai", available_models)],
         "Qwen" = available_models[grepl("Qwen/", available_models)],
         "Mistral AI" = available_models[grepl("mistralai", available_models)],
         "Reasoning" = available_models[grepl("(netease-youdao|nvidia)", available_models)],
         "Compact" = available_models[grepl("(microsoft|THUDM|openbmb|ibm-granite)", available_models)],
         "Multilingual" = available_models[grepl("(google|CohereForAI|bespokelabs|BAAI)", available_models)]
       )
      
      for (cat_name in names(categories)) {
        if (length(categories[[cat_name]]) > 0) {
          cat("  >> ", cat_name, " (", length(categories[[cat_name]]), "):\n")
          for (model in categories[[cat_name]]) {
            cat("     - ", model, "\n")
          }
        }
      }
      
      cat("\n>> Use list_ionet_models() to see all available models\n")
      cat(">> Use multiLLM_random10() or multiLLM_random5() for quick testing\n")
      
      stop("No valid models found. Please check model names against available models.")
    }
  }
  
  # Apply max_models limit
  if (length(valid_models) > max_models) {
    if (random_selection) {
      if (verbose) {
        cat("** Randomly selecting", max_models, "models from", length(valid_models), "available models\n")
      }
      # Set seed for reproducible debugging if needed, then randomize
      valid_models <- sample(valid_models, max_models)
      if (verbose) {
        cat("** Random selection completed\n")
      }
    } else {
      if (verbose) {
        cat(">>  Limiting to first", max_models, "models from specified list\n")
      }
      valid_models <- valid_models[1:max_models]
    }
  } else if (random_selection && length(valid_models) > 1) {
    # Even if we don't need to limit, shuffle the order if random_selection is TRUE
    if (verbose) {
      cat("** Shuffling", length(valid_models), "models in random order\n")
    }
    valid_models <- sample(valid_models)
  }
  
  return(valid_models)
}

# Helper function: Suggest similar models based on name patterns
.suggest_similar_models <- function(invalid_model, available_models) {
  
  # Extract key terms from the invalid model name
  model_parts <- tolower(strsplit(invalid_model, "[-_/]")[[1]])
  model_parts <- model_parts[nchar(model_parts) > 2]  # Filter out very short parts
  
  suggestions <- character(0)
  
  # Look for models containing similar terms
  for (part in model_parts) {
    matches <- available_models[grepl(part, available_models, ignore.case = TRUE)]
    suggestions <- c(suggestions, matches)
  }
  
  # Remove duplicates and limit suggestions
  suggestions <- unique(suggestions)
  suggestions <- suggestions[1:min(3, length(suggestions))]
  
  return(suggestions)
}

# Helper function: Execute models in parallel
.execute_models_parallel <- function(prompt, models, api_key, max_tokens, temperature,
                                    timeout, streaming, verbose) {
  
  if (verbose) {
    cat(">> Executing", length(models), "models in parallel (async)\n")
  }
  
  # Suppress package loading messages in parallel execution
  suppressPackageStartupMessages({
    future::plan(future::multisession, workers = min(length(models), 6))
  })
  
  # Create futures for each model with suppressed messages
  futures_list <- list()
  for (i in seq_along(models)) {
    futures_list[[models[i]]] <- future::future({
      # Execute single model (package functions are automatically available in workers)
      .execute_single_model(
        prompt, models[i], api_key, max_tokens, temperature,
        timeout, streaming, verbose = FALSE  # Disable verbose for cleaner parallel output
      )
    })
  }
  
  # Monitor progress
  if (verbose) {
    cat(">> Monitoring async execution progress:\n")
    completed_count <- 0
    
    while (completed_count < length(models)) {
      for (model in names(futures_list)) {
        if (future::resolved(futures_list[[model]])) {
          result <- tryCatch(future::value(futures_list[[model]]), error = function(e) NULL)
          if (!is.null(result) && !is.null(result$model)) {
            completed_count <- completed_count + 1
            status <- if (result$success) "[OK]" else "[ERROR]"
            cat("  ", status, result$model, "completed (", completed_count, "/", length(models), ")\n")
            futures_list[[model]] <- NULL  # Remove completed future
          }
        }
      }
      if (completed_count < length(models)) {
        Sys.sleep(0.5)  # Brief pause before next check
      }
    }
  }
  
  # Collect all results with suppressed messages
  results <- list()
  suppressPackageStartupMessages({
    for (model in models) {
      if (!is.null(futures_list[[model]])) {
        results[[model]] <- tryCatch(
          future::value(futures_list[[model]]),
          error = function(e) {
            list(
              model = model,
              response = NULL,
              success = FALSE,
              execution_time = 0,
              usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
              timestamp = Sys.time(),
              error = paste("Future execution failed:", e$message)
            )
          }
        )
      }
    }
  })
  
  if (verbose) {
    cat(">> All", length(models), "models completed asynchronously\n")
  }
  
  return(results)
}

# Helper function: Execute models sequentially
.execute_models_sequential <- function(prompt, models, api_key, max_tokens, temperature,
                                     timeout, streaming, verbose) {
  
  if (verbose) {
    cat(">> Executing", length(models), "models sequentially\n")
  }
  
  results <- list()
  
  for (i in seq_along(models)) {
    model <- models[i]
    if (verbose) {
      cat("  Processing model", i, "/", length(models), ":", model, "\n")
    }
    
    results[[model]] <- .execute_single_model(
      prompt, model, api_key, max_tokens, temperature, timeout, streaming, verbose
    )
  }
  
  return(results)
}

# Helper function: Execute single model with enhanced debugging
.execute_single_model <- function(prompt, model, api_key, max_tokens, temperature,
                                 timeout, streaming, verbose = TRUE) {
  
  start_time <- Sys.time()
  
  tryCatch({
    # Prepare request body (following JavaScript reference implementation)
    body <- list(
      model = model,
      messages = list(
        list(role = "user", content = prompt)
      ),
      max_completion_tokens = if (is.null(max_tokens)) 1024 else max_tokens,
      temperature = temperature,
      stream = streaming == TRUE  # Explicit boolean conversion as in JS example
    )
    
    # Make API request (following JavaScript reference implementation)
    response <- httr::POST(
      url = "https://api.intelligence.io.solutions/api/v1/chat/completions",
      httr::add_headers(
        `Authorization` = paste("Bearer", api_key),
        `Content-Type` = "application/json"
      ),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      encode = "json",
      httr::timeout(timeout)
    )
    
    # Enhanced error handling for different HTTP status codes
    status_code <- httr::status_code(response)
    if (status_code != 200) {
      error_content <- tryCatch(httr::content(response, "parsed"), error = function(e) NULL)
      
      # Categorize errors based on status code
      error_category <- switch(as.character(status_code),
        "400" = "Bad Request",
        "401" = "Authentication Error", 
        "403" = "Access Forbidden",
        "404" = "Model Not Found",
        "429" = "Rate Limit Exceeded",
        "500" = "Internal Server Error",
        "502" = "Bad Gateway",
        "503" = "Service Unavailable",
        "504" = "Gateway Timeout",
        paste("HTTP", status_code, "Error")
      )
      
      # Extract detailed error message
      detailed_msg <- if (!is.null(error_content$error$message)) {
        error_content$error$message
      } else if (!is.null(error_content$message)) {
        error_content$message
      } else {
        "No detailed error message available"
      }
      
      # Special handling for model availability issues
      if (status_code == 404 || grepl("model.*not.*found|model.*unavailable|model.*not.*exist", detailed_msg, ignore.case = TRUE)) {
        error_msg <- paste0("Model '", model, "' is not available or temporarily offline. ",
                           "This model may have been removed from io.net or is under maintenance.")
      } else if (status_code == 429) {
        error_msg <- paste0("Rate limit exceeded for model '", model, "'. ",
                           "Consider reducing concurrent requests or waiting before retry.")
      } else if (status_code == 503) {
        error_msg <- paste0("Model '", model, "' service is temporarily unavailable. ",
                           "This is usually temporary - try again later.")
      } else {
        error_msg <- paste0(error_category, " for model '", model, "': ", detailed_msg)
      }
      
      stop(error_msg)
    }
    
    # Parse response with enhanced debugging (following JavaScript reference)
    parsed_response <- tryCatch({
      if (streaming == TRUE) {
        # For streaming, handle Server-Sent Events (SSE) format
        content_text <- httr::content(response, "text", encoding = "UTF-8")
        
        if (verbose) {
          cat("[DEBUG] Raw streaming response length:", nchar(content_text), "characters\n")
        }
        
        # Handle SSE format: parse data chunks
        if (grepl("data:", content_text)) {
          # Split into lines and process SSE data chunks
          lines <- strsplit(content_text, "\n")[[1]]
          data_lines <- lines[grepl("^data:\\s*", lines)]
          
          # Clean data lines and remove empty/DONE markers
          data_lines <- gsub("^data:\\s*", "", data_lines)
          data_lines <- data_lines[data_lines != "[DONE]" & nchar(trimws(data_lines)) > 0]
          
          if (length(data_lines) > 0) {
            # Accumulate content from all chunks for complete response
            accumulated_content <- ""
            
            for (data_line in data_lines) {
              tryCatch({
                chunk_data <- jsonlite::fromJSON(data_line)
                if (!is.null(chunk_data$choices) && length(chunk_data$choices) > 0) {
                  if (!is.null(chunk_data$choices[[1]]$delta$content)) {
                    accumulated_content <- paste0(accumulated_content, chunk_data$choices[[1]]$delta$content)
                  }
                }
              }, error = function(e) {
                # Skip malformed chunks
                if (verbose) cat("[WARNING] Skipping malformed chunk:", data_line, "\n")
              })
            }
            
            # Create a synthetic response object with accumulated content
            if (nchar(accumulated_content) > 0) {
              list(
                choices = list(list(
                  message = list(content = accumulated_content)
                )),
                usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0)
              )
            } else {
              # Parse the last valid chunk as fallback
              jsonlite::fromJSON(data_lines[length(data_lines)])
            }
          } else {
            stop("No valid streaming data chunks found in SSE response")
          }
        } else {
          # Not SSE format, try parsing as regular JSON
          jsonlite::fromJSON(content_text)
        }
      } else {
        # Non-streaming: parse as standard JSON
        httr::content(response, "parsed")
      }
    }, error = function(e) {
      # Enhanced error message with response content for debugging
      raw_content <- tryCatch(httr::content(response, "text", encoding = "UTF-8"), error = function(e2) "Unable to extract content")
      stop("Failed to parse API response for model '", model, "'. Raw content (first 500 chars): ", 
           substr(raw_content, 1, 500), ". Parse error: ", e$message)
    })
    
    # Debug: Log actual response structure when choices are missing
    if (is.null(parsed_response$choices) || length(parsed_response$choices) == 0) {
      # Log the structure for debugging
      response_structure <- capture.output(utils::str(parsed_response, max.level = 2))
      response_names <- if (is.list(parsed_response)) names(parsed_response) else "Not a list"
      
      debug_info <- paste(
        "API Response Debug Info for model", model, ":",
        "\nResponse has", length(parsed_response), "top-level elements.",
        "\nTop-level names:", paste(response_names, collapse = ", "),
        "\nResponse structure (first 3 levels):",
        paste(response_structure[1:min(10, length(response_structure))], collapse = "\n"),
        "\nFirst 200 chars of raw response:",
        substr(httr::content(response, "text", encoding = "UTF-8"), 1, 200)
      )
      
      # Check for alternative response formats
      possible_content <- NULL
      
      # Try different common response formats
      if (!is.null(parsed_response$content)) {
        possible_content <- parsed_response$content
      } else if (!is.null(parsed_response$output)) {
        possible_content <- parsed_response$output
      } else if (!is.null(parsed_response$text)) {
        possible_content <- parsed_response$text
      } else if (!is.null(parsed_response$response)) {
        possible_content <- parsed_response$response
      } else if (!is.null(parsed_response$data) && !is.null(parsed_response$data$content)) {
        possible_content <- parsed_response$data$content
      }
      
      if (!is.null(possible_content) && nchar(trimws(possible_content)) > 0) {
        # Found content in alternative format
        response_text <- possible_content
      } else {
        stop("No valid content found in API response for model '", model, "'. ", debug_info)
      }
    } else {
      # Standard choices format - extract response text
      response_text <- tryCatch({
        if (streaming && !is.null(parsed_response$choices[[1]]$delta) && 
            !is.null(parsed_response$choices[[1]]$delta$content)) {
          parsed_response$choices[[1]]$delta$content
        } else if (!is.null(parsed_response$choices[[1]]$message) &&
                   !is.null(parsed_response$choices[[1]]$message$content)) {
          parsed_response$choices[[1]]$message$content
        } else {
          stop("Message content not found in choices structure")
        }
      }, error = function(e) {
        stop("Failed to extract content from choices for model '", model, "': ", e$message)
      })
    }
    
    # Validate response content
    if (is.null(response_text) || length(response_text) == 0 || 
        (is.character(response_text) && nchar(trimws(response_text)) == 0)) {
      stop("Model '", model, "' returned empty or null content")
    }
    
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Extract usage info if available
    usage_info <- if (!is.null(parsed_response$usage)) {
      list(
        prompt_tokens = parsed_response$usage$prompt_tokens %||% 0,
        completion_tokens = parsed_response$usage$completion_tokens %||% 0,
        total_tokens = parsed_response$usage$total_tokens %||% 0
      )
    } else {
      list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0)
    }
    
    return(list(
      model = model,
      response = response_text,
      success = TRUE,
      execution_time = execution_time,
      usage = usage_info,
      timestamp = end_time,
      error = NULL
    ))
    
  }, error = function(e) {
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    if (verbose) {
      cat("[ERROR] Error with model", model, ":", e$message, "\n")
    }
    
    return(list(
      model = model,
      response = NULL,
      success = FALSE,
      execution_time = execution_time,
      usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
      timestamp = end_time,
      error = e$message
    ))
  })
}

# Helper function: Summarize results
.summarize_results <- function(results, total_time, verbose) {
  
  successful_results <- Filter(function(x) x$success, results)
  failed_results <- Filter(function(x) !x$success, results)
  
  success_count <- length(successful_results)
  total_count <- length(results)
  success_rate <- round((success_count / total_count) * 100, 1)
  
  # Calculate statistics for successful results
  if (success_count > 0) {
    execution_times <- sapply(successful_results, function(x) x$execution_time)
    total_tokens <- sum(sapply(successful_results, function(x) x$usage$total_tokens))
    avg_execution_time <- mean(execution_times)
    min_execution_time <- min(execution_times)
    max_execution_time <- max(execution_times)
  } else {
    avg_execution_time <- min_execution_time <- max_execution_time <- 0
    total_tokens <- 0
  }
  
  summary_data <- list(
    total_models = total_count,
    successful_models = success_count,
    failed_models = length(failed_results),
    success_rate = success_rate,
    total_execution_time = total_time,
    avg_model_time = avg_execution_time,
    min_model_time = min_execution_time,
    max_model_time = max_execution_time,
    total_tokens_used = total_tokens,
    failed_model_names = if (length(failed_results) > 0) {
      sapply(failed_results, function(x) x$model)
    } else {
      character(0)
    }
  )
  
  return(summary_data)
}

# Utility function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Refresh io.net Model Cache
#'
#' @title refresh_ionet_models: Manually refresh the cached model list from io.net API
#' @description This function forces a refresh of the model list cache by fetching 
#'   the current models from the io.net API. Use this if you suspect the model list 
#'   has changed and you want to update immediately rather than waiting for the 
#'   1-hour cache to expire.
#'
#' @param api_key Optional API key for fetching current models. Defaults to IONET_API_KEY environment variable.
#' @param verbose Logical indicating whether to show detailed fetching information. Default is TRUE.
#'
#' @return A character vector of current model names from the API, or NULL if the API call failed
#' @export refresh_ionet_models
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Refresh model list from API
#'   current_models <- refresh_ionet_models()
#'   
#'   # Refresh silently
#'   current_models <- refresh_ionet_models(verbose = FALSE)
#' }
refresh_ionet_models <- function(api_key = NULL, verbose = TRUE) {
  
  # Input validation
  if (is.null(api_key)) {
    api_key <- Sys.getenv("IONET_API_KEY")
  }
  
  if (nchar(api_key) == 0) {
    if (verbose) {
      cat("!! No API key found. Please set IONET_API_KEY environment variable or provide api_key parameter.\n")
    }
    return(NULL)
  }
  
  if (verbose) {
    cat(">> Refreshing io.net model list from API...\n")
  }
  
  # Force refresh the model list
  tryCatch({
    models <- .get_ionet_available_models(api_key = api_key, force_refresh = TRUE, verbose = verbose)
    
    if (verbose) {
      cat(">> Successfully refreshed model list with", length(models), "models\n")
      cat("** Cache will be used for the next 1 hour\n")
    }
    
    return(models)
  }, error = function(e) {
    if (verbose) {
      cat("!! Failed to refresh models from API:", e$message, "\n")
      cat("** Existing cache (if any) will continue to be used\n")
    }
    return(NULL)
  })
}

#' List Available io.net Models
#'
#' @title list_ionet_models: Display available LLM models on io.net API
#' @description This function returns a list of all available LLM models that can be used
#'   with the multiLLMviaionet function. Models are categorized by family/provider.
#'   This function will attempt to fetch the current model list from the io.net API.
#'
#' @param category Optional character string to filter models by category. 
#'   Options: "llama", "deepseek", "qwen", "phi", "mistral", "specialized", "all". Default is "all".
#' @param detailed Logical indicating whether to show detailed model information. Default is FALSE.
#' @param api_key Optional API key for fetching current models. Defaults to IONET_API_KEY environment variable.
#' @param force_refresh Logical indicating whether to force refresh the model list from API. Default is FALSE.
#' @param verbose Logical indicating whether to show detailed fetching information. Default is FALSE.
#'
#' @return A character vector of model names, or a data frame if detailed=TRUE
#' @export list_ionet_models
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # List all available models (from API if available)
#'   all_models <- list_ionet_models()
#'   
#'   # Force refresh from API
#'   fresh_models <- list_ionet_models(force_refresh = TRUE)
#'   
#'   # List only Llama models
#'   llama_models <- list_ionet_models("llama")
#'   
#'   # Show detailed information
#'   model_info <- list_ionet_models(detailed = TRUE)
#' }
list_ionet_models <- function(category = "all", detailed = FALSE, api_key = NULL, 
                              force_refresh = FALSE, verbose = FALSE) {
  
  # Get all available models (with dynamic API fetching)
  all_models <- .get_ionet_available_models(api_key = api_key, force_refresh = force_refresh, verbose = verbose)
  
  # Define model categories with descriptions
  model_categories <- list(
    llama = list(
      pattern = "meta-llama",
      description = "Meta's Llama series - Multimodal models with expert architectures and strong general capabilities"
    ),
    deepseek = list(
      pattern = "deepseek-ai",
      description = "DeepSeek series - Advanced reasoning and inference models with o1-like capabilities"
    ),
    qwen = list(
      pattern = "Qwen/",
      description = "Alibaba's Qwen series - Comprehensive MoE models with multilingual and vision support"
    ),
    mistral = list(
      pattern = "mistralai",
      description = "Mistral AI series - European AI with software engineering and multilingual capabilities"
    ),
    reasoning = list(
      pattern = "(netease-youdao|nvidia)",
      description = "Reasoning specialized models - Mathematical problem solving and o1-like thinking"
    ),
    compact = list(
      pattern = "(microsoft|THUDM|openbmb|ibm-granite)",
      description = "Compact/efficient models - High performance with smaller parameter counts"
    ),
    multilingual = list(
      pattern = "(google|CohereForAI|bespokelabs|BAAI)",
      description = "Multilingual and specialized models - Advanced language capabilities and embeddings"
    )
  )
  
  # Filter by category if specified
  if (category != "all" && category %in% names(model_categories)) {
    pattern <- model_categories[[category]]$pattern
    filtered_models <- all_models[grepl(pattern, all_models, ignore.case = TRUE)]
  } else {
    filtered_models <- all_models
  }
  
  if (!detailed) {
    return(filtered_models)
  }
  
  # Create detailed data frame
  model_data <- data.frame(
    model = filtered_models,
    category = character(length(filtered_models)),
    description = character(length(filtered_models)),
    stringsAsFactors = FALSE
  )
  
  # Assign categories and descriptions
  for (i in seq_len(nrow(model_data))) {
    model_name <- model_data$model[i]
    
    # Determine category
    for (cat_name in names(model_categories)) {
      if (grepl(model_categories[[cat_name]]$pattern, model_name, ignore.case = TRUE)) {
        model_data$category[i] <- cat_name
        model_data$description[i] <- model_categories[[cat_name]]$description
        break
      }
    }
    
    # If no category matched, mark as "other"
    if (model_data$category[i] == "") {
      model_data$category[i] <- "other"
      model_data$description[i] <- "Other specialized model"
    }
  }
  
  return(model_data)
}

#' Random 10 Model Multi-LLM Execution
#'
#' @title multiLLM_random10: Quick execution of 10 randomly selected models
#' @description Convenience function that automatically selects 10 diverse models 
#'   from different categories and executes them in parallel. This provides a 
#'   comprehensive comparison across model families without manual selection.
#'
#' @param prompt A string containing the input prompt to send to all models.
#' @param balanced Logical indicating whether to balance selection across model categories.
#'   If TRUE (default), selects models from different families. If FALSE, uses pure random selection.
#' @param exclude_models Character vector of model names to exclude from random selection.
#' @param api_key A string containing the io.net API key. 
#'   Defaults to the environment variable "IONET_API_KEY".
#' @param max_tokens Integer specifying maximum tokens to generate per model. Default is 1024.
#' @param temperature Numeric value controlling randomness (0-2). Default is 0.7.
#' @param timeout Numeric value in seconds for request timeout per model. Default is 300.
#' @param streaming Logical indicating whether to use streaming responses. Default is FALSE.
#' @param verbose Logical indicating whether to show detailed progress. Default is TRUE.
#'
#' @return A multiLLM_result object with results from 10 randomly selected models.
#' @export multiLLM_random10
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Quick 10-model comparison with balanced selection
#'   result <- multiLLM_random10(
#'     prompt = "Explain the benefits of renewable energy"
#'   )
#'   
#'   # Pure random selection
#'   result <- multiLLM_random10(
#'     prompt = "Write a haiku about technology",
#'     balanced = FALSE,
#'     temperature = 1.0
#'   )
#'   
#'   # Exclude specific models
#'   result <- multiLLM_random10(
#'     prompt = "Solve this math problem: 2x + 5 = 15",
#'     exclude_models = c("microsoft/Phi-3.5-mini-instruct"),
#'     temperature = 0.1
#'   )
#' }
multiLLM_random10 <- function(prompt,
                              balanced = TRUE,
                              exclude_models = character(0),
                              api_key = Sys.getenv("IONET_API_KEY"),
                              max_tokens = 1024,
                              temperature = 0.7,
                              timeout = 300,
                              streaming = FALSE,
                              verbose = TRUE) {
  
  # Input validation
  assertthat::assert_that(
    assertthat::is.string(prompt),
    assertthat::noNA(prompt),
    nchar(prompt) > 0,
    assertthat::is.flag(balanced),
    is.character(exclude_models),
    assertthat::is.string(api_key),
    nchar(api_key) > 0
  )
  
  if (verbose) {
    cat(">> Random 10-Model Multi-LLM Execution\n")
    cat("====================================\n")
          cat(">> Selection mode:", if (balanced) "Balanced across categories" else "Pure random", "\n")
  }
  
  # Get all available models (with dynamic API fetching)
  all_models <- .get_ionet_available_models(api_key = api_key, verbose = verbose)
  
  # Remove excluded models
  if (length(exclude_models) > 0) {
    all_models <- all_models[!all_models %in% exclude_models]
    if (verbose && length(exclude_models) > 0) {
      cat(">> Excluded", length(exclude_models), "models from selection\n")
    }
  }
  
  # Select 10 models
  if (balanced) {
    selected_models <- .select_balanced_models(all_models, 10, verbose)
  } else {
    if (length(all_models) < 10) {
      warning("Only ", length(all_models), " models available after exclusions. Using all available models.")
      selected_models <- all_models
    } else {
      selected_models <- sample(all_models, 10)
    }
  }
  
  if (verbose) {
    cat(">> Selected 10 models for execution:\n")
    for (i in seq_along(selected_models)) {
      cat("  ", i, ". ", selected_models[i], "\n")
    }
    cat("\n")
  }
  
  # Execute using main function with pre-selected models
  # Since multiLLMviaionet now uses all available models, we need to temporarily
  # override the available models list to use only our selected models
  original_env_models <- NULL
  tryCatch({
    # Store original cached models if they exist
    if (exists("ionet_models_cache", envir = .GlobalEnv)) {
      original_env_models <- get("ionet_models_cache", envir = .GlobalEnv)
    }
    
    # Set our selected models as the "available" models for this execution
    assign("ionet_models_cache", selected_models, envir = .GlobalEnv)
    assign("ionet_models_cache_time", Sys.time(), envir = .GlobalEnv)
    
    result <- multiLLMviaionet(
      prompt = prompt,
      max_models = 10,
      streaming = streaming,
      random_selection = FALSE,  # Already selected
      api_key = api_key,
      max_tokens = max_tokens,
      temperature = temperature,
      timeout = timeout,
      parallel = TRUE,
      verbose = verbose
    )
  }, finally = {
    # Restore original cached models
    if (!is.null(original_env_models)) {
      assign("ionet_models_cache", original_env_models, envir = .GlobalEnv)
    } else {
      # Remove the temporary cache
      if (exists("ionet_models_cache", envir = .GlobalEnv)) {
        rm("ionet_models_cache", envir = .GlobalEnv)
      }
      if (exists("ionet_models_cache_time", envir = .GlobalEnv)) {
        rm("ionet_models_cache_time", envir = .GlobalEnv)
      }
    }
  })
  
  # Add random selection metadata
  result$selection_method <- if (balanced) "balanced" else "random"
  result$excluded_models <- exclude_models
  
  return(result)
}

# Helper function: Select balanced models across categories
.select_balanced_models <- function(all_models, num_models, verbose = FALSE) {
  
  # Define model categories with updated patterns for new 23 models
  categories <- list(
    llama = "meta-llama",                       # Meta Llama series (3 models)
    deepseek = "deepseek-ai",                   # DeepSeek series (4 models)
    qwen = "Qwen/",                            # Qwen series (2 models)
    mistral = "mistralai",                     # Mistral AI series (4 models)
    reasoning = "(netease-youdao|nvidia)",     # Reasoning specialized (2 models)
    compact = "(microsoft|THUDM|openbmb|ibm-granite)", # Compact/efficient models (4 models)
    multilingual = "(google|CohereForAI|bespokelabs|BAAI)", # Multilingual/specialized (4 models)
    other = ".*"                               # Catch-all for remaining models
  )
  
  # Categorize all models
  model_by_category <- list()
  for (cat_name in names(categories)) {
    pattern <- categories[[cat_name]]
    if (cat_name == "other") {
      # For "other", exclude models that matched previous categories
      already_categorized <- unlist(model_by_category)
      model_by_category[[cat_name]] <- setdiff(all_models, already_categorized)
    } else {
      model_by_category[[cat_name]] <- all_models[grepl(pattern, all_models, ignore.case = TRUE)]
    }
  }
  
  # Remove empty categories
  model_by_category <- model_by_category[sapply(model_by_category, length) > 0]
  
  if (verbose) {
    cat(">> Available models by category:\n")
    for (cat_name in names(model_by_category)) {
              cat("  -", toupper(cat_name), ":", length(model_by_category[[cat_name]]), "models\n")
    }
  }
  
  # Select models with balanced distribution
  selected_models <- character(0)
  models_per_category <- max(1, floor(num_models / length(model_by_category)))
  
  # First pass: select models_per_category from each category
  for (cat_name in names(model_by_category)) {
    available_in_cat <- model_by_category[[cat_name]]
    num_to_select <- min(models_per_category, length(available_in_cat))
    
    if (num_to_select > 0) {
      selected_from_cat <- sample(available_in_cat, num_to_select)
      selected_models <- c(selected_models, selected_from_cat)
    }
  }
  
  # Second pass: fill remaining slots randomly from all remaining models
  remaining_slots <- num_models - length(selected_models)
  if (remaining_slots > 0) {
    remaining_models <- setdiff(all_models, selected_models)
    if (length(remaining_models) > 0) {
      additional_models <- sample(remaining_models, min(remaining_slots, length(remaining_models)))
      selected_models <- c(selected_models, additional_models)
    }
  }
  
  # Shuffle the final selection
  selected_models <- sample(selected_models)
  
  return(selected_models)
}

#' Quick 5-Model Random Selection
#'
#' @title multiLLM_random5: Quick execution of 5 randomly selected models
#' @description Convenience function for faster testing with 5 diverse models.
#'
#' @param prompt A string containing the input prompt.
#' @param ... Additional arguments passed to multiLLM_random10()
#'
#' @return A multiLLM_result object with results from 5 randomly selected models.
#' @export multiLLM_random5
#' @examples
#' \dontrun{
#'   result <- multiLLM_random5("What is artificial intelligence?")
#' }
multiLLM_random5 <- function(prompt, ...) {
  
  # Get all models and select 5
  all_models <- .get_ionet_available_models(verbose = FALSE)
  selected_models <- .select_balanced_models(all_models, 5, verbose = FALSE)
  
  # Execute with selected models by temporarily overriding cache
  original_env_models <- NULL
  tryCatch({
    # Store original cached models if they exist
    if (exists("ionet_models_cache", envir = .GlobalEnv)) {
      original_env_models <- get("ionet_models_cache", envir = .GlobalEnv)
    }
    
    # Set our selected models as the "available" models for this execution
    assign("ionet_models_cache", selected_models, envir = .GlobalEnv)
    assign("ionet_models_cache_time", Sys.time(), envir = .GlobalEnv)
    
    multiLLMviaionet(
      prompt = prompt,
      max_models = 5,
      streaming = FALSE,
      random_selection = FALSE,
      parallel = TRUE,
      ...
    )
  }, finally = {
    # Restore original cached models
    if (!is.null(original_env_models)) {
      assign("ionet_models_cache", original_env_models, envir = .GlobalEnv)
    } else {
      # Remove the temporary cache
      if (exists("ionet_models_cache", envir = .GlobalEnv)) {
        rm("ionet_models_cache", envir = .GlobalEnv)
      }
      if (exists("ionet_models_cache_time", envir = .GlobalEnv)) {
        rm("ionet_models_cache_time", envir = .GlobalEnv)
      }
    }
  })
}

#' Print method for multiLLM_result
#' @param x A multiLLM_result object
#' @param ... Additional arguments (unused)
#' @export
print.multiLLM_result <- function(x, ...) {
  cat("Multi-LLM Execution Result\n")
  cat("==========================\n\n")
  
  cat(">> Summary:\n")
  cat("  Models executed:", x$summary$total_models, "\n")
  cat("  Successful:", x$summary$successful_models, "\n") 
  cat("  Failed:", x$summary$failed_models, "\n")
  cat("  Success rate:", x$summary$success_rate, "%\n")
  cat("  Total time:", round(x$summary$total_execution_time, 2), "seconds\n")
  cat("  Average time per model:", round(x$summary$avg_model_time, 2), "seconds\n")
  cat("  Total tokens used:", x$summary$total_tokens_used, "\n\n")
  
  if (x$summary$failed_models > 0) {
    cat("[ERROR] Failed models:\n")
    for (model_name in x$summary$failed_model_names) {
      cat("  -", model_name, "\n")
    }
    cat("\n")
  }
  
  cat(">> Successful responses available for", x$summary$successful_models, "models\n")
  cat("   Use result$results to access individual responses\n")
}