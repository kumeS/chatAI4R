#' Create eBay Product Description
#'
#' @title Create eBay Product Description
#' @description This function generates a product description for eBay listings in English.
#' It uses the GPT-4 model for text generation and can take input from either RStudio or the clipboard.
#' @param Model The GPT-4 model to use for text generation. Default is "gpt-4o-mini".
#' @param SelectedCode Whether to get the input from the selected code in RStudio. Default is TRUE.
#' @param verbose Whether to display progress information. Default is TRUE.
#' @param SlowTone Whether to print the output slowly. Default is FALSE.
#' @importFrom assertthat assert_that is.string is.flag noNA
#' @importFrom rstudioapi isAvailable getActiveDocumentContext
#' @importFrom clipr read_clip write_clip
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom stats runif
#' @return The generated eBay product description.
#' @export createEBAYdes
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Option 1
#' # Select some text in RStudio and then run the rstudio addins
#' # Option 2
#' # Copy the text into your clipboard then execute
#' createEBAYdes(Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = TRUE)
#' }

createEBAYdes <- function(Model = "gpt-4o-mini",
                          SelectedCode = TRUE,
                          verbose = TRUE,
                          SlowTone = FALSE){

# Assertions for function input
assertthat::assert_that(
  assertthat::is.string(Model),
  assertthat::is.flag(SelectedCode),
  assertthat::is.flag(verbose),
  assertthat::is.flag(SlowTone),
  rstudioapi::isAvailable() || !SelectedCode,
  Sys.getenv("OPENAI_API_KEY") != ""
)

# Get input either from RStudio or clipboard
if(SelectedCode){
  input <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
} else {
  input <- paste0(clipr::read_clip(), collapse = " \n")
}

# Assertions for input
assertthat::assert_that(
assertthat::is.string(input),
assertthat::noNA(input)
)

if(verbose){
  cat("\n", "createEBAYdes: ", "\n")
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
You are a professional eBay seller and a professional writer.
You want to list your product for sale with free shipping to the United States.
Please list the product description and features in English with EBAY SEO in mind.
Please list any accessories or contents that come with the product in English.
Please list product specifications in English, including year of release, material, size, weight, capacity, and language(s) listed.
Lengths should be listed in both centimeters and inches.
Please also include a nice, witty, encouraging comment in English.
"

template1 = "
As a professional eBay seller and editor, you are seeking to promote your product for sale.
In order to achieve this, please provide a detailed product description and features in English, with the aim of optimizing the listing for eBay SEO.
Additionally, kindly list any accessories or content that are included with the product in English.
To ensure clarity and precision, please include product specifications in English, such as the year of release, material, size, weight, capacity, and language(s) listed.
It is important to provide measurements in both centimeters and inches.
Lastly, please include a friendly and engaging comment in English to encourage potential buyers.
The product description should also include the following details:
"

# Substituting arguments into the prompt
template1s <- paste0(template1, paste0(input, collapse = " "), sep=" ")

# Prompt creation
history <- list(list('role' = 'system', 'content' = template),
                list('role' = 'user', 'content' = template1s))

if(verbose){utils::setTxtProgressBar(pb, 2)}

# Execution
res <- chat4R_history(history=history,
                      Model = Model,
                      temperature = temperature)
if(verbose){
utils::setTxtProgressBar(pb, 3)
cat("\n")}

# Output
if(SelectedCode){
  rstudioapi::insertText(text = as.character(res))
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

return(clipr::write_clip(as.character(res)))

}
}

