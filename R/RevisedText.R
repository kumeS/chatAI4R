#' Revise Scientific Text
#'
#' @title Revised Scientific Text
#' @description This function prompts the user to input text, revision comments, and additional background information.
#'    It then revises the text according to the comments and outputs the revised text.
#' @param verbose Logical, whether to output verbose messages, default is TRUE.
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom clipr read_clip
#' @importFrom utils menu askYesNo
#' @return Revised text or relevant message.
#' @export revisedText
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'  revisedText()
#' }

revisedText <- function(verbose = TRUE){

  # Ask if the user has text ready for input
  Ans1 <- utils::askYesNo("Do you have text ready for input?")
  assertthat::assert_that(assertthat::is.count(Ans1), assertthat::noNA(Ans1))

  # Handle the response for text input
  if(Ans1){
    Ans1A <- utils::askYesNo("Do you want to use your clipboard as input text for this revision?")
    assertthat::assert_that(assertthat::is.count(Ans1A), assertthat::noNA(Ans1A))

    if(Ans1A){
      txt1 <- paste0(clipr::read_clip(), collapse = " \n")
      assertthat::assert_that(assertthat::is.string(txt1))
    } else {
      txt1 <- readline(prompt = paste("Input text please: "))
      assertthat::assert_that(assertthat::is.string(txt1))
    }
  } else {
    return(message("No input!!"))
  }

  # Handle the response for revision comments
  if(verbose){ cat("\n") }
  Ans2 <- utils::askYesNo("Do you have revision comments for the input?")
  assertthat::assert_that(assertthat::is.count(Ans2), assertthat::noNA(Ans2))

  if(Ans2){
    Ans2A <- utils::askYesNo("Do you want to use your clipboard as revision comments?")
    assertthat::assert_that(assertthat::is.count(Ans2A), assertthat::noNA(Ans2A))

    if(Ans2A){
      txt2 <- paste0(clipr::read_clip(), collapse = " \n")
      assertthat::assert_that(assertthat::is.string(txt2))
    } else {
      txt2 <- readline(prompt = paste("Please enter the revision comments: "))
      assertthat::assert_that(assertthat::is.string(txt2))
    }
  } else {
    return(message("No revision comments!!"))
  }

#Q3
if(verbose){ cat("\n") }
Ans3 <- utils::askYesNo("Do you have any additional background information to add to the entry?")

if(Ans3){

  Ans3A <- utils::askYesNo("Do you want to use your clipboard as background information?")

  if(Ans3A){
   txt3 <- paste0(clipr::read_clip(), collapse = " \n")
   assertthat::assert_that(assertthat::is.string(txt3))
  }else{
   txt3 <- readline(prompt = paste("Please enter the information: "))
  }
}else{
  txt3 <- ""
}

#LLMモデルを選択する
choices1 <- c("GPT-3.5", "GPT-4 (0613)", "Another LLM")
selection1 <- utils::menu(choices1, title = "Which language model do you prefer?")

if (selection1 == 1) {
    Model = "gpt-3.5-turbo"
} else if (selection1 == 2) {
    Model = "gpt-4-0613"
} else if (selection1 == 3) {
    return(message("No valid selection made."))
} else {
    return(message("No valid selection made."))
}

# Create template for the prompt
template0 = "
You are an excellent assistant and a highly qualified scientific researcher of professorial level.
You always have to convert the input text into scientific literature.
You output only the text of the deliverable.
The language used is always the same as the input text.
"

if(txt3 != ""){
template0s <- paste(template0,
                    "Background information:",
                    txt3)
}else{
template0s <- template0
}

template1 = "
Please revise the following input text forrevision with a simple explanation based on the revision comments.:
"

# Substitute arguments into the prompt
template1s <- paste0(template1,
                     paste0("Text for revision: ", txt1, collapse = " "),
                     paste0("The revision comments: ", txt2, collapse = " "))

# Create prompt history
history <- list(list('role' = 'system', 'content' = template0s),
                list('role' = 'user', 'content' = template1s))

# Execute the chat model
res <- as.character(chat4R_history(history=history,
                      Model = Model,
                      temperature = 1))

# Output final result or relevant messages
if(verbose) {
  cat("\n"); cat("Results:\n")
  d <- ifelse(5/nchar(res) < 0.3, 5/nchar(res), 0.3) * stats::runif(1, min = 0.95, max = 1.05)
  slow_print_v2(res, delay = d)
} else {
  return(res)
}
}




