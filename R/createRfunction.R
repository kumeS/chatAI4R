#' Create R Function from Selected Text or Clipboard Content
#'
#' @title Create R Function from Selected Text or Clipboard Content and Output into the R Console
#' @description This function reads text either from your selected text in RStudio or from the clipboard, interprets it as a prompt, and generates an R function based on the given input. The generated R code is then printed into the source file or the R console with optional slow printing.
#' @param Model A character string representing the model to be used. Default is "gpt-4o-mini".
#' @param SelectedCode A logical value indicating if the selected text should be used as input. Default is TRUE.
#' @param verbose A logical value indicating if progress should be printed. Default is TRUE.
#' @param SlowTone A logical value indicating if slow printing should be used. Default is FALSE.
#' @importFrom assertthat assert_that is.string noNA is.flag
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom stats runif
#' @return This function returns the generated R code as a clipboard content if SelectedCode is FALSE.
#' @export createRfunction
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'
#' #Copy the idea text of the R function to your clipboard and run this function.
#' createRfunction(SelectedCode = FALSE)
#' }

createRfunction <- function(Model = "gpt-4o-mini",
                            SelectedCode = TRUE,
                            verbose = TRUE,
                            SlowTone = FALSE){

  # Get input either from RStudio or clipboard
  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  # Assertions for function input
  assertthat::assert_that(
    assertthat::is.string(Model),
    assertthat::is.flag(SelectedCode),
    assertthat::is.flag(verbose),
    assertthat::is.flag(SlowTone),
    rstudioapi::isAvailable() || !SelectedCode,
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  if(verbose){
    cat("\n", "createRfunction: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input)
  )

  temperature = 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template creation
  template = "
  You are an excellent assistant and a highly skilled genius co-pilot of R programming.
  You always respond to deliverables and related explanations in a very professional and accurate manner.
  According to the input idea for the R function, you only need to provide the R function as a deliverable in a comprehensive and detailed manner.
  For example, descriptions of loading R packages through library functions, test descriptions, and descriptions outside of R functions are not required.
  Be sure to comment out the description of each execution in the R function.
  You should not use code blocks (```r, etc.) and create tests or examples.
  The language used in the output deliverables must be the same as the language of the following input.
  "

  template1 = "
  Without creating any code blocks or tests, create the R program as an R function based on the following input.:
  "

  # Substituting arguments into the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Prompt creation
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execution
  res_df <- chat4R_history(history=history,
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

  # Output
  if(SelectedCode){
    rstudioapi::insertText(text = res)
  } else {
  if(verbose) {
    if(SlowTone) {
      d <- ifelse(20/nchar(res) < 0.3, 20/nchar(res), 0.3)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    } else {
      d <- ifelse(10/nchar(res) < 0.15, 10/nchar(res), 0.15)*stats::runif(1, min = 0.95, max = 1.05)
      slow_print_v2(res, delay = d)
    }
  }

  return(clipr::write_clip(res))

  }
}
