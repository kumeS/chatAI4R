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



# Synchronous text generation with grounding:
result <- geminiGrounding4R(
mode = "text",
contents = "What is the current Google stock price?",
store_history = FALSE,
dynamic_threshold = 1,
api_key = Sys.getenv("GoogleGemini_API_KEY")
)
print(result)
