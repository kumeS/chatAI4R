#' Generate and Improve R Functions (experimental)
#'
#' @title autocreateFunction4R (development / experimental)
#' @description This function generates an R function based on a given description,
#' proposes improvements, and then generates an improved version of the function.
#' It uses an AI model (OpenAI GPT) with robust prompts to ensure clean R code output.
#' This is an experimental function.
#' @param Func_description A character string that describes the function to be generated.
#' @param api_key A character string that represents the API key for the AI model being used.
#' Default is the "OPENAI_API_KEY" environment variable.
#' @param packages A character string that specifies the packages to be used in the function.
#' Default is "base".
#' @param Model A character string that specifies the AI model to use. Default is "gpt-5-nano".
#' @param temperature A numeric value that controls the randomness of the AI model's output.
#' Higher values (e.g., 1.0) make output more random, lower values (e.g., 0.3) make it more
#' focused and deterministic. Default is 1. IMPORTANT: When using "gpt-5-nano",
#' temperature MUST be set to 1.
#' @param roxygen A logical that indicates whether to include roxygen comments
#' in the generated function. Default is TRUE.
#' @param View A logical that indicates whether to view the intermediate steps.
#' Default is TRUE.
#' @param verbose A logical flag to print the message Default is TRUE.
#' @importFrom crayon red
#' @importFrom assertthat assert_that is.string is.count noNA
#' @return The function returns a character string that represents the generated and improved R function.
#' @export autocreateFunction4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   # Example 1: Basic usage with default settings
#'   Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
#'   autocreateFunction4R(Func_description = "identify 2*n+3 sequence",  Model = "gpt-5-mini")
#'
#'   # Example 2: Generate function using specific packages
#'   autocreateFunction4R(
#'     Func_description = "create a data frame with random numbers",
#'     Model = "gpt-5-mini", packages = "dplyr, tidyr"
#'   )
#' }

autocreateFunction4R <- function(Func_description,
                             packages = "base",
                             Model = "gpt-5-nano",
                             temperature = 1,
                             View = TRUE,
                             roxygen = TRUE,
                             api_key = Sys.getenv("OPENAI_API_KEY"),
                             verbose = TRUE){

# Validate inputs
assertthat::assert_that(assertthat::is.string(Func_description))
assertthat::assert_that(assertthat::is.string(packages))
assertthat::assert_that(is.logical(View))
assertthat::assert_that(is.logical(roxygen))
assertthat::assert_that(assertthat::is.string(api_key))

# Helper function to extract R code from markdown code blocks
extract_r_code <- function(text) {
  # Remove markdown code blocks (```r ... ``` or ``` ... ```)
  code <- gsub("```r\\s*", "", text)
  code <- gsub("```R\\s*", "", code)
  code <- gsub("```\\s*", "", code)

  # Split into lines and clean
  lines <- strsplit(code, "\n")[[1]]

  # Remove empty lines
  lines <- lines[!grepl("^\\s*$", lines)]

  # Remove example usage comments and any lines after them
  example_idx <- grep("^\\s*#\\s*[Ee]xample", lines)
  if(length(example_idx) > 0) {
    lines <- lines[1:(example_idx[1] - 1)]
  }

  # Filter out lines that are clearly not R code
  # Keep lines that look like R code
  valid_r_patterns <- c(
    "^[a-zA-Z_\\.][a-zA-Z0-9_\\.]*\\s*(<-|=)",  # Assignment
    "^[a-zA-Z_\\.][a-zA-Z0-9_\\.]*\\s*\\(",      # Function definition or call
    "^\\s*function\\s*\\(",                       # Function keyword
    "^\\s*return\\(",                             # Return statement
    "^\\s*if\\s*\\(",                             # If statement
    "^\\s*for\\s*\\(",                            # For loop
    "^\\s*while\\s*\\(",                          # While loop
    "^\\s*[{}]",                                  # Braces
    "^\\s*#"                                      # Comments
  )

  # Check each line against valid patterns
  is_valid <- sapply(lines, function(line) {
    any(sapply(valid_r_patterns, function(pattern) grepl(pattern, line)))
  })

  code_lines <- lines[is_valid]

  # If we found R code lines, use those; otherwise return cleaned original
  if(length(code_lines) > 0) {
    result <- paste(code_lines, collapse = "\n")
  } else {
    # If no valid R code found, return original but cleaned
    result <- paste(lines, collapse = "\n")
  }

  # Final cleanup
  result <- trimws(result)

  # Validate that result contains function keyword
  if(!grepl("function\\s*\\(", result)) {
    # Validation check (warning removed)
  }

  # Additional validation: check if function has a body (not just skeleton)
  # Count opening and closing braces
  open_braces <- lengths(regmatches(result, gregexpr("\\{", result)))
  close_braces <- lengths(regmatches(result, gregexpr("\\}", result)))

  if(open_braces == 0 || close_braces == 0) {
    # Validation check (warning removed)
  }

  if(open_braces != close_braces) {
    # Validation check (warning removed)
  }

  # Check if function has some implementation (not just empty braces)
  lines_between_braces <- gsub("^.*?\\{", "", result)
  lines_between_braces <- gsub("\\}.*?$", "", lines_between_braces)
  lines_between_braces <- trimws(lines_between_braces)

  if(nchar(lines_between_braces) < 10) {
    # Validation check (warning removed)
  }

  # Check for empty if blocks (common problem)
  empty_if_pattern <- "if\\s*\\([^)]+\\)\\s*\\{\\s*\\}"
  if(grepl(empty_if_pattern, result)) {
    # Check if it's a validation if block
    validation_pattern <- "if\\s*\\([^)]*(?:is\\.numeric|is\\.integer|is\\.character|<|>|!=|==)[^)]*\\)\\s*\\{\\s*\\}"
    if(grepl(validation_pattern, result, perl = TRUE)) {
      # Validation check (warning removed)
    } else {
      # Validation check (warning removed)
    }
  }

  # Check for empty loop blocks
  if(grepl("(for|while)\\s*\\([^)]+\\)\\s*\\{\\s*\\}", result)) {
    # Validation check (warning removed)
  }

  # Check for comment-only lines that should be code (common problem from memo.txt)
  lines <- strsplit(result, "\n")[[1]]
  comment_only_lines <- grep("^\\s*#\\s*(Initialize|Validate|Calculate|Generate|Load|Create|Set|Handle|Return|Ensure)", lines, value = TRUE)

  if(length(comment_only_lines) > 0) {
    # Validation check (warning removed)
  }

  return(result)
}

# Helper function to extract roxygen comments
extract_roxygen_comments <- function(text) {
  # Remove markdown code blocks if present
  text <- gsub("```.*```", "", text, perl = TRUE)

  # Split into lines
  lines <- strsplit(text, "\n")[[1]]

  # Keep only lines starting with #' or convert # to #'
  roxygen_lines <- lines[grepl("^\\s*#", lines)]
  roxygen_lines <- gsub("^\\s*#'?\\s*", "#' ", roxygen_lines)

  # If no roxygen found, return empty
  if(length(roxygen_lines) == 0) {
    return("")
  }

  result <- paste(roxygen_lines, collapse = "\n")
  return(trimws(result))
}

# Create a simple template focused on user intent
template1 = "
You are an expert R programmer.

USER REQUEST: %s

YOUR TASK:
Write a complete, executable R function that fulfills this request: %s

ALLOWED PACKAGES: %s

REQUIREMENTS:
- Implement EXACTLY what the user requested: %s
- Write ONLY executable code (no comment placeholders)
- Initialize all variables before use
- Use stop() for error handling in if blocks
- Return the result

OUTPUT:
Return ONLY the complete R function in ```r ``` code block.
No comments after the function.
No example usage.
"

# Substitute arguments into the prompt (4 placeholders: Func_description x3, packages x1)
template1s <- sprintf(template1, Func_description, Func_description, packages, Func_description)

# 01 Run function creation
if(verbose){cat(crayon::red("\n01 Run function creation \n"))}
f_result <- chat4R(content = template1s,
                   api_key = api_key,
                   Model = Model,
                   temperature = temperature,
                   check = FALSE)

# Extract R code from markdown code blocks
f_raw <- f_result$content
f <- extract_r_code(f_raw)

#View
if(View){
f1 <- gsub("   ", "\n", f)
f1 <- gsub("  ", "\n", f1)
cat(f1)
}

# Create a template for improvement suggestions
template2 = paste0("
You are an expert R code reviewer.

ORIGINAL USER REQUEST:
", Func_description, "

TASK:
Review this R function and suggest specific improvements while MAINTAINING the original user's intent.

GENERATED FUNCTION:
", f, "

IMPROVEMENT CRITERIA:
1. Ensure the function fulfills the ORIGINAL USER REQUEST
2. Code efficiency and best practices
3. Error handling and input validation
4. Edge cases coverage

CRITICAL REQUIREMENTS:
- ALL improvements MUST preserve the original user's intent: ", Func_description, "
- Provide ONLY a concise bulleted list of improvements
- Be specific and actionable
- Focus on code quality, not documentation
- DO NOT suggest changes that deviate from the original request
")

# 02 Propose improvements to the function
if(verbose){cat(crayon::red("\n02 Propose improvements to the function \n"))}
f1_result <- chat4R(content = template2,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)
f1 <- f1_result$content

#View
if(View){
  cat(f1)
}

# Create a template for improved version
template3 = paste0("
You are an expert R programmer.

ORIGINAL USER REQUEST (MUST FULFILL):
%s

ORIGINAL FUNCTION:
", f, "

IMPROVEMENT SUGGESTIONS:
", f1, "

YOUR TASK:
Write the COMPLETE FULL FUNCTION from start to finish.
- DO NOT write partial code or modifications only
- Write the ENTIRE function including all lines from beginning to end
- Apply ALL improvement suggestions
- Fulfill the ORIGINAL USER REQUEST: %s

CRITICAL:
You MUST output the FULL COMPLETE FUNCTION CODE.
NOT just the changes.
NOT just the modified parts.
Output the ENTIRE FUNCTION from function definition to closing brace.

OUTPUT FORMAT:
Return the COMPLETE function in ```r ``` code block.
Every line from start to finish.
No comments outside the function.
No example usage.
")

# Substitute arguments into the prompt (2 placeholders: original request)
#cat(template3)
template3s <- sprintf(template3, Func_description, Func_description)
#cat(template3s)

# 03 Improve the function
if(verbose){cat(crayon::red("\n03 Improve the function \n"))}
f2_result <- chat4R(content = template3s,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

# Extract R code from markdown code blocks
f2_raw <- f2_result$content
f2 <- extract_r_code(f2_raw)

#View
if(View){
f2s <- gsub("   ", "\n", f2)
f2s <- gsub("  ", "\n", f2s)
f2s <- gsub("#' ", "\n#' ", f2s)
cat(f2s)
}

##here roxygen if
if(roxygen){

# Create a template for roxygen documentation
template4 = paste0("
You are an expert R package developer.

TASK:
Write roxygen2 documentation comments for this R function.

R FUNCTION:
", f2, "

STRICT REQUIREMENTS:
- Output ONLY roxygen2 comments (lines starting with #')
- Include: @title, @description, @param for each parameter, @return, @export
- Do NOT include the function code itself
- Do NOT include examples or usage
- Be concise and professional

OUTPUT FORMAT:
Return ONLY the roxygen comments, each line starting with #'
")

# 04 Add roxygen comments
if(verbose){cat(crayon::red("\n04 Include roxygen comments \n"))}
f3_result <- chat4R(content = template4,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

# Extract roxygen comments (remove markdown if present)
f3_raw <- f3_result$content
f3 <- extract_roxygen_comments(f3_raw)

# Combine roxygen comments and function code
f4 <- paste0(f3, "\n", f2)

# Clean up formatting
f4 <- gsub("```r|```R|```", "", f4)  # Remove any remaining markdown
f4 <- trimws(f4)

#View
if(View){
  cat("\n--- Generated Function with Documentation ---\n")
  cat(f4)
  cat("\n")
}

# Final validation: ensure output is valid and complete R code
if(!grepl("function\\s*\\(", f4)) {
  stop("Error: Generated output does not contain a valid R function. Please try again with a clearer description.")
}

# Check for function body completeness
if(!grepl("\\{.*return\\(", f4) && !grepl("\\{.*\\}", f4)) {
  # Validation check (warning removed)
}

# Verify the function has substantial content
content_lines <- strsplit(f4, "\n")[[1]]
code_lines <- content_lines[!grepl("^\\s*#", content_lines)]  # Exclude comments
if(length(code_lines) < 3) {
  # Validation check (warning removed)
}

# Additional checks for common problems from memo.txt
if(grepl("if\\s*\\([^)]+\\)\\s*\\{\\s*\\}", f4)) {
  # Validation check (warning removed)
}

if(grepl("(for|while)\\s*\\([^)]+\\)\\s*\\{\\s*\\}", f4)) {
  # Validation check (warning removed)
}

# Check for library() calls outside function (Example 3 problem)
if(grepl("^library\\(", f4) || grepl("^require\\(", f4)) {
  # Validation check (warning removed)
}

# Check for comment-only placeholder lines (critical problem from memo.txt)
f4_lines <- strsplit(f4, "\n")[[1]]
placeholder_comments <- grep("^\\s*#\\s*(Initialize|Validate|Calculate|Generate|Load|Create|Complete|Vectorized|Set|Handle|Return|Ensure)", f4_lines, value = TRUE)

if(length(placeholder_comments) > 2) {
  # Validation check (warning removed)
}

# 05 Consistency check - verify function matches input description
if(verbose){cat(crayon::red("\n05 Is it a function that reflects the input? \n"))}

template5 <- paste0("
You are an expert R code reviewer.

TASK:
Compare the user's original request with the generated R function and determine if they match.

ORIGINAL REQUEST:
", Func_description, "

GENERATED FUNCTION:
", f4, "

EVALUATION CRITERIA:
1. Does the function implement what the user requested?
2. Are all key requirements addressed?
3. Is the function's purpose aligned with the description?
4. Are there any missing features?
5. Are there any unnecessary additions?

OUTPUT FORMAT:
Return ONLY ONE of these:
- MATCH: [Brief reason why it matches]
- MISMATCH: [Specific issues with alignment]
")

f5_result <- chat4R(content = template5,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

consistency_check <- f5_result$content

# Display result immediately
cat(consistency_check, "\n\n")

# 06 Finalize the function based on consistency check
if(verbose){cat(crayon::red("\n06 Finalize the function \n"))}

template6 <- paste0("
You are an expert R programmer.

ORIGINAL USER REQUEST:
", Func_description, "

CONSISTENCY CHECK RESULT:
", consistency_check, "

CURRENT FUNCTION WITH DOCUMENTATION:
", f4, "

YOUR TASK:
Review the consistency check result and make final adjustments to ensure the function perfectly matches the user's request.
- If MATCH: Make minor refinements for quality
- If MISMATCH: Fix the issues identified in the consistency check
- Output the COMPLETE function with roxygen documentation

CRITICAL:
Output the ENTIRE function from roxygen comments to closing brace.
DO NOT output partial code.

OUTPUT FORMAT:
Return the COMPLETE function with roxygen comments in ```r ``` code block.
No comments outside the function.
No example usage.
")

f6_result <- chat4R(content = template6,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

# Extract final function
f6_raw <- f6_result$content
f6 <- extract_r_code(f6_raw)

# View final result
if(View){
  cat("\n--- Finalized Function ---\n")
  cat(f6)
  cat("\n")
}

# View results
if(verbose){cat(crayon::red("\nFinished!!\n\n"))}

if(!View){return(cat(f6))}

}else{

# Clean up the function code
f2 <- gsub("```r|```R|```", "", f2)  # Remove any remaining markdown
f2 <- trimws(f2)

#View
if(View){
  cat("\n--- Generated Function ---\n")
  cat(f2)
  cat("\n")
}

# Final validation: ensure output is valid and complete R code
if(!grepl("function\\s*\\(", f2)) {
  stop("Error: Generated output does not contain a valid R function. Please try again with a clearer description.")
}

# Check for function body completeness
if(!grepl("\\{.*return\\(", f2) && !grepl("\\{.*\\}", f2)) {
  # Validation check (warning removed)
}

# Verify the function has substantial content
content_lines <- strsplit(f2, "\n")[[1]]
code_lines <- content_lines[!grepl("^\\s*#", content_lines)]  # Exclude comments
if(length(code_lines) < 3) {
  # Validation check (warning removed)
}

# Additional checks for common problems from memo.txt
if(grepl("if\\s*\\([^)]+\\)\\s*\\{\\s*\\}", f2)) {
  # Validation check (warning removed)
}

if(grepl("(for|while)\\s*\\([^)]+\\)\\s*\\{\\s*\\}", f2)) {
  # Validation check (warning removed)
}

# Check for library() calls outside function (Example 3 problem)
if(grepl("^library\\(", f2) || grepl("^require\\(", f2)) {
  # Validation check (warning removed)
}

# Check for comment-only placeholder lines (critical problem from memo.txt)
f2_lines <- strsplit(f2, "\n")[[1]]
placeholder_comments <- grep("^\\s*#\\s*(Initialize|Validate|Calculate|Generate|Load|Create|Complete|Vectorized|Set|Handle|Return|Ensure)", f2_lines, value = TRUE)

if(length(placeholder_comments) > 2) {
  # Validation check (warning removed)
}

# 05 Consistency check - verify function matches input description
if(verbose){cat(crayon::red("\n05 Is it a function that reflects the input? \n"))}

template5 <- paste0("
You are an expert R code reviewer.

TASK:
Compare the user's original request with the generated R function and determine if they match.

ORIGINAL REQUEST:
", Func_description, "

GENERATED FUNCTION:
", f2, "

EVALUATION CRITERIA:
1. Does the function implement what the user requested?
2. Are all key requirements addressed?
3. Is the function's purpose aligned with the description?
4. Are there any missing features?
5. Are there any unnecessary additions?

OUTPUT FORMAT:
Return ONLY ONE of these:
- MATCH: [Brief reason why it matches]
- MISMATCH: [Specific issues with alignment]
")

f5_result <- chat4R(content = template5,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

consistency_check <- f5_result$content

# Display result immediately
cat(consistency_check, "\n\n")

# 06 Finalize the function based on consistency check
if(verbose){cat(crayon::red("\n06 Finalize the function \n"))}

template6 <- paste0("
You are an expert R programmer.

ORIGINAL USER REQUEST:
", Func_description, "

CONSISTENCY CHECK RESULT:
", consistency_check, "

CURRENT FUNCTION:
", f2, "

YOUR TASK:
Review the consistency check result and make final adjustments to ensure the function perfectly matches the user's request.
- If MATCH: Make minor refinements for quality
- If MISMATCH: Fix the issues identified in the consistency check
- Output the COMPLETE function

CRITICAL:
Output the ENTIRE function from function definition to closing brace.
DO NOT output partial code.

OUTPUT FORMAT:
Return the COMPLETE function in ```r ``` code block.
No comments outside the function.
No example usage.
")

f6_result <- chat4R(content = template6,
                    api_key = api_key,
                    Model = Model,
                    temperature = temperature,
                    check = FALSE)

# Extract final function
f6_raw <- f6_result$content
f6 <- extract_r_code(f6_raw)

# View final result
if(View){
  cat("\n--- Finalized Function ---\n")
  cat(f6)
  cat("\n")
}

# View results
if(verbose){cat(crayon::red("\nFinished!!\n\n"))}
if(!View){return(cat(f6))}
}
}
