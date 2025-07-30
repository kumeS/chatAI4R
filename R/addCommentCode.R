#' Add Comments to R Code
#'
#' @title Add Comments to R Code
#' @description This function adds comments to R code without modifying the input R code.
#'    It can either take the selected code from RStudio or read from the clipboard.
#'    Supports multiple AI providers: OpenAI, Google Gemini, and Google Vertex AI.
#' @param Model A character string specifying the AI model to be used. Default is "gpt-4o-mini".
#'    Examples: "gpt-4o-mini", "gemini-2.0-flash", "gemini-1.5-pro" etc.
#' @param language A character string specifying the language for the comments. Default is "English".
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
#' @param provider A character string specifying the AI provider. Options: "auto", "openai", "gemini", "vertex".
#'    Default is "auto" which automatically detects available API keys (OpenAI -> Gemini -> Vertex AI).
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom httr POST add_headers content http_error status_code
#' @importFrom jsonlite toJSON fromJSON
#' @return A message indicating completion if `SelectedCode` is TRUE, otherwise the commented code is copied to the clipboard.
#' @export addCommentCode
#'
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Auto-detect provider (OpenAI -> Gemini -> Vertex AI)
#' addCommentCode(Model = "gpt-4o-mini", SelectedCode = TRUE)
#' 
#' # Explicitly use OpenAI
#' addCommentCode(Model = "gpt-4o-mini", provider = "openai", SelectedCode = TRUE)
#' 
#' # Use Google Gemini
#' addCommentCode(Model = "gemini-2.0-flash", provider = "gemini", SelectedCode = TRUE)
#' 
#' # Use Google Vertex AI
#' addCommentCode(Model = "gemini-1.5-pro", provider = "vertex", SelectedCode = TRUE)
#' }

addCommentCode <- function(Model = "gpt-4o-mini",
                           language = "English",
                           SelectedCode = TRUE,
                           provider = "auto") {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    assertthat::is.string(provider),
    provider %in% c("auto", "openai", "gemini", "vertex")
  )

  # Helper function to check API keys
  check_api_keys <- function() {
    list(
      openai = Sys.getenv("OPENAI_API_KEY") != "",
      gemini = Sys.getenv("GoogleGemini_API_KEY") != "",
      vertex = Sys.getenv("GOOGLE_CLOUD_PROJECT") != "" && 
               (Sys.getenv("GOOGLE_ACCESS_TOKEN") != "" || system("which gcloud", ignore.stderr = TRUE) == 0)
    )
  }

  # Determine which provider to use
  available_keys <- check_api_keys()
  
  if (provider == "auto") {
    if (available_keys$openai) {
      provider <- "openai"
    } else if (available_keys$gemini) {
      provider <- "gemini"
    } else if (available_keys$vertex) {
      provider <- "vertex"
    } else {
      stop("No API keys available. Please set OPENAI_API_KEY, GoogleGemini_API_KEY, or configure Google Cloud credentials.")
    }
  } else {
    # Validate specific provider
    if (provider == "openai" && !available_keys$openai) {
      stop("OpenAI API key not found. Please set OPENAI_API_KEY environment variable.")
    } else if (provider == "gemini" && !available_keys$gemini) {
      stop("Google Gemini API key not found. Please set GoogleGemini_API_KEY environment variable.")
    } else if (provider == "vertex" && !available_keys$vertex) {
      stop("Google Cloud credentials not found. Please set GOOGLE_CLOUD_PROJECT and GOOGLE_ACCESS_TOKEN or configure gcloud.")
    }
  }

  # Initialize temperature for text generation
  temperature <- 1

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled genius R programmer.
  You always give great answers about the R language.
  You should add inline comments to explain this code. Your output goes directly into a source (.R) file.
  You should comment the code line by line without modifying the input R code.
  You should provide a one-sentence summary comment for each run, without redundant explanations.
  You should output only the text of the deliverable in %s.
  "

  template <- sprintf(template, language)

  template1 <- "
  Please add inline comments to explain the following input code without changing the input R code.:
  "

  # Create the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Execute text generation based on provider
  if (provider == "openai") {
    # Initialize history for chat
    history <- list(list('role' = 'system', 'content' = template),
                    list('role' = 'user', 'content' = template1s))
    
    res <- as.character(chat4R_history(history = history,
                          Model = Model,
                          temperature = temperature))
  } else if (provider == "gemini") {
    # Use gemini4R for Gemini API
    messages <- list(
      list(role = "user", text = paste(template, template1s))
    )
    
    result <- gemini4R(mode = "chat", 
                       contents = messages, 
                       model = Model)
    
    res <- result$candidates[[1]]$content$parts[[1]]$text
    
  } else if (provider == "vertex") {
    # Use Vertex AI
    res <- vertex_ai_chat(
      prompt = paste(template, template1s),
      model = Model,
      temperature = temperature
    )
  }

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(res))
  }
}

# Helper function for Vertex AI
vertex_ai_chat <- function(prompt, model = "gemini-1.5-pro", temperature = 0.7) {
  project_id <- Sys.getenv("GOOGLE_CLOUD_PROJECT")
  access_token <- get_vertex_access_token()
  
  endpoint <- sprintf(
    "https://%s-aiplatform.googleapis.com/v1/projects/%s/locations/%s/publishers/google/models/%s:generateContent",
    "us-central1", project_id, "us-central1", model
  )
  
  body <- list(
    contents = list(
      list(
        role = "user",
        parts = list(list(text = prompt))
      )
    ),
    generationConfig = list(
      temperature = temperature,
      maxOutputTokens = 2048
    )
  )
  
  response <- httr::POST(
    url = endpoint,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    httr::add_headers(
      "Authorization" = paste("Bearer", access_token),
      "Content-Type" = "application/json"
    )
  )
  
  if (httr::http_error(response)) {
    stop("Vertex AI API error: ", httr::status_code(response))
  }
  
  result <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))
  
  if (!is.null(result$candidates) && length(result$candidates) > 0) {
    return(result$candidates[[1]]$content$parts[[1]]$text)
  } else {
    stop("No response generated from Vertex AI")
  }
}

# Helper function to get Vertex AI access token
get_vertex_access_token <- function() {
  # Try environment variable first
  token <- Sys.getenv("GOOGLE_ACCESS_TOKEN")
  if (token != "") {
    return(token)
  }
  
  # Try gcloud command
  result <- tryCatch({
    system("gcloud auth print-access-token", intern = TRUE, ignore.stderr = TRUE)
  }, error = function(e) {
    stop("Could not get Google Cloud access token. Please set GOOGLE_ACCESS_TOKEN or run 'gcloud auth login'")
  })
  
  if (length(result) > 0 && !grepl("ERROR", result[1])) {
    return(trimws(result[1]))
  } else {
    stop("Could not get Google Cloud access token. Please set GOOGLE_ACCESS_TOKEN or run 'gcloud auth login'")
  }
}
