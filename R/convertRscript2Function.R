#' Convert Selected R Script to R Function
#'
#' This function takes a selected portion of an R script and converts it into an R function.
#' The function uses the OpenAI GPT model for text generation to assist in the conversion.
#' The function can either take the selected code from the RStudio environment or from the clipboard.
#'
#' @title convertRscript2Function
#' @description Convert selected R script to an R function using LLM.
#' @param Model The OpenAI GPT model to use for text generation. Default is "gpt-4o-mini".
#' @param SelectedCode Logical flag to indicate whether to use selected code in RStudio. Default is TRUE.
#' @param verbose A logical value indicating whether to print the result to the console, default is TRUE.
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @importFrom assertthat assert_that is.string noNA is.flag
#' @return Inserts the converted function into the RStudio editor if `SelectedCode` is TRUE, otherwise writes to clipboard.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' convertRscript2Function(Model = "gpt-4o-mini", SelectedCode = F)
#' }

convertRscript2Function <- function(Model = "gpt-4o-mini",
                                    SelectedCode = TRUE,
                                    verbose = TRUE) {

  # Validate that RStudio API is available if SelectedCode is TRUE
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "convertRscript2Function: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Validate input parameters
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    assertthat::is.flag(SelectedCode),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature <- 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled genius copilot of the R language.
  You always have great answers about the R language.
  You should understand the input R code carefully, line by line.
  You need to convert R script input into One R function format.
  You should pay maximum attention to input and output (identifying arguments, setting defaults, setting return values),
  Scope and variables (using local variables, avoiding global variables), code organization (splitting code appropriately, adding comments)
  error handling (implementing input validation, providing error messages), performance (reevaluating efficiency, considering vectorization).
  You need to provide only the core R code as a deliverable in the language that is always used as the input text, without code blocks.
  "

  # Create the prompt
  template1 = "
  Please convert the following R script input to an R function type without code blocks and additional explanations.:
  "

  template1s <- paste0(template1, input, sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute text generation
  res_df <- chat4R_history(history = history,
                          Model = Model,
                          temperature = temperature)

  # Extract content from data.frame
  if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) || 
      is.null(res_df$content) || length(res_df$content) == 0 || nchar(trimws(res_df$content)) == 0) {
    stop("Invalid or empty response from chat4R_history", call. = FALSE)
  }
  
  res <- as.character(res_df$content)

  if(verbose){
    utils::setTxtProgressBar(pb, 3)
    cat("\n")}

  # Output the optimized code
  if(SelectedCode){
    rstudioapi::insertText(text = res)
  } else {
    return(clipr::write_clip(res))
  }
}
