#' Optimize and Complete R Code
#'
#' This function takes a snippet of R code and optimizes it for performance and readability.
#' It uses a machine learning model to generate the optimized code.
#'
#' @title Optimize and Complete R Code
#' @description Optimizes and completes the R code from the selected code or clipboard.
#' @param Model A string specifying the machine learning model to use for code optimization. Default is "gpt-4-0613".
#' @param SelectedCode A boolean indicating whether to get the code from RStudio or the clipboard. Default is TRUE.
#' @param verbose_Reasons4change A boolean indicating whether to provide detailed reasons for the changes made. Default is TRUE.
#' @param SlowTone A boolean indicating whether to print the output slowly. Default is FALSE.
#' @importFrom assertthat assert_that is.string noNA is.count is.flag
#' @importFrom rstudioapi isAvailable getActiveDocumentContext insertText
#' @importFrom clipr read_clip write_clip
#' @return A message indicating the completion of the optimization process.
#' @export OptimizeRcode
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' #Copy your R code then run the following function.
#' OptimizeRcode(SelectedCode = FALSE)
#' }

OptimizeRcode <- function(Model = "gpt-4-0613",
                          SelectedCode = TRUE,
                          verbose_Reasons4change = TRUE,
                          SlowTone = FALSE) {

  # Validate that RStudio API is available if SelectedCode is TRUE
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  # Validate input parameters
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    assertthat::is.flag(SelectedCode),
    assertthat::is.flag(verbose_Reasons4change),
    assertthat::is.flag(SlowTone),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  # Initialize temperature for text generation
  temperature <- 1

  # Template for text generation
  template <- "
  You are an excellent assistant and a highly skilled R copilot.
  You should understand the input R code carefully, line by line.
  You should consider the use of vectorization and vector manipulation, selection of appropriate data structures,
  efforts to minimize memory usage, parallel processing, latency evaluation, use of external libraries (such as Rcpp),
  selecting appropriate functions, optimizing loop processing, function reuse, code readability and maintainability
  and package selection to code by considering the following
  You must provide only the core R code as a deliverable in English, without code blocks and any explanations.
  "

  # Create the prompt
  template1 = "
  Without explanations, please optimize the following R code input in English.:
  "

  template1s <- paste0(template1, input, sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  # Execute text generation
  res <- chat4R_history(history = history,
                        Model = Model,
                        temperature = temperature)

  # Output the optimized code
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))

    if(verbose_Reasons4change){
      # Additional code for verbose reasons
      history[[3]] <- list('role' = 'assistant', 'content' = res)
      template2 = "Please describe in detail the changes you previously made to the R code without apology."
      history[[4]] <- list('role' = 'user', 'content' = template2)

      res1 <- chat4R_history(history = history,
                             Model = Model,
                             temperature = temperature)

      if(SlowTone) {
        d <- ifelse(20/nchar(res1) < 0.3, 20/nchar(res1), 0.3) * stats::runif(1, min = 0.95, max = 1.05)
        slow_print(res1, delay = d)
      } else {
        d <- ifelse(10/nchar(res1) < 0.15, 10/nchar(res1), 0.15) * stats::runif(1, min = 0.95, max = 1.05)
        slow_print(res1, delay = d)
      }
    }
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(res))
  }
}
