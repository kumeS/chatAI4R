#' Interactions and Flow Control Between LLM-based Bots (LLBs)
#'
#' This function is described to simulate the interactions and flow control between
#' three different roles of LLM-based bots, abbreviated as LLBs,
#' and to reproduce more realistic dialogues and discussions.
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
#' @title discussion_flow_v1: Interactions and Flow Control Between LLM-based Bots (LLBs)
#' @description Simulates interactions and flow control between three different roles of LLM-based bots (LLBs).
#' @param issue The issue to be discussed. Example: "I want to solve linear programming and create a timetable."
#' @param Domain The domain of the discussion, default is "bioinformatics".
#' @param Model The model to be used, default is "gpt-4o-mini".
#' @param api_key The API key for OpenAI, default is retrieved from the system environment variable "OPENAI_API_KEY".
#' @param language The language for the discussion, default is "English".
#' @param Summary_nch The number of characters for the summary, default is 50.
#' @param verbose Logical, whether to print verbose output, default is TRUE.
#' @param Nonfuture Logical, whether to use an asynchronous processing or not, default is not to use (TRUE).
#' @param sayENorJA Logical, whether to say in English or Japanese, default is TRUE. This feature is available on  macOS system only.
#' @importFrom future plan future multisession resolved
#' @importFrom igraph graph add_vertices layout_nicely add_edges layout_with_fr
#' @importFrom deepRstudio is_mac deepel
#' @return A summary of the conversation between the bots.
#' @export discussion_flow_v1
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' issue <-  "I want to solve linear programming and create a timetable."
#'
#' #Run Discussion with the domain of bioinformatics
#' discussion_flow_v1(issue)
#' }

#issue = "I want to solve linear programming and create a timetable.";Domain = "bioinformatics";Model = "gpt-4o-mini";api_key = Sys.getenv("OPENAI_API_KEY");language = "English";Summary_nch = 50; verbose = TRUE; sayENorJA = FALSE; Nonfuture = TRUE

#discussion_flow_v1(issue, sayENorJA = FALSE)

discussion_flow_v1 <- function(issue,
                               Domain = "bioinformatics",
                               Model = "gpt-4o-mini",
                               api_key = Sys.getenv("OPENAI_API_KEY"),
                               language = "English",
                               Summary_nch = 50,
                               verbose = TRUE,
                               Nonfuture = TRUE,
                               sayENorJA = TRUE){

# Input validation
if (!is.character(issue) || length(issue) != 1 || nchar(issue) == 0) {
  stop("issue must be a non-empty character string", call. = FALSE)
}

if (!is.character(api_key) || length(api_key) != 1 || nchar(api_key) == 0) {
  stop("api_key must be a non-empty character string. Set OPENAI_API_KEY environment variable.", call. = FALSE)
}

if (!is.character(Domain) || length(Domain) != 1) {
  stop("Domain must be a character string", call. = FALSE)
}

if (!is.logical(verbose) || length(verbose) != 1) {
  stop("verbose must be a logical value", call. = FALSE)
}

#Create multi-session
future::plan(future::multisession())
DEEPL <- any(names(Sys.getenv()) == "DeepL_API_KEY")

#Create graph nodes
set.seed(123)
g <- igraph::make_graph(c(), directed = TRUE)
g <- igraph::add_vertices(g, 4, name = c("H", "A", "B", "C"))
layout <- igraph::layout_nicely(g)*10
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
                  "A", "B",
                  "B", "A",
                  "A", "C",
                  "C", "A",
                  "A", "B",
                  "B", "A",
                  "A", "H")

# Decide voices on MacOS
if(deepRstudio::is_mac()){
  voices <- system("say -v \\?", intern = TRUE)
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

#LLB Settings
Setting_A <- "You are a beginner of %s. You can come up with lots of questions about a given %s topic, and you can ask great and pertinent questions. "
Setting_B <- "You are an expert of %s, an expert in the R language. You are very knowledgeable in %s and can answer any related question."
Setting_C <- "You are a peer reviewer of %s. You have heard the summary stories of %s and can comment on improvements and shortcomings comprehensively and accurately.
Please explain in an easy-to-understand way for a first-time student. Please also suggest additional content that is missing from the discussion."
#opt <- "Please return your answers as if you were having a conversation."

#Add domains
Setting_A_R <- sprintf(Setting_A, Domain, Domain)
Setting_B_R <- sprintf(Setting_B, Domain, Domain)
Setting_C_R <- sprintf(Setting_C, Domain, Domain)

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
res1 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res1)

if(!sayENorJA){
  if(DEEPL){
  res1_ja <- deepRstudio::deepel(input = res1, target_lang = "JA")$text
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
  issue_ja <- deepRstudio::deepel(input = issue, target_lang = "JA")$text
}}

#Task 2: Human say
rate <- 200
fut <- future::future({
if(sayENorJA){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", issue, "'"))
}else{
  if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", issue_ja, "'"))
  }
}
})

#Task 2':
#Printing
if(sayENorJA){
slow_print_v2(issue, delay = 5/nchar(issue))
}else{
slow_print_v2(issue_ja, delay = 5/nchar(issue))
}

if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut1))){
break()
}else{
Sys.sleep(0.5)
}}}

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
res2 <- chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res2)

if(!sayENorJA){
  if(DEEPL){
  res2_ja <- deepRstudio::deepel(input = res2, target_lang = "JA")$text
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
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res1, "'"))
}else{
  if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res1_ja, "'"))
  }
}
})

#Printing
if(sayENorJA){
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res1, delay = 60/(rate*5))
}else{
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res1_ja, delay = 60/(rate*5))
}

if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut3))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res2 <- future::value(fut3)[[1]]
LLB_B <- future::value(fut3)[[2]]
res2_ja <- future::value(fut3)[[3]]

#Task 4: Create question
# Substituting arguments into the prompt
prompt_A2 <- paste0(sprintf(prompt_A, language, Summary_nch), res2, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A2)

fut4 <- future::future({
res3 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res3)

if(!sayENorJA){
  if(DEEPL){
  res3_ja <- deepRstudio::deepel(input = res3, target_lang = "JA")$text
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
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res2, "'"))
}else{
  if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res2_ja, "'"))
  }
}
})

#Task 4' Printing
message(crayon::blue("LLB B: Answer"))
#Printing
if(sayENorJA){
slow_print_v2(res2, delay = 60/(rate*5))
}else{
slow_print_v2(res2_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut4))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input with safe access
fut4_result <- future::value(fut4)
if (is.null(fut4_result) || length(fut4_result) < 3) {
  stop("Invalid result from fut4 - insufficient elements", call. = FALSE)
}

res3 <- if (!is.null(fut4_result[[1]])) fut4_result[[1]] else stop("Missing res3 from fut4", call. = FALSE)
LLB_A <- if (!is.null(fut4_result[[2]])) fut4_result[[2]] else stop("Missing LLB_A from fut4", call. = FALSE)
res3_ja <- if (!is.null(fut4_result[[3]])) fut4_result[[3]] else ""

#Task 5: ask it to the expert
# Substituting arguments into the prompt
prompt_B2 <- paste0(sprintf(prompt_B, language, Summary_nch), res3, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B2)

fut5 <- future::future({
res4 <- chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res4)

if(!sayENorJA){
  if(DEEPL){
  res4_ja <- deepRstudio::deepel(input = res4, target_lang = "JA")$text
}}

list(res4, LLB_B, res4_ja)

})

#Graph 4
main = "LLB A ask a question to LLB B"
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
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res3, "'"))
}else{
  if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res3_ja, "'"))
}
}
})

#Task 5' Printing
message(crayon::cyan("LLB A: Question"))
if(sayENorJA){
slow_print_v2(res3, delay = 60/(rate*5))
}else{
slow_print_v2(res3_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut5))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input with safe access
fut5_result <- future::value(fut5)
if (is.null(fut5_result) || length(fut5_result) < 1) {
  stop("Invalid result from fut5 - insufficient elements", call. = FALSE)
}

res4 <- if (!is.null(fut5_result[[1]])) fut5_result[[1]] else stop("Missing res4 from fut5", call. = FALSE)
LLB_B <- if (length(fut5_result) >= 2 && !is.null(fut5_result[[2]])) fut5_result[[2]] else stop("Missing LLB_B from fut5", call. = FALSE)
res4_ja <- if (length(fut5_result) >= 3 && !is.null(fut5_result[[3]])) fut5_result[[3]] else ""

#Graph 5
main = "LLB B answer to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[9:10])
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
res5 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res5)


if(!sayENorJA){
  if(DEEPL){
  res5_ja <- deepRstudio::deepel(input = res5, target_lang = "JA")$text
  }}

list(res5, LLB_A, res5_ja)

})

#LLB B say
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res4, "'"))
}else{
if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res4_ja, "'"))
}

}
})

#Printing
message(crayon::blue("LLB B: Answer"))
#Printing
if(sayENorJA){
slow_print_v2(res4, delay = 60/(rate*5))
}else{
slow_print_v2(res4_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut6))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res5 <- future::value(fut6)[[1]]
LLB_A <- future::value(fut6)[[2]]
res5_ja <- future::value(fut6)[[3]]

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
res6 <- chat4R_history(history = LLB_C,
               api_key = api_key, Model = Model, temperature = 1)

if(!sayENorJA){
  if(DEEPL){
  res6_ja <- deepRstudio::deepel(input = res6, target_lang = "JA")$text
}}

list(res6, res6_ja)

})

#Graph 6
main = "LLB A sumirize talks to LLB C"
g1 <- igraph::add_edges(g, edges_to_add[11:12])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB A say
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res5, "'"))
}else{
  if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res5_ja, "'"))
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
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut7))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res6 <- future::value(fut7)[[1]]
res6_ja <- future::value(fut7)[[2]]

#Task 8: Create question
# Substituting arguments into the prompt
prompt_A4 <- paste0(sprintf(prompt_A, language, Summary_nch), res6, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A4)

fut8 <- future::future({
res7 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res7)

if(!sayENorJA){
  if(DEEPL){
  res7_ja <- deepRstudio::deepel(input = res7, target_lang = "JA")$text
}}

list(res7, LLB_A, res7_ja)
})

#Graph 6
main = "LLB C provide review comments to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[13:14])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB C say
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[4], "'", res6, "'"))
}else{
if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res6_ja, "'"))
}
}
})

#Printing
message(crayon::green("LLB C: Review"))

#Printing
if(sayENorJA){
slow_print_v2(res6, delay = 60/(rate*5))
}else{
slow_print_v2(res6_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut8))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res7 <- future::value(fut8)[[1]]
LLB_A <- future::value(fut8)[[2]]
res7_ja <- future::value(fut8)[[3]]

#Task 08: ask it to the expert
# Substituting arguments into the prompt
prompt_B3 <- paste0(sprintf(prompt_B, language, Summary_nch), res7, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B3)

fut9 <- future::future({
res8 <- chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res8)

if(!sayENorJA){
  if(DEEPL){
  res8_ja <- deepRstudio::deepel(input = res8, target_lang = "JA")$text
}}

list(res8, LLB_B, res8_ja)
})

#Graph 8
main = "LLB A ask a question to LLB B"
g1 <- igraph::add_edges(g, edges_to_add[15:16])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)


#LLB A say
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res7, "'"))
}else{
if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res7_ja, "'"))
}
}
})

#Printing
message(crayon::cyan("LLB A ask: Question"))

#Printing
if(sayENorJA){
slow_print_v2(res7, delay = 60/(rate*5))
}else{
slow_print_v2(res7_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut9))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res8 <- future::value(fut9)[[1]]
LLB_B <- future::value(fut9)[[2]]
res8_ja <- future::value(fut9)[[3]]

#Task 6: summarize the conversation
prompt_A3 = "
Please sumerize the conversion with the following input in %s within %s words.:
"
prompt_A3 <- paste0(sprintf(prompt_A3, language, Summary_nch), res8, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A3)

fut10 <- future::future({
res9 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)

if(!sayENorJA){
  if(DEEPL){
  res9_ja <- deepRstudio::deepel(input = res9, target_lang = "JA")$text
  }}

list(res9, res9_ja)

})

#Graph 9
main = "LLB B answer to LLB A"
g1 <- igraph::add_edges(g, edges_to_add[17:18])
plot(g1, edge.arrow.size = 0.75,
     edge.arrow.size = 1, edge.arrow.width = 2, vertex.label.color = "black",
     vertex.shape = shapes, layout = layout, vertex.color=vertex.color,
     vertex.label.cex = vertex.label.cex, vertex.label = labels,
     vertex.size = vertex.size, vertex.size2 = vertex.size2,
     main = main)

#LLB B say
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res8, "'"))
}else{
if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res8_ja, "'"))
}
}
})

#Printing
message(crayon::blue("LLB B: Answer"))

#Printing
if(sayENorJA){
slow_print_v2(res8, delay = 60/(rate*5))
}else{
slow_print_v2(res8_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(all(future::resolved(fut), future::resolved(fut10))){
break()
}else{
Sys.sleep(0.5)
}}}

#re-input
res9 <- future::value(fut10)[[1]]
res9_ja <- future::value(fut10)[[2]]

#Graph 10
main = "LLB A report 2nd summary to Human"
g1 <- igraph::add_edges(g, edges_to_add[19:20])
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
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res9, "'"))
}else{
if(DEEPL){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", res9_ja, "'"))
}
}
})

#Printing
if(sayENorJA){
slow_print_v2(res9, delay = 60/(rate*5))
}else{
slow_print_v2(res9_ja, delay = 60/(rate*5))
}

#Release asynchronous processing
if(Nonfuture){
repeat{
if(future::resolved(fut)){
break()
}else{
Sys.sleep(0.5)
}}}

return(message("Finished!!"))

}

