#' Add Comments to R Code
#'
#' @title Add Comments to R Code
#' @description This function adds comments to R code without modifying the input R code.
#'    It can either take the selected code from RStudio or read from the clipboard.
#' @param Model A character string specifying the model to be used. Default is "gpt-4o-mini" for OpenAI or "gemini-2.0-flash" for Gemini.
#' @param language A character string specifying the language for the comments. Default is "English".
#' @param SelectedCode A logical value indicating whether to use the selected code in RStudio. Default is TRUE.
#' @param provider A character string specifying the API provider. Options: "auto" (default), "openai", "gemini". When "auto", automatically detects available API keys with priority: OpenAI → Gemini.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip write_clip
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @return A message indicating completion if `SelectedCode` is TRUE, otherwise the commented code is copied to the clipboard.
#' @export addCommentCode
#'
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1: Auto-detect available API (OpenAI or Gemini)
#' # Select some text in RStudio and then run the rstudio addins
#' addCommentCode(Model = "gpt-4o-mini", language = "English", SelectedCode = TRUE)
#' 
#' # Option 2: Explicitly use OpenAI
#' addCommentCode(Model = "gpt-4o-mini", provider = "openai", SelectedCode = TRUE)
#' 
#' # Option 3: Use Gemini API
#' addCommentCode(Model = "gemini-2.0-flash", provider = "gemini", SelectedCode = TRUE)
#' 
#' # Option 4: Copy text to clipboard and execute
#' addCommentCode(Model = "gpt-4o-mini", language = "English", SelectedCode = FALSE)
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

  # Detect available API providers
  openai_available <- Sys.getenv("OPENAI_API_KEY") != ""
  gemini_available <- Sys.getenv("GoogleGemini_API_KEY") != ""
  
  # Auto-detect provider if not specified
  if (provider == "auto") {
    if (openai_available) {
      provider <- "openai"
    } else if (gemini_available) {
      provider <- "gemini"
    } else {
      stop("No API keys found. Set OPENAI_API_KEY or GoogleGemini_API_KEY environment variable.")
    }
  }
  
  # Validate selected provider has API key
  if (provider == "openai" && !openai_available) {
    stop("OpenAI API key not found. Set OPENAI_API_KEY environment variable.")
  }
  if (provider == "gemini" && !gemini_available) {
    stop("Gemini API key not found. Set GoogleGemini_API_KEY environment variable.")
  }
  
  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    assertthat::is.string(provider),
    provider %in% c("openai", "gemini")
  )

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

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute text generation based on provider
  if (provider == "openai") {
    res <- as.character(chat4R_history(history = history,
                          Model = Model,
                          temperature = temperature))
  } else if (provider == "gemini") {
    # Convert history to gemini4R format
    gemini_contents <- lapply(history, function(msg) {
      list(role = if(msg$role == "system") "user" else msg$role, 
           text = msg$content)
    })
    
    # Use gemini4R for text generation
    gemini_result <- gemini4R(mode = "chat",
                             contents = gemini_contents, 
                             model = Model,
                             max_tokens = 2048)
    
    # Extract text from Gemini response
    if (!is.null(gemini_result$candidates) && length(gemini_result$candidates) > 0) {
      res <- gemini_result$candidates[[1]]$content$parts[[1]]$text
    } else {
      stop("Unexpected Gemini API response format")
    }
  }

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(res))
  }
}
