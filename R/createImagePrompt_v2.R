#' Generate Image Prompts version 2
#'
#' @title Generate Image Prompts version 2
#' @description Generates optimal prompts for creating images using the OpenAI API.
#' Given a base prompt, negative elements, and style guidance, it generates three optimized prompts for image creation.
#' This is an experimental function.
#' @param Base_prompt A string. The main description of the image you want to generate (e.g., "A serene mountain landscape").
#' @param removed_from_image A string. Elements or attributes to avoid or exclude from the image (e.g., "people, buildings, text"). Use empty string if not applicable.
#' @param style_guidance A string. Style or quality guidance for the image generation (e.g., "photorealistic", "artistic", "detailed", "minimalist"). Default is "N/A".
#' @param Model A string. This is the model used for generating the prompts. Default is "gpt-4o-mini".
#' @param len An integer. This is the maximum length of the generated prompts. Must be between 1 and 1000. Default is 1000.
#' @importFrom assertthat assert_that is.count is.string
#' @return A vector of strings. Each string in the vector is a generated prompt (typically 3 prompts).
#' @export createImagePrompt_v2
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Example 1: Landscape without specific exclusions
#' base_prompt <- "A peaceful mountain lake surrounded by pine trees"
#' removed_from_image <- ""
#' style_guidance <- "photorealistic, high detail"
#'
#' res <- createImagePrompt_v2(Base_prompt = base_prompt,
#'                            removed_from_image = removed_from_image,
#'                            style_guidance = style_guidance,
#'                            len = 200)
#' print(res)
#'
#' # Example 2: Portrait with specific exclusions
#' base_prompt <- "A portrait of a wise elderly person"
#' removed_from_image <- "hat, glasses, jewelry"
#' style_guidance <- "oil painting style"
#'
#' res <- createImagePrompt_v2(Base_prompt = base_prompt,
#'                            removed_from_image = removed_from_image,
#'                            style_guidance = style_guidance)
#' print(res)
#' }

createImagePrompt_v2 <- function(Base_prompt = "",
                                 removed_from_image = "",
                                 style_guidance = "N/A",
                                Model = "gpt-4o-mini",
                                len = 1000){
  # Asserting input types and values
  assertthat::assert_that(assertthat::is.string(Base_prompt))
  assertthat::assert_that(assertthat::is.string(removed_from_image))
  assertthat::assert_that(assertthat::is.string(style_guidance))
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.count(len), len > 0, len < 1001)

  if(Base_prompt == "") {
    warning("No input provided.")
    stop()
  }

# Creating the prompt
len_w <- "Please create the optimal prompt based on the following requirements definition.
Base prompt: %s
Elements to avoid/exclude from image: %s
Style guidance: %s
When creating prompts, please consider providing specific descriptions,
using adjectives and adverbs to provide details, making comparisons or metaphors, and considering the context in which the image will be used.
The maximum length is %s characters. Please provide three suggestions for the prompt.
Please output only the three resulting prompts separated by double line breaks. No explanation is necessary."

# Substitute arguments into the prompt
template <- sprintf(len_w, Base_prompt, removed_from_image, style_guidance, len)

# Creating the list
history <- list(list('role' = 'system', 'content' = paste0('You are a helpful assistant and prompt master for creating text-to-image prompts. You will create optimized image generation prompts.')),
                 list('role' = 'user', 'content' = template))

  # Executing chat4R_history
  res_df <- chat4R_history(history, Model = Model)

  # Extract content from data.frame with enhanced validation
  if (is.null(res_df) || !is.data.frame(res_df) || !"content" %in% names(res_df) ||
      is.null(res_df$content) || length(res_df$content) == 0) {
    stop("Invalid or empty response from chat4R_history", call. = FALSE)
  }

  # Convert to character with robust error handling to prevent AI output randomness issues
  res <- tryCatch({
    # Handle list or nested structures from AI response
    if (is.list(res_df$content) && !is.data.frame(res_df$content)) {
      res_df$content <- unlist(res_df$content)
    }

    # Convert to character
    res_char <- as.character(res_df$content)

    # Collapse multiple elements if they exist
    if (length(res_char) > 1) {
      res_char <- paste(res_char, collapse = " ")
    }

    # Validate conversion result: must be single non-NA character
    if (is.na(res_char) || !is.character(res_char) || length(res_char) != 1) {
      stop("Conversion to character failed", call. = FALSE)
    }

    # Trim whitespace and validate non-empty content
    res_char <- trimws(res_char)
    if (nchar(res_char) == 0) {
      stop("Response content is empty after trimming", call. = FALSE)
    }

    res_char
  }, error = function(e) {
    stop(paste("Failed to process AI response:", e$message), call. = FALSE)
  })

  # Split the string safely with error handling
  res1 <- tryCatch({
    unlist(strsplit(res, "\\n\\n"))
  }, error = function(e) {
    stop(paste("Failed to split response text:", e$message), call. = FALSE)
  })

  # Filter out "---" separator lines and empty strings
  res1 <- res1[nzchar(trimws(res1)) & trimws(res1) != "---"]

  # Validate that we have at least one prompt
  if (length(res1) == 0) {
    stop("No valid prompts generated after filtering", call. = FALSE)
  }

  # Returning the image generation prompts
  return(res1)
}
