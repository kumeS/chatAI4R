#' Generate Image Prompts using OpenAI
#'
#' This function generates prompts for creating images using OpenAI's API.
#' It uses the provided base prompt, image attributes, and model parameters to generate the optimal prompts.
#'
#' @title Generate Image Prompts using OpenAI
#' @description Generates optimal prompts for creating images using the OpenAI API.
#' Given a base prompt, image attributes, and model parameters, it generates the optimal prompts for image creation.
#' This is an experimental function.
#' @param Base_prompt A string. This is the base prompt that forms the basis for the generated prompts.
#' @param removed_from_image A string. This is an attribute that should be removed from the image.
#' @param stable_diffusion A string. This parameter is used to control the stability of the diffusion process.
#' @param Model A string. This is the model used for generating the prompts. Default is "gpt-3.5-turbo-16k".
#' @param len An integer. This is the maximum length of the generated prompts. Must be between 1 and 1000. Default is 1000.
#'
#' @importFrom assertthat assert_that is.count is.string
#'
#' @return A vector of strings. Each string in the vector is a generated prompt.
#'
#' @export createImagePrompt_v2
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Define the base prompt and image attributes
#' base_prompt = "A sunset over a serene lake"
#' removed_from_image = "The sun"
#' stable_diffusion = "Moderate"
#'
#' # Generate image prompts
#' res <- createImagePrompt_v2(Base_prompt = base_prompt, removed_from_image = removed_from_image,
#' stable_diffusion = stable_diffusion, len = 100)
#'
#' # Print the generated prompts
#' print(res)
#' }

createImagePrompt_v2 <- function(Base_prompt = "",
                                 removed_from_image = "",
                                 stable_diffusion = "N/A",
                                Model = "gpt-3.5-turbo-16k",
                                len = 1000){
  # Asserting input types and values
  assertthat::assert_that(assertthat::is.string(Base_prompt))
    assertthat::assert_that(assertthat::is.string(removed_from_image))
      assertthat::assert_that(assertthat::is.string(stable_diffusion))
  assertthat::assert_that(assertthat::is.string(Model))
  assertthat::assert_that(assertthat::is.count(len), len > 0, len < 1001)

  if(Base_prompt == "") {
    warning("No input provided.")
    stop()
  }

# Creating the prompt
len_w <- "Please create the optimal prompt based on the following requirements definition.
Base prompt: %s
removed from image: %s
stable diffusion: %s
When creating prompts, please consider providing specific descriptions, using adjectives and adverbs to provide details, making comparisons or metaphors, and considering the context in which the image will be used.
The maximum length is %s characters. Please provide three suggestions for the prompt.
Please output only the three resulting prompt. No explanation is necessary."

# Substitute arguments into the prompt
template <- sprintf(len_w, Base_prompt, removed_from_image, stable_diffusion, len)

# Creating the list
history <- list(list('role' = 'system', 'content' = paste0('You are a helpful assistant and prompt master for creating text to images. You will create an image generation prompt for DALL·E 2.')),
                 list('role' = 'user', 'content' = template))

  # Executing chat4R_history
  res <- chat4R_history(history, Model = Model)

  # Splitting the string
  res1 <- unlist(strsplit(res, "\\n\\n"))

  # Returning the image generation prompt
  return(res1)
}
