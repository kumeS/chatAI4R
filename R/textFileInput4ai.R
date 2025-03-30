#' Send Text File Content to OpenAI API and Retrieve Response
#'
#' This function reads the content of a specified text file, sends it to the OpenAI API
#' using the provided API key, and retrieves the generated response from the GPT model.
#' If the text content exceeds the max_input_chars threshold, it will be automatically split
#' into smaller chunks based on character count and processed separately, with results returned as a list.
#' The function handles invalid multibyte strings automatically by cleaning and converting text encoding.
#' It can also handle files with header rows and displays progress during processing.
#'
#' @param file_path A string representing the path to the text or csv file to be read and sent to the API.
#' @param api_key A string containing the OpenAI API key. Defaults to the "OPENAI_API_KEY" environment variable.
#' @param model A string specifying the OpenAI model to be used (default is "gpt-4o-mini").
#' @param system_prompt Optional. A system-level instruction that can be used to guide the model's behavior
#' (default is "You are a helpful assistant to analyze your input.").
#' @param max_tokens A numeric value specifying the maximum number of tokens to generate (default is 50).
#' @param max_input_chars A numeric value specifying the maximum number of characters to send in a single API request.
#'        If the text content exceeds this value, it will be split into chunks (default is 10000).
#' @param has_header Logical indicating whether the input file has a header row (default is TRUE).
#' @param show_progress Logical indicating whether to display progress information during processing (default is TRUE).
#' @param summarize_results Logical indicating whether to summarize the final results using the system prompt (default is FALSE).
#'        Only applies when text content is split into multiple chunks.
#'
#' @return If the text content is within the max_input_chars limit, returns a character string containing
#'         the response from the OpenAI API. If the content exceeds the limit, returns a list of responses.
#'         If the text file contains invalid multibyte characters, the function will attempt to clean and
#'         normalize the text before processing. If summarize_results is TRUE and chunks are processed,
#'         an additional summarized response will be returned as the last element of the list.
#' @importFrom httr POST add_headers content
#' @importFrom jsonlite toJSON
#' @importFrom assertthat assert_that is.string is.number is.count noNA
#' @author Satoshi Kume
#' @export textFileInput4ai
#' @examples
#' \dontrun{
#'   # Example usage of the function
#'   api_key <- "YOUR_OPENAI_API_KEY"
#'   file_path <- "path/to/your/text_file.txt"
#'   response <- textFileInput4ai(file_path, api_key = api_key, max_tokens = 50)
#'
#' }


textFileInput4ai <- function(file_path,
                             model = "gpt-4o-mini",
                             system_prompt = "You are a helpful assistant to analyze your input.",
                             max_tokens = 1000,
                             max_input_chars = 10000,
                             api_key = Sys.getenv("OPENAI_API_KEY"),
                             has_header = TRUE,
                             show_progress = TRUE,
                             summarize_results = FALSE) {

  # Input validation
  assertthat::assert_that(
    assertthat::is.string(file_path),
    assertthat::noNA(file_path),
    assertthat::is.string(model),
    assertthat::is.string(system_prompt),
    assertthat::is.count(max_tokens),
    assertthat::is.count(max_input_chars),
    assertthat::is.string(api_key),
    nchar(api_key) > 0,
    is.logical(has_header),
    is.logical(show_progress),
    is.logical(summarize_results)
  )

  # Read the text content from the specified file
  tryCatch({
    # Try to read file with explicit encoding and handle any multibyte string issues
    lines <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
    # Clean any potentially problematic characters
    lines <- iconv(lines, from = "UTF-8", to = "UTF-8", sub = "")
  }, error = function(e) {
    # If UTF-8 reading fails, try with Latin1 encoding
    lines <- readLines(file_path, warn = FALSE, encoding = "Latin1")
    # Convert to UTF-8 and replace any problematic characters
    lines <- iconv(lines, from = "Latin1", to = "UTF-8", sub = "")
  })

  # Extract header if present
  header <- NULL
  if (has_header && length(lines) > 0) {
    header <- lines[1]
    lines <- lines[-1]
    if (show_progress) {
      cat("Header detected:", header, "\n")
    }
  }

  # Combine lines into text content
  text_content <- paste(lines, collapse = "\n")

  # Define the OpenAI API endpoint URL
  url <- "https://api.openai.com/v1/chat/completions"

  # Define the request headers including the API key for authorization
  headers <- c(
    "Content-Type" = "application/json",
    "Authorization" = paste("Bearer", api_key)
  )

  # Check if text content exceeds max_input_chars
  # First ensure text is properly encoded for accurate character count
  clean_text <- iconv(text_content, from = "UTF-8", to = "UTF-8", sub = "")
  if (nchar(clean_text) <= max_input_chars) {
    if (show_progress) {
      cat("Processing text as a single chunk (", nchar(clean_text), " characters)\n")
    }

    # Add header back if needed
    content_to_process <- clean_text
    if (!is.null(header)) {
      content_to_process <- paste(header, content_to_process, sep = "\n")
    }

    # Process as a single request
    body <- jsonlite::toJSON(list(
      model = model,
      messages = list(
        list(role = "system", content = system_prompt),
        list(role = "user", content = content_to_process)
      ),
      max_tokens = max_tokens
    ), auto_unbox = TRUE)

    # Send a POST request to the OpenAI API with the specified headers and body
    if (show_progress) {
      cat("Sending request to OpenAI API...\n")
    }
    response <- httr::POST(url, httr::add_headers(.headers = headers), body = body, encode = "json")

    # Parse the response content from the API
    result <- httr::content(response, "parsed", encoding = "UTF-8")

    # If the API returned valid choices, return the generated text; otherwise, throw an error
    if (!is.null(result$choices) && length(result$choices) > 0) {
      if (show_progress) {
        cat("Response received successfully.\n")
      }
      return(result$choices[[1]]$message$content)
    } else {
      stop("No response from OpenAI API. Check your API key and input data.")
    }
  } else {
    # Split the text content into chunks based on character count only
    # Ensure text_content is properly encoded and cleaned before measuring length
    clean_text <- iconv(text_content, from = "UTF-8", to = "UTF-8", sub = "")
    total_chars <- nchar(clean_text)
    num_chunks <- ceiling(total_chars / max_input_chars)

    if (show_progress) {
      cat("Text exceeds maximum input size. Splitting into", num_chunks, "chunks.\n")
      cat("Total characters:", total_chars, "\n")
    }

    # Create chunks by character position
    chunks <- character(num_chunks)
    for (i in 1:num_chunks) {
      start_pos <- (i - 1) * max_input_chars + 1
      end_pos <- min(i * max_input_chars, total_chars)
      chunks[i] <- tryCatch({
        substr(clean_text, start_pos, end_pos)
      }, error = function(e) {
        # If substring fails, return a placeholder and warning
        warning(paste("Error extracting chunk", i, ":", e$message))
        paste("Error processing text chunk", i, "- Invalid character encoding detected")
      })
    }

    # Process each chunk and collect responses
    responses <- list()
    for (i in seq_along(chunks)) {
      if (show_progress) {
        cat(sprintf("[%d/%d] Processing chunk %d (%.1f%% complete)...\n",
                   i, length(chunks), i, (i-1)/length(chunks) * 100))
      }

      # Add header to each chunk if needed
      chunk_content <- chunks[i]
      if (!is.null(header)) {
        chunk_content <- paste(header, chunk_content, sep = "\n")
      }

      # Add context about chunking to system prompt
      chunk_system_prompt <- paste0(
        system_prompt,
        " Note: This is part ", i, " of ", length(chunks),
        " from a larger document that has been split due to size limitations."
      )

      # Create the request body for this chunk
      body <- jsonlite::toJSON(list(
        model = model,
        messages = list(
          list(role = "system", content = chunk_system_prompt),
          list(role = "user", content = chunk_content)
        ),
        max_tokens = max_tokens
      ), auto_unbox = TRUE)

      # Send the request
      if (show_progress) {
        cat(sprintf("  Sending chunk %d to OpenAI API...\n", i))
      }
      response <- httr::POST(url, httr::add_headers(.headers = headers), body = body, encode = "json")

      # Parse the response
      result <- httr::content(response, "parsed", encoding = "UTF-8")

      # Store the response
      if (!is.null(result$choices) && length(result$choices) > 0) {
        responses[[i]] <- result$choices[[1]]$message$content
        if (show_progress) {
          cat(sprintf("  Chunk %d processed successfully.\n", i))
        }
      } else {
        responses[[i]] <- paste("Error processing chunk", i, "- No response from API")
        if (show_progress) {
          cat(sprintf("  Error processing chunk %d.\n", i))
        }
      }

      # Show progress percentage after each chunk
      if (show_progress) {
        cat(sprintf("Progress: %.1f%% complete (%d/%d chunks)\n",
                   i/length(chunks) * 100, i, length(chunks)))
      }
    }

    # Summarize the results if requested
    if (summarize_results && length(responses) > 1) {
      if (show_progress) {
        cat("Generating summary of all chunks using system prompt...\n")
      }

      # Create a combined response with all individual responses
      combined_responses <- paste(unlist(responses), collapse = "\n\n--- Next Chunk ---\n\n")

      # Create a summarization prompt
      summary_system_prompt <- paste0(
        "You are a helpful assistant that summarizes content. ",
        "Below are multiple responses that were generated from different chunks of a larger document. ",
        "Please synthesize these responses into a cohesive summary according to these instructions: ",
        system_prompt
      )

      # Create the request body for summarization
      body <- jsonlite::toJSON(list(
        model = model,
        messages = list(
          list(role = "system", content = summary_system_prompt),
          list(role = "user", content = combined_responses)
        ),
        max_tokens = max_tokens * 2  # Allow more tokens for summarization
      ), auto_unbox = TRUE)

      # Send the summarization request
      response <- httr::POST(url, httr::add_headers(.headers = headers), body = body, encode = "json")

      # Parse the response
      result <- httr::content(response, "parsed", encoding = "UTF-8")

      # Add the summary to the responses list
      if (!is.null(result$choices) && length(result$choices) > 0) {
        responses[[length(responses) + 1]] <- result$choices[[1]]$message$content
        if (show_progress) {
          cat("Summary generated successfully.\n")
        }
      } else {
        if (show_progress) {
          cat("Failed to generate summary.\n")
        }
      }
    }

    if (show_progress) {
      cat("Processing complete. Generated", length(responses), "responses.\n")
    }

    return(responses)
  }
}
