#' Enrich Text Content
#'
#' @title Enrich Text Content v2
#' @description This function doubles the amount of text without changing its meaning.
#'    The GPT-4 model is currently recommended for text generation. It can either read from the RStudio selection or the clipboard.
#' @param Model A character string specifying the AI model to be used for text enrichment. Default is "gpt-4o-mini".
#' @param SelectedCode A logical flag to indicate whether to read from RStudio's selected text. Default is TRUE.
#' @param verbose Logical flag to indicate whether to display the generated text. Default is TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @return If SelectedCode is TRUE, the enriched text is inserted into the RStudio editor and a message "Finished!!" is returned.
#'         Otherwise, the enriched text is placed into the clipboard.
#' @export enrichTextContent
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' enrichTextContent(Model = "gpt-4o-mini", SelectedCode = TRUE)
#' }

enrichTextContent <- function(Model = "gpt-4o-mini",
                              SelectedCode = TRUE,
                              verbose = TRUE) {

  # Get input either from RStudio or clipboard
  if(SelectedCode){
    assertthat::assert_that(rstudioapi::isAvailable())
    input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  } else {
    input <- paste0(clipr::read_clip(), collapse = " \n")
  }

  if(verbose){
    cat("\n", "enrichTextContent: ", "\n")
    pb <- utils::txtProgressBar(min = 0, max = 3, style = 3)
  }

  # Assertions for input validation
  assertthat::assert_that(
    assertthat::is.string(input),
    assertthat::noNA(input),
    assertthat::is.string(Model),
    Sys.getenv("OPENAI_API_KEY") != ""
  )

  temperature <- 1
  if(verbose){utils::setTxtProgressBar(pb, 1)}

  # Template for text generation
  template <- "
You are an excellent assistant. Your expertise as an assistant is truly unparalleled. Your task involves expanding the text's length twofold without altering its original significance. This expansion necessitates the artful substitution of words with their equivalents, the transformation of simple sentences into more intricate structures, and the embellishment of the narrative with suitably chosen adjectives, adverbs, and the weaving in of metaphors to enrich the prose. Your deliverables will be confined solely to the text, ensuring the language remains consistent with the initial input. Your specialization should extend to the refinement of textual content with an emphasis on generating outputs that resonate with scientific accuracy and logical coherence. By assessing the domain intrinsic to the input text, you ensure that the augmentation is not only relevant but also significantly enhances the material through comprehensive explanations, supplementary information, and the resolution of any ambiguities or complex notions. The ultimate aim is to elevate the informational value of the text, adhering to the rigorous principles of scientific argumentation and rational thought. This endeavor encompasses the necessary adjustments to rectify any omissions or unclear narratives, with all exchanges conducted in English to guarantee both clarity and broad accessibility.
  "

  template1 <- "
  Please double the following input text without changing the meaning or intent:
  "

  # Create the prompt
  template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

  # Initialize history for chat
  history <- list(list('role' = 'system', 'content' = template),
                  list('role' = 'user', 'content' = template1s))

  if(verbose){utils::setTxtProgressBar(pb, 2)}

  # Execute text generation
  retry_count <- 0
  while (retry_count <= 3) {
    res <- chat4R_history(history = history,
                          Model = Model,
                          temperature = temperature)
    if(nchar(res) >= nchar(input) * 2){ break }
    retry_count <- retry_count + 1
  }

  if(verbose){utils::setTxtProgressBar(pb, 3)}

  # Output the enriched text
  if(SelectedCode){
    rstudioapi::insertText(text = as.character(res))
    return(message("Finished!!"))
  } else {
    return(clipr::write_clip(as.character(res)))
  }
}
