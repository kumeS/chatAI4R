#' Generate and Improve R Functions
#'
#' @title createFunction4R
#' @description This function generates an R function based on a given description, proposes improvements, and then generates an improved version of the function. It is expected to use an AI model (possibly GPT-3 or similar) to perform these tasks.
#' @param Func_description A character string that describes the function to be generated.
#' @param api_key A character string that represents the API key for the AI model being used. Default is the "OPENAI_API_KEY" environment variable.
#' @param packages A character string that specifies the packages to be used in the function. Default is "base".
#' @param max_tokens An integer that specifies the maximum number of tokens to be returned by the AI model. Default is 250.
#' @param roxygen A logical that indicates whether to include roxygen comments in the generated function. Default is TRUE.
#' @importFrom magrittr %>%
#' @importFrom crayon red
#' @return The function returns a character string that represents the generated and improved R function.
#' @export createFunction4R
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
#'   createFunction4R(Func_description = "2*n+3 sequence")
#' }

#library(magrittr)

createFunction4R <- function(Func_description,
                             api_key = Sys.getenv("OPENAI_API_KEY"),
                             packages = "base",
                             max_tokens = 250,
                             View = TRUE,
                             roxygen = TRUE){

# Create a template
template1 = "
You are a great assistant.
I will give you the function overview to create in this project.
Please complete the following required fields
Function description: a R function to perform %s
Language used in the script: R
Packages used for the function: %s
Deliverables you will output: R Script text only
Please write the R code for this function without any example usage and note.
"

# Substitute arguments into the prompt
template1s <- sprintf(template1, Func_description, packages)

# 01 Run function creation
cat(crayon::red("01 Run function creation \n"))
f <- completions4R(prompt = template1s,
       api_key = api_key,
       max_tokens =  max_tokens,
       simple = TRUE)

#View
if(View){
cat(f %>%
  gsub("   ", "\n", .) %>%
  gsub("  ", "\n", .))}

# Create a template
template2 = paste0("
Deliverables: Suggested text only
You are a great assistant.
I will give you an overview of the R function to be created in this project.
Please itemize and suggest improvements to this function.
", f)

# 02 Propose improvements to the function
cat(crayon::red("02 Propose improvements to the function \n"))
f1 <- completions4R(prompt = template2,
       api_key = api_key,
       max_tokens =  max_tokens,
       simple = TRUE)

#View
if(View){
  cat(f1)
}

# Create a template
template3 = paste0("
Please write and complete the following R function according to the required fields and suggestions.
Function description: a R function to perform %s
Language used in the script: R
Packages used for the function: %s
Deliverables you will output: R Script text only without comments
Suggestions: ", f1, "
R script: ", f)

# Substitute arguments into the prompt
template3s <- sprintf(template3, Func_description, packages)

# 03 Improve the function
cat(crayon::red("03 Improve the function \n"))
f2 <- completions4R(prompt = template3s,
       api_key = api_key,
       max_tokens =  max_tokens,
       simple = TRUE)

#View
if(View){
  cat(f2 %>%
  gsub("   ", "\n", .) %>%
  gsub("  ", "\n", .) %>%
  gsub("#' ", "\n#' ", .))
}

if(roxygen){

# Create a template
template4 = paste0("
Computer language: R
Deliverables: roxygen comments only

You are a great assistant.
Please write roxygen comments only for the following R code.
Function: ", f2)

# 04 Include roxygen comments
cat(crayon::red("04 Include roxygen comments \n"))
f3 <- completions4R(prompt = template4,
       api_key = api_key,
       max_tokens =  max_tokens,
       temperature = 1,
       simple = TRUE)

f4 <- paste0(f3, "\n", f2)

f4g <- f4 %>%
  gsub("   ", "\n", .) %>%
  gsub("  ", "\n", .) %>%
  gsub("#' ", "\n#' ", .) %>%
  gsub("#' @export", "#' @export\n", .)

#View
if(View){
  cat(f4g)
}

# View results
cat(crayon::red("Finished!!"))

return(f4)

}else{

# View results
cat(crayon::red("Finished!!"))

return(f2)
}
}
