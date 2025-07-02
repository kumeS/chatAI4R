# =============================================================================
# Combined Examples from chatAI4R Package
# Generated on: 2025-07-01 20:49:23.741767
# =============================================================================

# Load the chatAI4R package
library(chatAI4R)

# Note: Some examples may require API keys to be set:
# Sys.setenv(OPENAI_API_KEY = 'your_openai_key')
# Sys.setenv(GoogleGemini_API_KEY = 'your_gemini_key')
# Sys.setenv(Replicate_API_KEY = 'your_replicate_key')
# Sys.setenv(IONET_API_KEY = 'your_ionet_key')

# =============================================================================

# -----------------------------------------------------------------------------
# addCommentCode examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
addCommentCode(Model = "gpt-4o-mini", language = "English", SelectedCode = TRUE)

# -----------------------------------------------------------------------------
# addRoxygenDescription examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
addRoxygenDescription(Model = "gpt-4o-mini", SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# autocreateFunction4R examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
autocreateFunction4R(Func_description = "2*n+3 sequence")

# -----------------------------------------------------------------------------
# chat4R_history examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "Your API key")
history <- list(list('role' = 'system', 'content' = 'You are a helpful assistant.'),
list('role' = 'user', 'content' = 'Who won the world series in 2020?'))
chat4R_history(history)

# -----------------------------------------------------------------------------
# chat4R_streaming examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "Your API key")
# Without system_set
chat4R_streaming(content = "What is the capital of France?")
# With system_set provided
chat4R_streaming(
content = "What is the capital of France?",
system_set = "You are a helpful assistant."
)

# -----------------------------------------------------------------------------
# chat4R examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "Your API key")
chat4R(content = "What is the capital of France?", check = TRUE)
chat4R(content = "What is the capital of France?", check = FALSE)

# -----------------------------------------------------------------------------
# chat4Rv2 examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "Your API key")
# Using chat4Rv2 without system_prompt (default behavior)
response <- chat4Rv2(content = "What is the capital of France?")
response
# Using chat4Rv2 with a system_prompt provided
response <- chat4Rv2(content = "What is the capital of France?",
                     system_prompt = "You are a helpful assistant.")
response

# -----------------------------------------------------------------------------
# chatAI4pdf examples
# -----------------------------------------------------------------------------

#Baktash et al: GPT-4: A REVIEW ON ADVANCEMENTS AND OPPORTUNITIES IN NATURAL LANGUAGE PROCESSING
pdf_file_path <- "https://arxiv.org/pdf/2305.03195.pdf"

#Execute
summary_text <- chatAI4pdf(pdf_file_path)

# -----------------------------------------------------------------------------
# checkErrorDet_JP examples
# -----------------------------------------------------------------------------

# Analyzing error message from the clipboard
checkErrorDet_JP(Summary_nch = 100, Model = "gpt-4o-mini", verbose = TRUE, SlowTone = FALSE)

# -----------------------------------------------------------------------------
# checkErrorDet examples
# -----------------------------------------------------------------------------

# Copy the error message that you want to fix.
checkErrorDet()
checkErrorDet(language = "Japanese")

# -----------------------------------------------------------------------------
# completions4R examples
# -----------------------------------------------------------------------------

# DEPRECATED: Use chat4R() instead for new code
#Sys.setenv(OPENAI_API_KEY = "Your API key")
prompt <- "Translate the following English text to French: 'Hello, world!'"
completions4R(prompt)

# -----------------------------------------------------------------------------
# conversation4R examples
# -----------------------------------------------------------------------------

conversation4R(message = "Hello, OpenAI! How are you?",
               language = "English",
               ConversationBufferWindowMemory_k = 10)

# -----------------------------------------------------------------------------
# convertBullet2Sentence examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
convertBullet2Sentence(Model = "gpt-4o-mini", SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# convertRscript2Function examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
convertRscript2Function(Model = "gpt-4o-mini", SelectedCode = F)

# -----------------------------------------------------------------------------
# convertScientificLiterature examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
convertScientificLiterature(SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# create_eBay_Description examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
createEBAYdes(Model = "gpt-4o-mini", SelectedCode = FALSE, verbose = TRUE)

# -----------------------------------------------------------------------------
# createImagePrompt_v1 examples
# -----------------------------------------------------------------------------

createImagePrompt_v1(content = "A Japanese girl animation with blonde hair.")

# -----------------------------------------------------------------------------
# createImagePrompt_v2 examples
# -----------------------------------------------------------------------------

# Define the base prompt and image attributes
base_prompt = "A sunset over a serene lake"
removed_from_image = "The sun"
stable_diffusion = "Moderate"

# Generate image prompts
res <- createImagePrompt_v2(Base_prompt = base_prompt,
                            removed_from_image = removed_from_image,
                            style_guidance = stable_diffusion, len = 100)
# Print the generated prompts
print(res)

# -----------------------------------------------------------------------------
# createRcode examples
# -----------------------------------------------------------------------------

# Copy the origin of R code to your clipboard then execute from RStudio's Addins.

# -----------------------------------------------------------------------------
# createRfunction examples
# -----------------------------------------------------------------------------

#Copy the idea text of the R function to your clipboard and run this function.
createRfunction(SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# createSpecifications4R examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
createSpecifications4R(SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# designPackage examples
# -----------------------------------------------------------------------------
??chatAI4R

# Copy the text into your clipboard then execute
designPackage(Model = "gpt-4o-mini", verbose = TRUE, SlowTone = FALSE)

# -----------------------------------------------------------------------------
# DifyChat4R examples
# -----------------------------------------------------------------------------

# Set your Dify API key in the environment or pass it directly
#Sys.setenv(DIFY_API_KEY = "YOUR-DIFY-SECRET-KEY")
# Use the chat-messages endpoint
response_chat <- DifyChat4R(
query = "Hello world via chat!")

print(response_chat)

# -----------------------------------------------------------------------------
# discussion_flow_v1 examples
# -----------------------------------------------------------------------------

issue <-  "I want to solve linear programming and create a timetable."
#Run Discussion with the domain of bioinformatics
discussion_flow_v1(issue, sayENorJA = T)
discussion_flow_v1(issue, sayENorJA = F)

# -----------------------------------------------------------------------------
# discussion_flow_v2 examples
# -----------------------------------------------------------------------------

issue <-  "I want to solve linear programming and create a timetable."
#Run Discussion with the domain of bioinformatics
discussion_flow_v2(issue, sayENorJA = TRUE)
discussion_flow_v2(issue, sayENorJA = F)

# -----------------------------------------------------------------------------
# enrichTextContent examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
enrichTextContent(Model = "gpt-4o-mini", SelectedCode = TRUE)

# -----------------------------------------------------------------------------
# extractKeywords examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
extractKeywords(Model = "gpt-4o-mini", verbose = TRUE, SlowTone = FALSE)

# -----------------------------------------------------------------------------
# gemini4R examples
# -----------------------------------------------------------------------------

gemini4R("text",
contents = "Explain how AI works.",
max_tokens = 256)

# -----------------------------------------------------------------------------
# geminiGrounding4R examples
# -----------------------------------------------------------------------------

# Synchronous text generation with grounding:
result <- geminiGrounding4R(
mode = "text",
contents = "What is the current Google stock price?",
store_history = FALSE,
dynamic_threshold = 1,
api_key = Sys.getenv("GoogleGemini_API_KEY")
)
print(result)

# Chat mode with history storage:
chat_history <- list(
list(role = "user", text = "Hello"),
list(role = "model", text = "Hi there! How can I help you?")
)
chat_result <- geminiGrounding4R(
mode = "chat",
contents = chat_history,
store_history = TRUE,
dynamic_threshold = 1,
api_key = Sys.getenv("GoogleGemini_API_KEY")
)
print(chat_result)
# Streaming text generation:
stream_result <- geminiGrounding4R(
mode = "stream_text",
contents = "Tell me a story about a magic backpack.",
store_history = FALSE,
dynamic_threshold = 1,
api_key = Sys.getenv("GoogleGemini_API_KEY")
)
print(stream_result$full_text)

# -----------------------------------------------------------------------------
# interpretResult examples
# -----------------------------------------------------------------------------

# Example using summary() output of a data frame:
df <- data.frame(x = rnorm(100), y = rnorm(100))
interpretation <- interpretResult("summary", summary(df))
cat(interpretation$content)

# -----------------------------------------------------------------------------
# multiLLMviaionet examples
# -----------------------------------------------------------------------------

# multiLLMviaionet - Example 1
# Set your io.net API key
#Sys.setenv(IONET_API_KEY = "your_ionet_api_key_here")
# Basic usage with default models
result <- multiLLMviaionet(
prompt = "Explain quantum computing in simple terms",
models = c("meta-llama/Llama-3.3-70B-Instruct"),
streaming = F
)



# Advanced usage with random selection (10 models)
result <- multiLLMviaionet(
prompt = "Write a Python function to calculate fibonacci numbers",
max_models = 10,
random_selection = TRUE,
temperature = 0.3,
streaming = FALSE
)
# Quick random 10 model comparison
result <- multiLLM_random10(
prompt = "Explain machine learning in simple terms"
)
# Access results
print(result$summary)
lapply(result$results, function(x) cat(x$model, ":\n", x$response, "\n\n"))

# multiLLMviaionet - Example 2
# List all available models
all_models <- list_ionet_models()
# List only Llama models
llama_models <- list_ionet_models("llama")
# Show detailed information
model_info <- list_ionet_models(detailed = TRUE)

# multiLLMviaionet - Example 3
# Quick 10-model comparison with balanced selection
result <- multiLLM_random10(
prompt = "Explain the benefits of renewable energy"
)
# Pure random selection
result <- multiLLM_random10(
prompt = "Write a haiku about technology",
balanced = FALSE,
temperature = 1.0
)
# Exclude specific models
result <- multiLLM_random10(
prompt = "Solve this math problem: 2x + 5 = 15",
exclude_models = c("microsoft/Phi-3.5-mini-instruct"),
temperature = 0.1
)

# multiLLMviaionet - Example 4
result <- multiLLM_random5("What is artificial intelligence?")

# -----------------------------------------------------------------------------
# ngsub examples
# -----------------------------------------------------------------------------

ngsub("This is  a text \n with  extra   spaces.")

# -----------------------------------------------------------------------------
# OptimizeRcode examples
# -----------------------------------------------------------------------------

#Copy your R code then run the following function.
OptimizeRcode(SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# proofreadEnglishText examples
# -----------------------------------------------------------------------------

# Proofreading selected text in RStudio
proofreadEnglishText(Model = "gpt-4o-mini", SelectedCode = TRUE)
# Proofreading text from the clipboard
proofreadEnglishText(Model = "gpt-4o-mini", SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# proofreadText examples
# -----------------------------------------------------------------------------

# Proofread text from clipboard
proofreadText(SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# RcodeImprovements examples
# -----------------------------------------------------------------------------

#Copy your function to your clipboard
RcodeImprovements(Summary_nch = 100, Model = "gpt-4o-mini")

# -----------------------------------------------------------------------------
# removeQuotations examples
# -----------------------------------------------------------------------------

removeQuotations("\"XXX'`\"YYY'`") # Returns "XXXYYY"

# -----------------------------------------------------------------------------
# replicateAPI4R examples
# -----------------------------------------------------------------------------

#Sys.setenv(Replicate_API_KEY = "Your API key")
input <- list(
input = list(
prompt = "What is the capital of France?",
max_tokens = 1024,
top_k = 50,
top_p = 0.9,
min_tokens = 0,
temperature = 0.6,
system_prompt = "You are a helpful assistant.",
presence_penalty = 0,
frequency_penalty = 0
)
)
model_url <- "/models/meta/meta-llama-3.1-405b-instruct/predictions"
response <- replicatellmAPI4R(input, model_url)
print(response)

# -----------------------------------------------------------------------------
# RevisedText examples
# -----------------------------------------------------------------------------

revisedText()

# -----------------------------------------------------------------------------
# searchFunction examples
# -----------------------------------------------------------------------------

# To search for an R function related to "linear regression"
searchFunction(Summary_nch = 50, SelectedCode = FALSE)

# -----------------------------------------------------------------------------
# slow_print_v2 examples
# -----------------------------------------------------------------------------

slow_print_v2("Hello, World!")
slow_print_v2("Hello, World!", random = TRUE)
slow_print_v2("Hello, World!", delay = 0.1)

# -----------------------------------------------------------------------------
# speakInEN examples
# -----------------------------------------------------------------------------

# Select some text in RStudio and then run the rstudio addin

# -----------------------------------------------------------------------------
# speakInJA_v2 examples
# -----------------------------------------------------------------------------

# Copy some text into your clipboard in RStudio and then run the function
speakInJA_v2()

# -----------------------------------------------------------------------------
# speakInJA examples
# -----------------------------------------------------------------------------

# Select some text in RStudio and then run the rstudio addins

# -----------------------------------------------------------------------------
# summaryWebScraping examples
# -----------------------------------------------------------------------------

summaryWebScrapingText(query = "LLM", t = "w", gl = "us", hl = "en", URL_num = 5)

# -----------------------------------------------------------------------------
# supportIdeaGeneration examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
supportIdeaGeneration()

# -----------------------------------------------------------------------------
# textEmbedding examples
# -----------------------------------------------------------------------------

#Sys.setenv(OPENAI_API_KEY = "Your API key")
textEmbedding("Hello, world!")
textEmbedding("Hello, world!", model = "text-embedding-3-large")

# -----------------------------------------------------------------------------
# textFileInput4ai examples
# -----------------------------------------------------------------------------

# Example usage of the function
api_key <- "YOUR_OPENAI_API_KEY"
file_path <- "path/to/your/text_file.txt"
response <- textFileInput4ai(file_path, api_key = api_key, max_tokens = 50)

# -----------------------------------------------------------------------------
# TextSummary examples
# -----------------------------------------------------------------------------

TextSummary(text = c("This is a long text to be summarized.",
"It spans multiple sentences and goes into much detail."),
nch = 10)

# -----------------------------------------------------------------------------
# TextSummaryAsBullet examples
# -----------------------------------------------------------------------------

# Option 1
# Select some text in RStudio and then run the rstudio addins
# Option 2
# Copy the text into your clipboard then execute
TextSummaryAsBullet()

# -----------------------------------------------------------------------------
# vision4R examples
# -----------------------------------------------------------------------------

# Example usage of the function
api_key <- "YOUR_OPENAI_API_KEY"
file_path <- "path/to/your/text_file.txt"
vision4R(image_path = file_path, api_key = api_key)

# =============================================================================
# End of Combined Examples
# Total functions with examples: 51
# Total example sections: 54
# =============================================================================
