#' Interactions and Flow Control Between LLM-based Bots (LLBs)
#'
#' This function simulates the relationships between three different roles of LLM bots (LLB A, B, C) to
#' reproduce more realistic dialogues and discussions.
#' The function assumes the following three roles:
#' A (Beginner): Generates questions and summaries based on the content of the discussion provided by the user.
#' B (Expert): Professionally answers questions from A.
#' C (Peer Reviewer): Reviews the dialogue between A and B and proposes improvements.
#' The three parties independently call the OpenAI API according to their roles, maintain their conversation history,
#' and execute the processes of questioning, answering, and peer reviewing.
#' The concept of the domain is to give a field of talk settings to each LLB.
#' It is recommended to use a model with accuracy higher than GPT-4.
#' English is recommended as the language, but verification will also be conducted in Japanese, the author's native language.
#'
#' @title discussion_flow_v1: Interactions and Flow Control Between LLM-based Bots (LLBs)
#' @description Simulates interactions and flow control between three different roles of LLM-based bots (LLBs).
#' @param issue The issue to be discussed. Example: "I want to solve linear programming and create a timetable."
#' @param Domain The domain of the discussion, default is "bioinformatics".
#' @param Model The model to be used, default is "gpt-4-0613".
#' @param api_key The API key for OpenAI, default is retrieved from the system environment variable "OPENAI_API_KEY".
#' @param language The language for the discussion, default is "English".
#' @param Summary_nch The number of characters for the summary, default is 50.
#' @param verbose Logical, whether to print verbose output, default is TRUE.
#' @param sayENorJA Logical, whether to say in English or Japanese, default is TRUE.
#' @importFrom future plan future multisession
#' @importFrom igraph graph add_vertices layout_nicely add_edges
#' @importFrom deepRstudio is_mac
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

#issue = "I want to solve linear programming and create a timetable.";Domain = "bioinformatics";Model = "gpt-4-0613";api_key = Sys.getenv("OPENAI_API_KEY");language = "English";Summary_nch = 50; verbose = TRUE; sayENorJA = TRUE

discussion_flow_v1 <- function(issue,
                               Domain = "bioinformatics",
                               Model = "gpt-4-0613",
                               api_key = Sys.getenv("OPENAI_API_KEY"),
                               language = "English",
                               Summary_nch = 50,
                               verbose = TRUE,
                               sayENorJA = TRUE){

#Create multi-session
future::plan(future::multisession())

#Create graph nodes
set.seed(123)
g <- igraph::graph(c(), directed = TRUE)
g <- igraph::add_vertices(g, 4, name = c("H", "A", "B", "C"))
layout <- igraph::layout_nicely(g)
shapes <- ifelse(igraph::V(g)$name == "H", "square", "circle")

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
Setting_A <- "You are a beginner of %s. You can come up with lots of questions about a given %s topic, and you can ask great and pertinent questions."
Setting_B <- "You are an expert of %s, an expert in Python and the R language. You are very knowledgeable in %s and can answer any related question."
Setting_C <- "You are a peer reviewer of %s. You have heard the summary stories of %s and can comment on improvements and shortcomings comprehensively and accurately."
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
list(res1, LLB_A)
})

#Graph 1
g1 <- igraph::add_edges(g, edges_to_add[1:2])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "Human ask to LLB A")

#Printing
#Task 2:
if(sayENorJA){
  message(crayon::red("Human asks:"))
}else{
  #deepRstudio::deepel()
}

#Task 2: Human say
rate <- 150
fut <- future::future({
if(sayENorJA){
  system(paste("say -r", rate, "-v", H_AI_voices[1], "'", issue, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Task 2':
#Printing
if(sayENorJA){
slow_print_v2(issue, delay = 5/nchar(issue))
}else{
  #deepRstudio::deepel()
}

#re-input
res1 <- future::value(fut1)[[1]]
LLB_A <- future::value(fut1)[[2]]

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
list(res2, LLB_B)
})

#Graph 2
g1 <- igraph::add_edges(g, edges_to_add[3:4])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB A asks a question to LLB B")

#Task 3'
#LLB A say
rate <- 155
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res1, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res1, delay = 60/(rate*5))

#re-input
res2 <- future::value(fut3)[[1]]
LLB_B <- future::value(fut3)[[2]]

#Task 4: Create question
# Substituting arguments into the prompt
prompt_A2 <- paste0(sprintf(prompt_A, language, Summary_nch), res2, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A2)

fut4 <- future::future({
res3 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res3)
list(res3, LLB_A)
})

#Graph 3
g1 <- igraph::add_edges(g, edges_to_add[5:6])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB B answers to LLB A")

#LLB B say
rate <- 200
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res2, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Task 4' Printing
message(crayon::blue("LLB B: Answer"))
slow_print_v2(res2, delay = 60/(rate*5))

#re-input
res3 <- future::value(fut4)[[1]]
LLB_A <- future::value(fut4)[[2]]

#Task 5: ask it to the expert
# Substituting arguments into the prompt
prompt_B2 <- paste0(sprintf(prompt_B, language, Summary_nch), res3, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B2)

fut5 <- future::future({
res4 <- chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res4)
list(res4, LLB_B)
})

#Graph 4
g1 <- igraph::add_edges(g, edges_to_add[7:8])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB A talk to LLB B")

#LLB A say
rate <- 155
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res3, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Task 5' Printing
message(crayon::cyan("LLB A: Question"))
slow_print_v2(res3, delay = 60/(rate*5))

#re-input
res4 <- future::value(fut5)[[1]]
LLB_B <- future::value(fut5)[[2]]

#Graph 5
g1 <- igraph::add_edges(g, edges_to_add[7:8])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB B talk to LLB A")

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
list(res5, LLB_A)
})

#Graph 5
g1 <- igraph::add_edges(g, edges_to_add[9:10])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB B talk to LLB A")

#LLB B say
rate <- 200
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res4, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::blue("LLB B: Answer"))
slow_print_v2(res4, delay = 60/(rate*5))

#re-input
res5 <- future::value(fut6)[[1]]
LLB_A <- future::value(fut6)[[2]]

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
res6
})

#Graph 6
g1 <- igraph::add_edges(g, edges_to_add[11:12])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB A ask to LLB C")

#LLB A say
rate <- 200
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res5, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::cyan("LLB A: 1st Summary"))
slow_print_v2(res5, delay = 60/(rate*5))

#re-input
res6 <- future::value(fut7)

#Task 8: Create question
# Substituting arguments into the prompt
prompt_A4 <- paste0(sprintf(prompt_A, language, Summary_nch), res6, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A4)

fut8 <- future::future({
res7 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'assistant', 'content' = res7)
list(res7, LLB_A)
})

#Graph 7
g1 <- igraph::add_edges(g, edges_to_add[13:14])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB C review to LLB A")

#LLB C say
rate <- 180
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[4], "'", res6, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::green("LLB C: Review"))
slow_print_v2(res6, delay = 60/(rate*5))

#re-input
res7 <- future::value(fut8)[[1]]
LLB_A <- future::value(fut8)[[2]]


#Task 08: ask it to the expert
# Substituting arguments into the prompt
prompt_B3 <- paste0(sprintf(prompt_B, language, Summary_nch), res7, sep=" ")
# Prompt creation
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'user', 'content' = prompt_B3)

fut9 <- future::future({
res8 <- chat4R_history(history = LLB_B,
               api_key = api_key, Model = Model, temperature = 1)
LLB_B[[length(LLB_B) + 1]] <- list('role' = 'assistant', 'content' = res8)
list(res8, LLB_B)
})

#Graph 8
g1 <- igraph::add_edges(g, edges_to_add[15:16])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB A ask to LLB C")

#LLB A say
rate <- 150
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res7, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::cyan("LLB A ask: Question"))
slow_print_v2(res7, delay = 60/(rate*5))

#re-input
res8 <- future::value(fut9)[[1]]
LLB_B <- future::value(fut9)[[2]]

#Task 6: summarize the conversation
prompt_A3 = "
Please sumerize the conversion with the following input in %s within %s words.:
"
prompt_A3 <- paste0(sprintf(prompt_A3, language, Summary_nch), res8, sep=" ")
LLB_A[[length(LLB_A) + 1]] <- list('role' = 'user', 'content' = prompt_A3)

fut10 <- future::future({
res9 <- chat4R_history(history = LLB_A,
               api_key = api_key, Model = Model, temperature = 1)
res9
})

#Graph 9
g1 <- igraph::add_edges(g, edges_to_add[17:18])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB C ask to LLB A")


#LLB B say
rate <- 200
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[3], "'", res8, "'"))
}else{
  #deepRstudio::deepel()
}
})

#Printing
message(crayon::blue("LLB B: Answer"))
slow_print_v2(res8, delay = 60/(rate*5))

#re-input
res9 <- future::value(res9)

#Graph 10
g1 <- igraph::add_edges(g, edges_to_add[19:20])
plot(g1, edge.arrow.size = 0.5, vertex.label.cex = 1.5, vertex.size = 50,
     edge.arrow.size = 1, edge.arrow.width = 2,
     vertex.shape = shapes, layout = layout,
     main = "LLB A report to Human")

#Printing
message(crayon::cyan("LLB B report to Human"))

#LLB A say
rate <- 150
fut <- future::future({
if(sayENorJA){
system(paste("say -r", rate, "-v", H_AI_voices[2], "'", res9, "'"))
}else{
  #deepRstudio::deepel()
}
})

slow_print_v2(res9, delay = 60/(rate*5))

}





