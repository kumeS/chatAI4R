#' Multi-LLM via io.net API
#'
#' @title multiLLMviaionet: Execute ALL available LLM models simultaneously via io.net API
#' @description This function automatically runs the same prompt across ALL currently available
#'   LLM models on the io.net API (by default it now selects one random model to reduce API load).
#'   It supports running multiple models (configurable) in parallel with streaming
#'   responses and comprehensive error handling.
#'
#'   The function dynamically fetches the current list of available models from the io.net API
#'   and executes a configurable subset (default 1 random model; set max_models or random_selection to control). Results are
#'   cached for 1 hour to improve performance. If the API is unavailable, it falls back to a static model list.
#'
#'   Typical models observed on io.net (30-Nov-2025) include:
#'   - moonshotai/Kimi-K2-Thinking, moonshotai/Kimi-K2-Instruct-0905
#'   - zai-org/GLM-4.6
#'   - meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8, Llama-3.3-70B-Instruct, Llama-3.2-90B-Vision-Instruct
#'   - Qwen/Qwen3-235B-A22B-Thinking-2507, Qwen3-Next-80B-A3B-Instruct, Qwen2.5-VL-32B-Instruct, Intel/Qwen3-Coder-480B-A35B-Instruct-int4-mixed-ar
#'   - deepseek-ai/DeepSeek-R1-0528
#'   - mistralai/Devstral-Small-2505, Magistral-Small-2506, Mistral-Large-Instruct-2411, Mistral-Nemo-Instruct-2407
#'   - openai/gpt-oss-120b, openai/gpt-oss-20b
#'
#' @param prompt A string containing the input prompt to send to all selected models.
#' @param max_models Integer specifying maximum number of models to run (1-50). Default is 1 (single model).
#' @param streaming Logical indicating whether to use streaming responses. Default is FALSE.
#' @param random_selection Logical indicating whether to randomly select models from all available models.
#'   If TRUE (default), randomly selects up to max_models from all available models.
#'   If FALSE, uses models in order (up to max_models limit).
#' @param api_key A string containing the io.net API key.
#'   Defaults to the environment variable "IONET_API_KEY".
#' @param max_tokens Integer specifying maximum tokens to generate per model. Default is 1024.
#' @param temperature Numeric value controlling randomness (0-2). Default is 0.7.
#' @param timeout Numeric value in seconds for request timeout per model. Default is 300.
#' @param parallel Logical indicating whether to run models in parallel. Default is TRUE.
#' @param verbose Logical indicating whether to show detailed progress. Default is TRUE.
#' @param refresh_models Logical indicating whether to force-refresh the io.net model list before execution. Default is FALSE.
#' @param retries Integer number of retries for transient errors (429/5xx/timeout/connection). Default is 1.
#' @param retry_wait Base wait in seconds before retry (multiplied by attempt count). Default is 2.
#' @param monitor_timeout Maximum seconds to wait for all async futures in the progress loop (prevents hangs). Default is 120.
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
#'   # Basic usage - single random model (default)
#'   result_one <- multiLLMviaionet(
#'     prompt = "Explain quantum computing in simple terms"
#'   )
#'   print(result_one$summary)
#'   print_multiLLM_results(result_one)
#'
#'   # Run first 5 models in list order (no random selection)
#'   result_top5 <- multiLLMviaionet(
#'     prompt = "What is machine learning?",
#'     max_models = 5,
#'     random_selection = FALSE
#'   )
#'   print_multiLLM_results(result_top5)
#'
#'   # Random selection of 10 models from all available
#'   result_random10 <- multiLLMviaionet(
#'     prompt = "Write a Python function to calculate fibonacci numbers",
#'     max_models = 10,
#'     random_selection = TRUE,
#'     temperature = 0.3,
#'     streaming = FALSE
#'   )
#'   print_multiLLM_results(result_random10)
#' }

multiLLMviaionet <- function(prompt,
                             max_models = 1,
                             streaming = FALSE,
                             random_selection = TRUE,
                              api_key = Sys.getenv("IONET_API_KEY"),
                             max_tokens = 1024,
                             temperature = 0.7,
                             timeout = 300,
                             parallel = TRUE,
                             verbose = TRUE,
                             refresh_models = FALSE,
                             retries = 1,
                             retry_wait = 2,
                             monitor_timeout = 120) {

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

  # Get list of available models (with dynamic API fetching). Force refresh if requested.
  available_models <- .get_ionet_available_models(
    api_key = api_key,
    force_refresh = refresh_models,
    verbose = verbose
  )

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
      timeout, streaming, verbose, retries, retry_wait, monitor_timeout
    )
  } else {
    results <- .execute_models_sequential(
      prompt, processed_models, api_key, max_tokens, temperature,
      timeout, streaming, verbose, retries, retry_wait
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
  cache_env <- .get_cache_env()
  cache_duration <- 3600  # Cache for 1 hour

  # Get cached data if available and not forcing refresh
  if (!force_refresh && exists(cache_key, envir = cache_env, inherits = FALSE) && exists(cache_time_key, envir = cache_env, inherits = FALSE)) {
    cached_time <- get(cache_time_key, envir = cache_env, inherits = FALSE)
    if (as.numeric(difftime(Sys.time(), cached_time, units = "secs")) < cache_duration) {
      cached_models <- get(cache_key, envir = cache_env, inherits = FALSE)
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
    assign(cache_key, api_models, envir = cache_env)
    assign(cache_time_key, Sys.time(), envir = cache_env)

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
    # Updated static fallback list (2025-02) reflecting current io.net catalogue
    "moonshotai/Kimi-K2-Thinking",
    "zai-org/GLM-4.6",
    "moonshotai/Kimi-K2-Instruct-0905",
    "meta-llama/Llama-3.2-90B-Vision-Instruct",
    "openai/gpt-oss-120b",
    "Qwen/Qwen2.5-VL-32B-Instruct",
    "deepseek-ai/DeepSeek-R1-0528",
    "Qwen/Qwen3-Next-80B-A3B-Instruct",
    "Qwen/Qwen3-235B-A22B-Thinking-2507",
    "Intel/Qwen3-Coder-480B-A35B-Instruct-int4-mixed-ar",
    "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8",
    "mistralai/Mistral-Nemo-Instruct-2407",
    "openai/gpt-oss-20b",
    "mistralai/Devstral-Small-2505",
    "mistralai/Magistral-Small-2506",
    "meta-llama/Llama-3.3-70B-Instruct",
    "mistralai/Mistral-Large-Instruct-2411"
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
      cat(">> Use multiLLMviaionet(prompt, max_models=10, random_selection=TRUE) for random model testing\n")

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
                                    timeout, streaming, verbose, retries, retry_wait, monitor_timeout) {

  if (verbose) {
    cat(">> Executing", length(models), "models in parallel (async)\n")
  }

  # Suppress package loading messages in parallel execution
  suppressPackageStartupMessages({
    future::plan(future::multisession, workers = min(length(models), 6))
  })

  # Create futures for each model with suppressed messages
  futures_list <- list()
  results <- list()
  monitor_start <- Sys.time()
  for (i in seq_along(models)) {
    futures_list[[models[i]]] <- future::future({
      # Execute single model (package functions are automatically available in workers)
      .execute_single_model(
        prompt, models[i], api_key, max_tokens, temperature,
        timeout, streaming, verbose = FALSE, retries = retries, retry_wait = retry_wait  # Disable verbose for cleaner parallel output
      )
    })
  }

  # Monitor progress
  if (verbose) {
    cat(">> Monitoring async execution progress:\n")
    completed_count <- 0
    monitor_start <- Sys.time()

    while (completed_count < length(models)) {
      for (model in names(futures_list)) {
        if (future::resolved(futures_list[[model]])) {
          result <- tryCatch(future::value(futures_list[[model]]), error = function(e) NULL)
          if (!is.null(result) && !is.null(result$model)) {
            completed_count <- completed_count + 1
            status <- if (result$success) "[OK]" else "[ERROR]"
            cat("  ", status, result$model, "completed (", completed_count, "/", length(models), ")\n")
            results[[model]] <- result
            futures_list[[model]] <- NULL  # Remove completed future
          }
        }
      }
      if (completed_count < length(models)) {
        # Check for monitor timeout
        elapsed <- as.numeric(difftime(Sys.time(), monitor_start, units = "secs"))
        if (!is.null(monitor_timeout) && elapsed > monitor_timeout) {
          if (verbose) cat("[WARN] Monitor timed out after", monitor_timeout, "seconds. Marking remaining futures as timed out.\n")
          break
        }
        Sys.sleep(0.5)  # Brief pause before next check
      }
    }
  }

  # Collect all results with suppressed messages
  suppressPackageStartupMessages({
    for (model in models) {
      if (!is.null(futures_list[[model]])) {
        resolved_now <- future::resolved(futures_list[[model]])
        if (resolved_now) {
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
        } else {
          results[[model]] <- list(
            model = model,
            response = NULL,
            success = FALSE,
            execution_time = as.numeric(difftime(Sys.time(), monitor_start, units = "secs")),
            usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
            timestamp = Sys.time(),
            error = paste0("Timed out after ", monitor_timeout, " seconds")
          )
        }
      } else if (is.null(results[[model]])) {
        # Ensure each requested model has an entry (in case of unexpected early removal)
        results[[model]] <- list(
          model = model,
          response = NULL,
          success = FALSE,
          execution_time = 0,
          usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
          timestamp = Sys.time(),
          error = "Result missing after parallel execution"
        )
      }
    }
  })

  if (verbose) {
    cat(">> All", length(models), "models completed asynchronously\n")
    failed <- Filter(function(x) !is.null(x) && !x$success, results)
    if (length(failed) > 0) {
      cat(">> Failed models (reason):\n")
      for (f in failed) {
        reason <- f$error
        label <- if (!is.null(reason) && grepl("Timed out", reason, ignore.case = TRUE)) "[TIMEOUT]" else "[FAIL]"
        cat("   ", label, f$model, "-", reason, "\n")
      }
    }
  }

  return(results)
}

# Helper function: Execute models sequentially
.execute_models_sequential <- function(prompt, models, api_key, max_tokens, temperature,
                                     timeout, streaming, verbose, retries, retry_wait) {

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
      prompt, model, api_key, max_tokens, temperature, timeout, streaming, verbose, retries, retry_wait
    )
  }

  return(results)
}

# Helper function: Execute single model with enhanced debugging
.execute_single_model <- function(prompt, model, api_key, max_tokens, temperature,
                                 timeout, streaming, verbose = TRUE, retries = 1, retry_wait = 2) {

  start_time <- Sys.time()
  attempt <- 1
  last_error <- NULL
  
  # Helper: extract response text from various possible structures
  .extract_response_text <- function(parsed_response, streaming) {
    # Standard OpenAI-ish choices structure
    if (!is.null(parsed_response$choices) && length(parsed_response$choices) > 0) {
      ch <- parsed_response$choices[[1]]
      parts <- character(0)
      # streaming delta
      if (streaming && !is.null(ch$delta) && !is.null(ch$delta$content)) {
        parts <- c(parts, ch$delta$content)
      }
      # message content
      if (!is.null(ch$message) && !is.null(ch$message$content)) {
        mc <- ch$message$content
        if (is.list(mc) || length(mc) > 1) mc <- paste(unlist(mc), collapse = "\n")
        parts <- c(parts, mc)
      }
      # message reasoning_content (seen in some providers)
      if (!is.null(ch$message) && !is.null(ch$message$reasoning_content)) {
        parts <- c(parts, ch$message$reasoning_content)
      }
      # some providers return message$parts[[1]]$text
      if (!is.null(ch$message$parts) && length(ch$message$parts) > 0 && !is.null(ch$message$parts[[1]]$text)) {
        parts <- c(parts, ch$message$parts[[1]]$text)
      }
      # choices[[1]]$content
      if (!is.null(ch$content)) {
        cc <- ch$content
        if (is.list(cc) || length(cc) > 1) cc <- paste(unlist(cc), collapse = "\n")
        parts <- c(parts, cc)
      }
      # choices[[1]]$text
      if (!is.null(ch$text)) parts <- c(parts, ch$text)
      
      # Return the first non-empty part
      parts <- parts[nchar(trimws(parts)) > 0]
      if (length(parts) > 0) return(parts[1])
    }
    # Alternative top-level fields seen in some APIs
    if (!is.null(parsed_response$content)) return(parsed_response$content)
    if (!is.null(parsed_response$output)) return(parsed_response$output)
    if (!is.null(parsed_response$text)) return(parsed_response$text)
    if (!is.null(parsed_response$response)) return(parsed_response$response)
    if (!is.null(parsed_response$data) && !is.null(parsed_response$data$content)) return(parsed_response$data$content)
    NULL
  }

  repeat {
    this_start <- Sys.time()
    res <- tryCatch({
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
      httr::POST(
        url = "https://api.intelligence.io.solutions/api/v1/chat/completions",
        httr::add_headers(
          `Authorization` = paste("Bearer", api_key),
          `Content-Type` = "application/json"
        ),
        body = jsonlite::toJSON(body, auto_unbox = TRUE),
        encode = "json",
        httr::timeout(timeout)
      )
    }, error = function(e) e)

    # Handle transport-level errors
    if (inherits(res, "error")) {
      last_error <- res$message
      if (attempt <= retries && .is_transient_error(last_error, NA)) {
        if (verbose) cat("[WARN] Model", model, "attempt", attempt, "failed:", last_error, "- retrying\n")
        Sys.sleep(retry_wait * attempt)
        attempt <- attempt + 1
        next
      } else {
        end_time <- Sys.time()
        execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        if (verbose) cat("[ERROR] Error with model", model, ":", last_error, "\n")
        return(list(
          model = model,
          response = NULL,
          success = FALSE,
          execution_time = execution_time,
          usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
          timestamp = end_time,
          error = last_error
        ))
      }
    }

    status_code <- httr::status_code(res)
    error_content <- NULL

    if (status_code != 200) {
      error_content <- tryCatch(httr::content(res, "parsed"), error = function(e) NULL)
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

      last_error <- error_msg
      if (attempt <= retries && .is_transient_error(last_error, status_code)) {
        if (verbose) cat("[WARN] Model", model, "attempt", attempt, "got", status_code, "-", detailed_msg, "- retrying\n")
        Sys.sleep(retry_wait * attempt)
        attempt <- attempt + 1
        next
      } else {
        end_time <- Sys.time()
        execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        if (verbose) cat("[ERROR] Error with model", model, ":", error_msg, "\n")
        return(list(
          model = model,
          response = NULL,
          success = FALSE,
          execution_time = execution_time,
          usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0),
          timestamp = end_time,
          error = error_msg
        ))
      }
    }

    # Parse response with enhanced debugging (following JavaScript reference)
    parsed_response <- tryCatch({
      if (streaming == TRUE) {
        content_text <- httr::content(res, "text", encoding = "UTF-8")

        if (verbose) {
          cat("[DEBUG] Raw streaming response length:", nchar(content_text), "characters\n")
        }

        if (grepl("data:", content_text)) {
          lines <- strsplit(content_text, "\n")[[1]]
          data_lines <- lines[grepl("^data:\\s*", lines)]
          data_lines <- gsub("^data:\\s*", "", data_lines)
          data_lines <- data_lines[data_lines != "[DONE]" & nchar(trimws(data_lines)) > 0]

          if (length(data_lines) > 0) {
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
                if (verbose) cat("[WARNING] Skipping malformed chunk:", data_line, "\n")
              })
            }

            if (nchar(accumulated_content) > 0) {
              list(
                choices = list(list(
                  message = list(content = accumulated_content)
                )),
                usage = list(prompt_tokens = 0, completion_tokens = 0, total_tokens = 0)
              )
            } else {
              jsonlite::fromJSON(data_lines[length(data_lines)])
            }
          } else {
            stop("No valid streaming data chunks found in SSE response")
          }
        } else {
          jsonlite::fromJSON(content_text)
        }
      } else {
        httr::content(res, "parsed")
      }
    }, error = function(e) {
      raw_content <- tryCatch(httr::content(res, "text", encoding = "UTF-8"), error = function(e2) "Unable to extract content")
      stop("Failed to parse API response for model '", model, "'. Raw content (first 500 chars): ",
           substr(raw_content, 1, 500), ". Parse error: ", e$message)
    })

    response_text <- .extract_response_text(parsed_response, streaming)
    if (is.null(response_text) || (is.character(response_text) && nchar(trimws(response_text)) == 0)) {
      response_structure <- capture.output(utils::str(parsed_response, max.level = 2))
      response_names <- if (is.list(parsed_response)) names(parsed_response) else "Not a list"
      debug_info <- paste(
        "API Response Debug Info for model", model, ":",
        "\nResponse has", length(parsed_response), "top-level elements.",
        "\nTop-level names:", paste(response_names, collapse = ", "),
        "\nResponse structure (first 3 levels):",
        paste(response_structure[1:min(10, length(response_structure))], collapse = "\n"),
        "\nFirst 200 chars of raw response:",
        substr(httr::content(res, "text", encoding = "UTF-8"), 1, 200)
      )
      stop("No valid content found in API response for model '", model, "'. ", debug_info)
    }

    if (is.null(response_text) || length(response_text) == 0 ||
        (is.character(response_text) && nchar(trimws(response_text)) == 0)) {
      last_error <- paste0("Model '", model, "' returned empty or null content")
      if (attempt <= retries && .is_transient_error(last_error, status_code)) {
        if (verbose) cat("[WARN] Model", model, "attempt", attempt, "returned empty content - retrying\n")
        Sys.sleep(retry_wait * attempt)
        attempt <- attempt + 1
        next
      } else {
        stop(last_error)
      }
    }

    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

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
      raw_response = parsed_response,  # keep full parsed payload to handle provider-specific formats
      success = TRUE,
      execution_time = execution_time,
      usage = usage_info,
      timestamp = end_time,
      error = NULL
    ))
  }
}

# Helper function: Summarize results
.summarize_results <- function(results, total_time, verbose) {

  successful_results <- Filter(function(x) x$success, results)
  failed_results <- Filter(function(x) !x$success, results)

  success_count <- length(successful_results)
  total_count <- length(results)
  success_rate <- if (total_count > 0) round((success_count / total_count) * 100, 1) else 0

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
    failed_details = if (length(failed_results) > 0) {
      lapply(failed_results, function(x) {
        list(
          model = x$model,
          error = x$error,
          execution_time = x$execution_time
        )
      })
    } else {
      list()
    },
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

# Utility: determine if error is transient for retry logic
.is_transient_error <- function(message, status_code = NA) {
  transient_codes <- c(408, 429, 500, 502, 503, 504)
  if (!is.na(status_code) && status_code %in% transient_codes) return(TRUE)
  if (is.null(message)) return(FALSE)
  any(grepl("(timeout|timed out|connection|temporarily unavailable|retry)", message, ignore.case = TRUE))
}

#' Pretty-print multiLLMviaionet results
#'
#' @description Display model responses with status, handling NULLs and errors cleanly.
#' @param result A result object returned by `multiLLMviaionet()`.
#' @param show_failed Logical; if TRUE (default), also prints failed/timeout models and their errors.
#' @param trim Optional integer; if not NULL, truncates long responses to the first `trim` characters for display.
#' @return Invisibly returns NULL.
#' @export print_multiLLM_results
print_multiLLM_results <- function(result, show_failed = TRUE, trim = NULL) {
  if (is.null(result$results)) {
    cat("[WARN] No results to display.\n")
    return(invisible(NULL))
  }

  for (res in result$results) {
    model <- res$model %||% "<unknown>"
    status <- if (isTRUE(res$success)) "OK" else if (!is.null(res$error) && grepl("Timed out", res$error, ignore.case = TRUE)) "TIMEOUT" else "FAIL"
    cat("[", status, "] ", model, ":\n", sep = "")
    out <- res$response
    # Normalize response to a single character string
    if (!is.null(out)) {
      if (is.list(out)) {
        out <- paste(capture.output(utils::str(out, max.level = 2)), collapse = "\n")
      }
      out <- paste(out, collapse = "\n")
      if (all(is.na(out)) || !nchar(trimws(out))) {
        out <- NULL
      }
    }

    if (!is.null(out)) {
      if (!is.null(trim) && nchar(out) > trim) {
        out <- paste0(substr(out, 1, trim), " ...")
      }
      cat(out, "\n\n")
    } else if (!isTRUE(res$success) && show_failed) {
      cat("[no response] - ", res$error %||% "Unknown error", "\n\n", sep = "")
    } else {
      cat("[no response]\n\n")
    }
  }

  invisible(NULL)
}

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

#' List io.net Models (simple alias)
#'
#' @title ionet_models: Retrieve the available model list from io.net API
#' @description Convenience wrapper around list_ionet_models() to get the current model list.
#'   By default it uses cached data; set force_refresh = TRUE to refetch.
#'
#' @param api_key Optional API key for fetching current models. Defaults to IONET_API_KEY environment variable.
#' @param verbose Logical indicating whether to show detailed fetching information. Default is TRUE.
#' @param force_refresh Logical indicating whether to force refresh the model list from API. Default is FALSE.
#'
#' @return A character vector of model names, or a data frame if detailed=TRUE in the underlying call.
#' @export ionet_models
ionet_models <- function(api_key = NULL, verbose = TRUE, force_refresh = FALSE) {
  list_ionet_models(
    category = "all",
    detailed = FALSE,
    api_key = api_key,
    force_refresh = force_refresh,
    verbose = verbose
  )
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




#' Print method for multiLLM_result
#' @param x A multiLLM_result object
#' @param ... Additional arguments (unused)
#' @export
#' @method print multiLLM_result
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
