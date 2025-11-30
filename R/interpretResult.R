#' Interpret Analysis Results
#'
#' This function constructs an interpretation prompt based on the analysis type and passes it to the `chat4R` function.
#'
#' @param analysis_type A character string indicating the type of analysis. Valid values include "summary", "PCA", "regression",
#'   "group_comparison", "visualization", "time_series", "clustering", "biological_implication", "statistical_metrics",
#'   "test_validity", "report", "preprocessing", and "custom".
#' @param result_text An object containing the analysis result to be interpreted. If it is not a character string,
#'   it will be converted to one using capture.output.
#' @param custom_template An optional custom prompt template to be used when analysis_type is "custom". If NULL, a default prompt is used.
#' @param model The chat model to use (default: "gpt-5-nano"). Set to another supported model string if needed.
#' @param temperature Sampling temperature passed to the chat model (default: 1).
#' @param api_key API key passed to `chat4R` (defaults to OPENAI_API_KEY).
#' @param use_fallback If TRUE, falls back to `fallback_model` when the primary model errors.
#' @param fallback_model Model used when the primary model errors (default: "gpt-5-nano"). Ignored if `use_fallback = FALSE` or the primary succeeds.
#'
#' @return The interpretation produced by AI (data.frame with a `content` column by default)
#'
#' @export interpretResult
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Example: interpret PCA results of the iris dataset
#' pca_res <- prcomp(iris[, 1:4], scale. = TRUE)
#' interpretation <- interpretResult("PCA", summary(pca_res))
#' cat(interpretation$content)
#' }
#' @importFrom glue glue
#' @importFrom utils capture.output
#' 

interpretResult <- function(analysis_type,
                            result_text,
                            custom_template = NULL,
                            model = "gpt-5-nano",
                            temperature = 1,
                            api_key = Sys.getenv("OPENAI_API_KEY"),
                            use_fallback = TRUE,
                            fallback_model = "gpt-5-nano") {
  # Convert result_text to a single string if it is not already a character string.
  if (!is.character(result_text)) {
    result_text <- paste(capture.output(result_text), collapse = "\n")
  } else if (length(result_text) > 1) {
    result_text <- paste(result_text, collapse = "\n")
  }

  # Validate the converted result_text.
  if (!nzchar(result_text)) {
    stop("result_text must not be empty.")
  }

  # Validate analysis_type: it must be a single character string.
  if (!is.character(analysis_type) || length(analysis_type) != 1) {
    stop("analysis_type must be a single character string.")
  }

  # Define valid analysis types.
  valid_types <- c("summary", "PCA", "regression", "group_comparison", "visualization",
                   "time_series", "clustering", "biological_implication", "statistical_metrics",
                   "test_validity", "report", "preprocessing", "custom")
  if (!(analysis_type %in% valid_types)) {
    stop(glue("Unknown analysis type. Please provide a valid value. Available values are: {paste(valid_types, collapse = ', ')}"))
  }

  # Construct the prompt using glue for readability.
  prompt <- switch(
    analysis_type,
    "summary" = glue("Please explain the data trends and key characteristics from the following summary statistics: {result_text}"),
    "PCA" = glue("Based on the following PCA analysis results, please explain the meaning of each principal component and the variance of the data: {result_text}"),
    "regression" = glue("Based on the following regression analysis results, please explain the meaning of each coefficient and the reliability of the model: {result_text}"),
    "group_comparison" = glue("Based on the following group comparison results, please explain the differences between groups and the statistical significance: {result_text}"),
    "visualization" = glue("Please interpret the trends, outliers, and clusters observed in the following plot: {result_text}"),
    "time_series" = glue("Based on the following time series analysis results, please describe the trends and seasonality: {result_text}"),
    "clustering" = glue("Based on the following clustering analysis results, please explain the characteristics of each cluster and the relationships between groups: {result_text}"),
    "biological_implication" = glue("From the following results, please interpret them from a biological perspective, such as ecosystems, evolutionary adaptations, or interspecies differences: {result_text}"),
    "statistical_metrics" = glue("Please provide a detailed explanation of the data distribution and variability based on the following statistical metrics (mean, median, variance, confidence intervals, etc.): {result_text}"),
    "test_validity" = glue("Based on the following statistical test results and assumptions, please explain the validity of the test method used and the extent to which the assumptions are met: {result_text}"),
    "report" = glue("Please integrate the following analysis results into a comprehensive analysis report: {result_text}"),
    "preprocessing" = glue("Based on the following data preprocessing/transformation results, please explain the effectiveness and considerations of the process: {result_text}"),
    "custom" = if (!is.null(custom_template)) {
      custom_template
    } else {
      glue("Please interpret the following results: {result_text}")
    }
  )

  # Helper to call chat model with optional fallback when a model is unavailable
  call_model <- function(prompt, model) {
    chat4R(
      content = prompt,
      Model = model,
      temperature = temperature,
      api_key = api_key
    )
  }

  model_used <- model
  interpretation <- tryCatch(
    call_model(prompt, model),
    error = function(e) {
      if (use_fallback && !is.null(fallback_model) && fallback_model != model) {
        model_used <<- fallback_model
        call_model(prompt, fallback_model)
      } else {
        stop(e)
      }
    }
  )

  # Attach which model was used for transparency
  attr(interpretation, "model_used") <- model_used

  return(interpretation)
}
