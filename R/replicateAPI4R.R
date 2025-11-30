#' replicatellmAPI4R: Interact with Replicate API for LLM models in R
#'
#' @description This function interacts with the Replicate API (v1) to utilize
#' language models (LLM) such as Llama. It sends a POST request with the provided
#' input and handles both streaming and non-streaming responses.
#'
#' **Note**: This function is primarily designed and optimized for Large Language
#' Models (LLMs). While the Replicate API supports various model types
#' (e.g., image generation, audio models), this function's features (especially `collapse_tokens`)
#' are tailored for LLM text outputs. For non-LLM models, consider setting `collapse_tokens = FALSE`
#' or use the full response mode with `simple = FALSE`.
#'
#' @param input A list containing the API request body with parameters including prompt,
#' max_tokens, top_k, top_p, min_tokens, temperature, system_prompt, presence_penalty, and frequency_penalty.
#' @param model_url A character string specifying the model endpoint URL (e.g., "/models/meta/meta-llama-3.1-405b-instruct/predictions").
#' @param simple A logical value indicating whether to return a simplified output (only the model output) if TRUE,
#' or the full API response if FALSE. Default is TRUE.
#' @param fetch_stream A logical value indicating whether to fetch a streaming response. Default is FALSE.
#' @param collapse_tokens A logical value indicating whether to collapse token vectors
#' into a single string for LLM text outputs. When TRUE (default), token vectors like
#' c("The", " capital", " of", " France") are automatically combined into "The capital of France".
#' This parameter only affects LLM text outputs and has no effect on other model types (e.g., image URLs, audio data).
#' Default is TRUE.
#' @param api_key A character string representing the Replicate API key. Defaults to the environment variable "Replicate_API_KEY".
#'
#' @importFrom httr add_headers POST GET content
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom curl new_handle handle_setopt handle_setheaders curl_fetch_stream
#' @importFrom assertthat assert_that is.string is.flag noNA
#'
#' @return If fetch_stream is FALSE, returns either a simplified output (if simple is TRUE)
#' or the full API response. When simple is TRUE and collapse_tokens is TRUE, returns a single character string.
#' In streaming mode, outputs the response stream directly to the console.
#'
#' @examples
#' \dontrun{
#'   Sys.setenv(Replicate_API_KEY = "Your API key")
#'   input <- list(
#'     input = list(
#'       prompt = "What is the capital of France?",
#'       max_tokens = 1024,
#'       top_k = 50,
#'       top_p = 0.9,
#'       min_tokens = 0,
#'       temperature = 0.6,
#'       system_prompt = "You are a helpful assistant.",
#'       presence_penalty = 0,
#'       frequency_penalty = 0
#'     )
#'   )
#'   model_url <- "/models/meta/meta-llama-3.1-405b-instruct/predictions"
#'
#'   # Default: collapse_tokens = TRUE (returns single string)
#'   response <- replicatellmAPI4R(input, model_url, fetch_stream = TRUE)
#'   print(response)
#'   # [1] "The capital of France is Paris."
#'
#'   # Keep tokens separated
#'   response_tokens <- replicatellmAPI4R(input, model_url, fetch_stream = TRUE,
#'                                        collapse_tokens = FALSE)
#'   print(response_tokens)
#'   # [1] "The" " capital" " of" " France" " is" " Paris" "."
#' }
#'
#' @export replicatellmAPI4R
#' @author Satoshi Kume
replicatellmAPI4R <- function(input,
                              model_url,
                              simple = TRUE,
                              fetch_stream = FALSE,
                              collapse_tokens = TRUE,
                              api_key = Sys.getenv("Replicate_API_KEY")) {

  # Validate input arguments using assertthat functions
  assertthat::assert_that(
    #input = list(NA)
    is.list(input),
    assertthat::is.string(model_url),
    assertthat::is.flag(simple),
    assertthat::is.flag(fetch_stream),
    assertthat::is.flag(collapse_tokens),
    assertthat::is.string(api_key),
    assertthat::noNA(api_key)
  )

  # Define the base API URL and construct the full API endpoint URL by concatenating the base URL and model URL
  api_url <- "https://api.replicate.com/v1/"
  api_url0 <- paste0(api_url, model_url)
  # Remove any accidental double slashes from the URL
  api_url0 <- gsub("\\/\\/", "\\/", api_url0)

  # Configure HTTP headers for the API request, including content type and authorization
  headers <- httr::add_headers(
    `Content-Type` = "application/json",
    `Authorization` = paste("Bearer", api_key)
  )

  # Define the body of the API request using the input provided
  body <- input

  # Send a POST request to the Replicate API endpoint with the JSON-encoded body and headers
  response <- httr::POST(
    url = api_url0,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )

  # Check HTTP status code first
  if (httr::status_code(response) != 200 && httr::status_code(response) != 201) {
    error_content <- httr::content(response, "parsed")
    error_msg <- if (!is.null(error_content$detail)) {
      error_content$detail
    } else {
      paste("HTTP", httr::status_code(response), "error")
    }
    stop("API Error (", httr::status_code(response), "): ", error_msg)
  }

  # If fetch_stream is TRUE, handle streaming response mode
  if (fetch_stream) {
    # Parse response content safely
    parsed_response <- httr::content(response, "parsed")

    # Safe access to get URL
    if (!is.null(parsed_response$urls) && !is.null(parsed_response$urls$get)) {
      get_url <- parsed_response$urls$get
    } else {
      stop("Unexpected API response format: missing URLs or get URL")
    }

    # Initialize result as NULL to start polling with timeout protection
    result <- NULL
    timeout_seconds <- 300  # 5 minutes timeout
    start_time <- Sys.time()
    retry_count <- 0
    max_retries <- 5

    # Poll the get_url until the result is ready or timeout occurs
    while (is.null(result) && (Sys.time() - start_time) < timeout_seconds) {
      response_output <- httr::GET(get_url, headers)

      # Check polling response status with improved error handling
      if (httr::status_code(response_output) != 200) {
        retry_count <- retry_count + 1
        if (retry_count > max_retries) {
          stop("Max polling retries (", max_retries, ") exceeded with HTTP status: ", httr::status_code(response_output))
        }
        # Exponential backoff: wait 2^retry_count seconds, max 30 seconds
        backoff_time <- min(2^retry_count, 30)
        warning("Polling request failed with status: ", httr::status_code(response_output),
                ". Retrying in ", backoff_time, " seconds (attempt ", retry_count, "/", max_retries, ")")
        Sys.sleep(backoff_time)
        next
      }

      # Reset retry count on successful request
      retry_count <- 0

      # Parse the response text into JSON
      content <- jsonlite::fromJSON(httr::content(response_output, "text", encoding = "UTF-8"))

      if (!is.null(content$status)) {
        if (content$status == "succeeded") {
          # If prediction succeeded, assign the result to response_result and update result to exit the loop
          response_result <- content
          result <- response_result
        } else if (content$status == "failed") {
          # If prediction failed, throw an error
          error_msg <- if (!is.null(content$error)) content$error else "Prediction failed"
          stop("Prediction failed: ", error_msg)
        } else {
          # Wait for 1 second before polling again
          Sys.sleep(1)
        }
      } else {
        # If status is missing, wait and continue
        Sys.sleep(1)
      }
    }

    # Check if we exited due to timeout
    if (is.null(result)) {
      stop("Request timed out after ", timeout_seconds, " seconds")
    }

    # Return a simplified output if simple is TRUE, otherwise return the full response
    if (simple) {
      output <- response_result$output

      # Collapse token vectors into a single string if collapse_tokens is TRUE
      # This is useful for LLM outputs that return tokens as separate vector elements
      if (collapse_tokens && is.character(output) && length(output) > 1) {
        output <- paste(output, collapse = "")
      }

      return(output)
    } else {
      return(response_result)
    }
  } else {
    # If fetch_stream is FALSE, handle non-streaming mode

    # Parse response content safely
    parsed_response <- httr::content(response, "parsed")

    # Safe access to stream URL
    if (!is.null(parsed_response$urls) && !is.null(parsed_response$urls$stream)) {
      stream_url <- parsed_response$urls$stream
    } else {
      stop("Unexpected API response format: missing URLs or stream URL")
    }

    # Define a callback function to process streaming data chunks as they arrive
    streaming_callback <- function(data) {
      # Convert raw data to character
      message <- rawToChar(data)
      # Output the message with a newline for clarity
      cat(message, "\n")
      # Return TRUE to indicate processing was successful
      TRUE
    }

    # Create a new curl handle for the streaming request
    stream_handle <- curl::new_handle()
    # Set the streaming URL on the handle
    curl::handle_setopt(stream_handle, url = stream_url)
    # Set the required headers for the streaming request, including authorization and content type
    curl::handle_setheaders(stream_handle,
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    )

    # Send the streaming request, processing data using the defined callback function
    curl::curl_fetch_stream(url = stream_url, fun = streaming_callback, handle = stream_handle)
  }
}
