#' Interactions and Flow Control Between LLM-based Bots (LLBs)
#'
#' In the v2 model, we added a regulation of the difficulty of the sentence,
#' the human intervention in their conversation between LLM bots, and number of repetitions of conversation.
#' This function is described to simulate the interactions and flow control between
#' three different roles of LLM-based bots, abbreviated as LLBs, namely A (Beginner), B (Expert), and C (Peer Reviewer).
#' These roles have distinct functions and work together to facilitate more complex and meaningful discussions.
#' Here is a brief description of the roles:
#' A (Beginner): This bot generates questions and summaries based on the content of the discussion provided by the user.
#' B (Expert): This bot provides professional answers to questions posed by LLB A.
#' C (Peer Reviewer):  This bot reviews the dialog between LLB A and LLB B and suggests improvements or refinements.
#' The three parties independently call the OpenAI API according to their roles.
#' In addition, it keeps track of the conversation history between the bots and performs
#' processes such as questioning, answering, and peer review.
#' The function is designed to work in a "domain," which is essentially a specific area
#' or topic around which conversations revolve.
#' It is recommended to use GPT-4 or a model with higher accuracy than GPT-4.
#' English is recommended as the input language, but the review will also be conducted in Japanese, the native language of the author.
#'
#' @title discussion_flow_v2: Interactions and Flow Control Between LLM-based Bots (LLBs)
#' @description Simulates interactions and flow control between three different roles of LLM-based bots (LLBs).
#' @param issue The issue to be discussed. Example: "I want to perform differential gene expression analysis from RNA-seq data and interpret enriched pathways."
#' @param Domain The domain of the discussion, default is "bioinformatics".
#' @param Model The LLM model to be used, default is "gpt-4o-mini".
#' @param api_key The API key for OpenAI, default is retrieved from the system environment variable "OPENAI_API_KEY".
#' @param language The language for the discussion, default is "English".
#' @param Summary_nch The number of characters for the summary, default is 50.
#' @param Sentence_difficulty Numeric, the complexity level for sentence construction, default is 2.
#' @param R_expert_setting Logical, whether R expert settings are enabled, default is TRUE.
#' @param verbose Logical, whether to print verbose output, default is TRUE.
#' @param sayENorJA Logical, whether to speak in English or Japanese, default is TRUE. This feature is available on macOS systems only.
#' @param rep_x Numeric, a number of repeats for the conversations, default is 3.
#' @importFrom future plan future multisession resolved
#' @importFrom igraph graph add_vertices layout_nicely add_edges layout_with_fr
#' @importFrom deepRstudio is_mac deepel
#' @return A summary of the conversation between the bots.
#' @export discussion_flow_v2
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' issue <-  "I want to perform differential gene expression analysis from
#'            RNA-seq data and interpret enriched pathways."
#'
#' #Run Discussion with the domain of bioinformatics
#' discussion_flow_v2(issue)
#' }

#issue = "I want to perform differential gene expression analysis from RNA-seq data
#         and interpret enriched pathways.";Domain = "bioinformatics";Model = "gpt-4o-mini";api_key = Sys.getenv("OPENAI_API_KEY");language = "English";Summary_nch = 50; verbose = TRUE; sayENorJA = FALSE; Sentence_difficulty = 2; R_expert_setting = TRUE; rep_x = 3
#discussion_flow_v2(issue, sayENorJA = FALSE)

discussion_flow_v2 <- function(issue,
                               Domain = "bioinformatics",
                               Model = "gpt-4o-mini",
                               api_key = Sys.getenv("OPENAI_API_KEY"),
                               language = "English",
                               Summary_nch = 50,
                               Sentence_difficulty = 2,
                               R_expert_setting = TRUE,
                               verbose = TRUE,
                               sayENorJA = TRUE,
                               rep_x = 3){

#Create multi-session
future::plan(future::multisession())
DEEPL <- any(names(Sys.getenv()) == "DeepL_API_KEY")

normalize_text <- function(x) {
  if (is.null(x)) {
    return("")
  }

  if (is.data.frame(x)) {
    if ("content" %in% names(x)) {
      return(paste(as.character(x$content), collapse = "\n"))
    }
    return(paste(as.character(unlist(x, use.names = FALSE)), collapse = "\n"))
  }

  if (is.list(x)) {
    if (!is.null(x$text)) {
      return(paste(as.character(x$text), collapse = "\n"))
    }
    if (!is.null(x$content)) {
      return(paste(as.character(x$content), collapse = "\n"))
    }
    return(paste(as.character(unlist(x, use.names = FALSE)), collapse = "\n"))
  }

  paste(as.character(x), collapse = "\n")
}

say_text <- function(text, voice, rate = 200) {
  if (!deepRstudio::is_mac()) {
    return(invisible(NULL))
  }

  base::system2(
    "say",
    args = c(
      "-r", as.character(rate),
      "-v", base::shQuote(normalize_text(voice)),
      base::shQuote(normalize_text(text))
    ),
    stdout = FALSE,
    stderr = FALSE
  )
}

#Create graph nodes
set.seed(123)
g <- igraph::make_graph(c(), directed = TRUE)
g <- igraph::add_vertices(g, 4, name = c("H", "A", "B", "C"))

layout <- igraph::layout_in_circle(g)
#layout <- igraph::layout_nicely(g)*10
#layout <- igraph::layout_with_fr(g, area = vcount(g)^3)

shapes <- ifelse(igraph::V(g)$name == "H", "square", "rectangle")
labels <- c("H", "A\n(Beginner)", "B\n(Expert)", "C\n(Reviewer)")
vertex.label.cex <- ifelse(igraph::V(g)$name == "H", 1.5, 0.8)
vertex.size <- ifelse(igraph::V(g)$name == "H", 50, 95)
vertex.size2  <- ifelse(igraph::V(g)$name == "H", NA, 60)
vertex.color <- ifelse(igraph::V(g)$name == "H", "#AEDFF7", "#FFD1DC")

#Define edges
edges_to_add <- c("H", "A",
                  "A", "B",
                  "B", "A",
                  "A", "C",
                  "C", "A",
                  "A", "H")

# Decide voices on MacOS
if(deepRstudio::is_mac()){
  voices <- system2("say", args = c("-v", "?"), stdout = TRUE)
  a <- strsplit(voices, split="       |#")
  b <- data.frame(matrix(NA, nrow = length(a), ncol = 3))
  for(n in seq_len(length(a))){
    #n <- 1
    a1 <- a[[n]][a[[n]] != ""]
    a1[2] <- gsub(" ", "", a1[2])
    a1[3] <- gsub("^ ", "", a1[3])
    b[n,] <- a1
  }

  if(sayENorJA){
    d <-b[grepl("US$|GB$", b$X2),]
  }else{
    d <- b[grepl("JP$", b$X2),]
  }

  if(nrow(d) > 3){
      H_AI_voices <- as.character(d[sample(1:nrow(d), 4, replace = F),1])
  }else{
      H_AI_voices <- as.character(d[sample(1:nrow(d), 4, replace = T),1])
  }
}

Sentence_difficulty0 <- switch(as.character(Sentence_difficulty),
      "1" = "Make sure that you always answer using an expression that the elementary students can understand.",
      "2" = "Make sure you are always sure to answer using plain language and simple sentences.",
      "3" = "Make sure you always answer using technical terms and professional-sounding sentences.")

#LLB Settings
Setting_A <- "You are a beginner of %s. You can come up with lots of questions about a given %s topic, and you can ask great and pertinent questions."

if( R_expert_setting ){
Setting_B <- "You are an expert of %s, an expert in the R language. You are very knowledgeable in %s and can answer any related question."
}else{
Setting_B <- "You are an expert in %s in general. You are very knowledgeable in %s and can answer any related question."
}

if( R_expert_setting ){
Setting_C <- "You are a peer reviewer of %s, an expert in the R language. You have heard the summary stories of %s and can comment on improvements and shortcomings comprehensively and accurately.
Please explain in an easy-to-understand way for a first-time student. Please also suggest additional content that is missing from the discussion."
}else{
Setting_C <- "You are a peer reviewer of %s in general. You have heard the summary stories of %s and can comment on improvements and shortcomings comprehensively and accurately.
Please explain in an easy-to-understand way for a first-time student. Please also suggest additional content that is missing from the discussion."
#opt <- "Please return your answers as if you were having a conversation."
}

#Add domains
Setting_A_R <- paste(sprintf(Setting_A, Domain, Domain), Sentence_difficulty0)
Setting_B_R <- paste(sprintf(Setting_B, Domain, Domain), Sentence_difficulty0)
Setting_C_R <- paste(sprintf(Setting_C, Domain, Domain), Sentence_difficulty0)

#Task 1: create a question for the issue that the user provided
prompt_A = "
Please consider a question based on the following input in %s within %s words.:
"

# Substituting arguments into the prompt
prompt_A1 <- paste0(sprintf(prompt_A, language, Summary_nch), issue, sep=" ")

# Prompt creation
LLB_A <- list(list('role' = 'system', 'content' = paste(Setting_A_R)),
                  list('role' = 'user', 'content' = prompt_A1))

#Task 1
fut1 <- future::future({
res1 <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res1)

# Initialize res1_ja
res1_ja <- res1  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res1_ja <- normalize_text(deepRstudio::deepel(input = res1, target_lang = "JA")$text)
}}

list(res1, LLB_A, res1_ja)

})

#Graph 1
main = "Human ask to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[1:2])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Printing
#Task 2:
if(sayENorJA){
  message(crayon::red("\nHuman asks:"))
}else{
  message(crayon::red("\nHuman asks:"))
}

if(!sayENorJA){
  if(DEEPL){
  issue_ja <- normalize_text(deepRstudio::deepel(input = issue, target_lang = "JA")$text)
}}

#Task 2: Human say
rate <- 200
fut <- future::future({
if(sayENorJA){
  say_text(text = issue, voice = H_AI_voices[1], rate = rate)
}else{
  if(DEEPL){
  say_text(text = issue_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Task 2':
#Printing
if(sayENorJA){
slow_print_v2(issue, delay = 5/nchar(issue))
}else{
slow_print_v2(issue_ja, delay = 5/nchar(issue))
}

repeat{
if(all(future::resolved(fut), future::resolved(fut1))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res1 <- future::value(fut1)[[1]]
LLB_A <- future::value(fut1)[[2]]
res1_ja <- future::value(fut1)[[3]]

###############################################
#Task 3: ask it to the expert
prompt_B = "
Please professionally respond to the following question in %s within %s words.:
"

# Substituting arguments into the prompt
prompt_B1 <- paste0(sprintf(prompt_B, language, Summary_nch), res1, sep=" ")
# Prompt creation
LLB_B <- list(list('role' = 'system', 'content' = paste(Setting_B_R)),
                  list('role' = 'user', 'content' = prompt_B1))

#Task 3
fut3 <- future::future({
res2 <- normalize_text(chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res2)

# Initialize res2_ja
res2_ja <- res2  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res2_ja <- normalize_text(deepRstudio::deepel(input = res2, target_lang = "JA")$text)
}}

list(res2, LLB_B, res2_ja)

})

#Graph 2
main = "LLB A asks a question to LLB B"
g1 <- igraph::add_edges(g, edges_to_add[3:4])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Task 3'
#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res1, voice = H_AI_voices[2], rate = rate)
}else{
  if(DEEPL){
  say_text(text = res1_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
if(sayENorJA){
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res1, delay = 60/(rate*5))
}else{
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res1_ja, delay = 60/(rate*5))
}

repeat{
if(all(future::resolved(fut), future::resolved(fut3))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res2 <- future::value(fut3)[[1]]
LLB_B <- future::value(fut3)[[2]]
res2_ja <- future::value(fut3)[[3]]

#Task 4: Create question
# Substituting arguments into the prompt
prompt_A2 <- paste0(sprintf(prompt_A, language, Summary_nch), res2, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A2)

fut4 <- future::future({
res3 <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res3)

# Initialize res3_ja
res3_ja <- res3  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res3_ja <- normalize_text(deepRstudio::deepel(input = res3, target_lang = "JA")$text)
}}

list(res3, LLB_A, res3_ja)

})

#Graph 3
main = "LLB B answers to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[5:6])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB B say
fut <- future::future({
if(sayENorJA){
say_text(text = res2, voice = H_AI_voices[2], rate = rate)
}else{
  if(DEEPL){
  say_text(text = res2_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Task 4' Printing
message(crayon::blue("LLB B: Answer"))
#Printing
if(sayENorJA){
slow_print_v2(res2, delay = 60/(rate*5))
}else{
slow_print_v2(res2_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut4))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res3 <- future::value(fut4)[[1]]
LLB_A <- future::value(fut4)[[2]]
res3_ja <- future::value(fut4)[[3]]

#Task 5: ask it to the expert
# Substituting arguments into the prompt
prompt_B2 <- paste0(sprintf(prompt_B, language, Summary_nch), res3, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B2)

fut5 <- future::future({
res4 <- normalize_text(chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res4)

# Initialize res4_ja
res4_ja <- res4  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res4_ja <- normalize_text(deepRstudio::deepel(input = res4, target_lang = "JA")$text)
}}

list(res4, LLB_B, res4_ja)

})

#Graph 4
main = "LLB A ask a question to LLB B"
g1 <- igraph::add_edges(g, edges_to_add[3:4])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res3, voice = H_AI_voices[2], rate = rate)
}else{
  if(DEEPL){
  say_text(text = res3_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Task 5' Printing
message(crayon::cyan("LLB A: Question"))
if(sayENorJA){
slow_print_v2(res3, delay = 60/(rate*5))
}else{
slow_print_v2(res3_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut5))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res4 <- future::value(fut5)[[1]]
LLB_B <- future::value(fut5)[[2]]
res4_ja <- future::value(fut5)[[3]]

#Graph 5
main = "LLB B answer to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[5:6])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Task 6: summarize the conversation
prompt_A3 = "
Please sumerize the conversion with the following input in %s within %s words.:
"

prompt_A3 <- paste0(sprintf(prompt_A3, language, Summary_nch), res4, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A3)

fut6 <- future::future({
res5 <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res5)

# Initialize res5_ja
res5_ja <- res5  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res5_ja <- normalize_text(deepRstudio::deepel(input = res5, target_lang = "JA")$text)
  }}

list(res5, LLB_A, res5_ja)

})

#LLB B say
fut <- future::future({
if(sayENorJA){
say_text(text = res4, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res4_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::blue("LLB B: Answer"))
#Printing
if(sayENorJA){
slow_print_v2(res4, delay = 60/(rate*5))
}else{
slow_print_v2(res4_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut6))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res5 <- future::value(fut6)[[1]]
LLB_A <- future::value(fut6)[[2]]
res5_ja <- future::value(fut6)[[3]]

#######################################################################
#######################################################################
#Task 7: Critical reading
prompt_C = "
Please critically peer review and propose the improvement points for the following input in %s within %s words.:
"
# Substituting arguments into the prompt
prompt_C1 <- paste0(sprintf(prompt_C, language, Summary_nch), res5, sep=" ")

# Prompt creation
LLB_C <- list(list('role' = 'system', 'content' = paste(Setting_C_R)),
                  list('role' = 'user', 'content' = prompt_C1))

fut7 <- future::future({
res6 <- normalize_text(chat4R_history(history = LLB_C,
               api_key = api_key, Model = Model, temperature = 1)
)

# Initialize res6_ja
res6_ja <- res6  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res6_ja <- normalize_text(deepRstudio::deepel(input = res6, target_lang = "JA")$text)
}}

list(res6, res6_ja)

})

#Graph 6
main = "LLB A sumirize talks to LLB C"
g1 <- igraph::add_edges(g, edges_to_add[7:8])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res5, voice = H_AI_voices[2], rate = rate)
}else{
  if(DEEPL){
  say_text(text = res5_ja, voice = H_AI_voices[1], rate = rate)
}
}
})

#Printing
message(crayon::cyan("LLB A report 1st Summary to LLB C"))

#Printing
if(sayENorJA){
slow_print_v2(res5, delay = 60/(rate*5))
}else{
slow_print_v2(res5_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut7))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res6 <- future::value(fut7)[[1]]
res6_ja <- future::value(fut7)[[2]]


#Graph 6
main = "LLB C provide review comments to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[9:10])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB C say
fut <- future::future({
if(sayENorJA){
say_text(text = res6, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res6_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::green("LLB C: Review"))

#Printing
if(sayENorJA){
slow_print_v2(res6, delay = 60/(rate*5))
}else{
slow_print_v2(res6_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(future::resolved(fut)){
break()
}else{
Sys.sleep(0.5)
}}

#######################################################################
#######################################################################
#Human intervention:
Ans <- utils::askYesNo("Do you have an intervention for this conversation?")
if(Ans){
  intervention <- readline(prompt = paste("Please enter your intervention: "))
  Human_intervention_en <- normalize_text(deepRstudio::deepel(input = intervention, target_lang = "EN")$text)
  res6 <- paste("Human's comment (Make sure you follow these rules from human): ",
                 Human_intervention_en,
                 " Reviewer's comment: ", res6)
}
#######################################################################
#######################################################################
#Task 8: Create question
# Substituting arguments into the prompt
prompt_A4 <- paste0(sprintf(prompt_A, language, Summary_nch), res6, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A4)

fut8 <- future::future({
res7 <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res7)

# Initialize res7_ja
res7_ja <- res7  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res7_ja <- normalize_text(deepRstudio::deepel(input = res7, target_lang = "JA")$text)
}}

list(res7, LLB_A, res7_ja)
})

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut8))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res7 <- future::value(fut8)[[1]]
LLB_A <- future::value(fut8)[[2]]
res7_ja <- future::value(fut8)[[3]]

#######################################################################
#######################################################################
#Human intervention:
if(Ans){
  res7 <- paste(res7, Human_intervention_en)

  # Update res7_ja when res7 is modified
  res7_ja <- res7  # Default to original text

  if(!sayENorJA){
  if(DEEPL){
  res7_ja <- normalize_text(deepRstudio::deepel(input = res7, target_lang = "JA")$text)
  }}
}
#######################################################################
#######################################################################
#Task 08: ask it to the expert
# Substituting arguments into the prompt
prompt_B3 <- paste0(sprintf(prompt_B, language, Summary_nch), res7, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B3)

fut9 <- future::future({
res8 <- normalize_text(chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res8)

# Initialize res8_ja
res8_ja <- res8  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res8_ja <- normalize_text(deepRstudio::deepel(input = res8, target_lang = "JA")$text)
}}

list(res8, LLB_B, res8_ja)
})

#Graph 8
main = "LLB A ask a question to LLB B"
g1 <- igraph::add_edges(g, edges_to_add[3:4])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)


#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res7, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res7_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::cyan("LLB A ask: Question"))

#Printing
if(sayENorJA){
slow_print_v2(res7, delay = 60/(rate*5))
}else{
slow_print_v2(res7_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(fut9))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res8 <- future::value(fut9)[[1]]
LLB_B <- future::value(fut9)[[2]]
res8_ja <- future::value(fut9)[[3]]

#Graph 9
main = "LLB B answer to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[5:6])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB B say
fut <- future::future({
if(sayENorJA){
say_text(text = res8, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res8_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::blue("LLB B: Answer"))

#Printing
if(sayENorJA){
slow_print_v2(res8, delay = 60/(rate*5))
}else{
slow_print_v2(res8_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(future::resolved(fut)){
break()
}else{
Sys.sleep(0.5)
}}

#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#Here is a repeart point;
res <- res8
LLB_A <- LLB_A[c(1, length(LLB_A)-3, length(LLB_A)-2, length(LLB_A)-1, length(LLB_A))]
LLB_B <- LLB_B[c(1, length(LLB_B)-3, length(LLB_B)-2, length(LLB_B)-1, length(LLB_B))]

for(x in seq_len(rep_x)){

if(x%%2 != 0){
#Human intervention:
Ans <- utils::askYesNo("Do you have an intervention for this conversation?")
if(Ans){
  intervention <- readline(prompt = paste("Please enter your intervention: "))
  Human_intervention_en <- normalize_text(deepRstudio::deepel(input = intervention, target_lang = "EN")$text)
  res <- paste("Make sure you follow these rules: ",
                 Human_intervention_en, res)
}}


# Substituting arguments into the prompt
prompt_AR <- paste0(sprintf(prompt_A, language, Summary_nch), res, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_AR)

futR <- future::future({
res <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res)

# Initialize res_ja
res_ja <- res  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res_ja <- normalize_text(deepRstudio::deepel(input = res, target_lang = "JA")$text)
}}

list(res, LLB_A, res_ja)
})

main = "LLB A ask a question to LLB B"
g1 <- igraph::add_edges(g, edges_to_add[3:4])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Release asynchronous processing
repeat{
if(all(future::resolved(futR))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res <- future::value(futR)[[1]]
LLB_A <- future::value(futR)[[2]]
res_ja <- future::value(futR)[[3]]

#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::cyan("LLB A: Question"))

#Printing
if(sayENorJA){
slow_print_v2(res, delay = 60/(rate*5))
}else{
slow_print_v2(res_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(future::resolved(fut)){
break()
}else{
Sys.sleep(0.5)
}}

#######################################################################
#######################################################################
# Substituting arguments into the prompt
prompt_BR <- paste0(sprintf(prompt_B, language, Summary_nch), res, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_BR)

futR <- future::future({
res <- normalize_text(chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res)

# Initialize res_ja
res_ja <- res  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res_ja <- normalize_text(deepRstudio::deepel(input = res, target_lang = "JA")$text)
}}

list(res, LLB_B, res_ja)
})

#Graph 8
main = "LLB B answer to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[5:6])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(futR))){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res <- future::value(futR)[[1]]
LLB_B <- future::value(futR)[[2]]
res_ja <- future::value(futR)[[3]]

#LLB B say
fut <- future::future({
if(sayENorJA){
say_text(text = res, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
message(crayon::blue("LLB B: Answer"))

#Printing
if(sayENorJA){
slow_print_v2(res, delay = 60/(rate*5))
}else{
slow_print_v2(res_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(all(future::resolved(fut), future::resolved(futR))){
break()
}else{
Sys.sleep(0.5)
}}

}

#Results
res8 <- res

#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#Task 6: summarize the conversation
prompt_A3 = "
Please sumerize the conversion with the following input in %s within %s words.:
"
prompt_A3 <- paste0(sprintf(prompt_A3, language, Summary_nch), res8, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A3)

fut10 <- future::future({
res9 <- normalize_text(chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
)

# Initialize res9_ja
res9_ja <- res9  # Default to original text

if(!sayENorJA){
  if(DEEPL){
  res9_ja <- normalize_text(deepRstudio::deepel(input = res9, target_lang = "JA")$text)
  }}

list(res9, res9_ja)

})

#Release asynchronous processing
repeat{
if(future::resolved(fut10)){
break()
}else{
Sys.sleep(0.5)
}}

#re-input
res9 <- future::value(fut10)[[1]]
res9_ja <- future::value(fut10)[[2]]

#Graph 10
main = "LLB A report 2nd summary to Human"
g1 <- igraph::add_edges(g, edges_to_add[11:12])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#Printing
message(crayon::cyan("LLB A report to Human"))

#LLB A say
fut <- future::future({
if(sayENorJA){
say_text(text = res9, voice = H_AI_voices[2], rate = rate)
}else{
if(DEEPL){
  say_text(text = res9_ja, voice = H_AI_voices[1], rate = rate)
}}})

#Printing
if(sayENorJA){
slow_print_v2(res9, delay = 60/(rate*5))
}else{
slow_print_v2(res9_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
repeat{
if(future::resolved(fut)){
break()
}else{
Sys.sleep(0.5)
}}

return(message("Finished!!"))

}

