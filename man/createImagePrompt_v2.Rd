% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/createImagePrompt_v2.R
\name{createImagePrompt_v2}
\alias{createImagePrompt_v2}
\title{Generate Image Prompts version 2}
\usage{
createImagePrompt_v2(
  Base_prompt = "",
  removed_from_image = "",
  stable_diffusion = "N/A",
  Model = "gpt-4o-mini",
  len = 1000
)
}
\arguments{
\item{Base_prompt}{A string. This is the base prompt that forms the basis for the generated prompts.}

\item{removed_from_image}{A string. This is an attribute that should be removed from the image.}

\item{stable_diffusion}{A string. This parameter is used to control the stability of the diffusion process.}

\item{Model}{A string. This is the model used for generating the prompts. Default is "gpt-4o-mini".}

\item{len}{An integer. This is the maximum length of the generated prompts. Must be between 1 and 1000. Default is 1000.}
}
\value{
A vector of strings. Each string in the vector is a generated prompt.
}
\description{
Generates optimal prompts for creating images using the OpenAI API.
Given a base prompt, image attributes, and model parameters, it generates the optimal prompts for image creation.
This is an experimental function.
}
\details{
Generate Image Prompts version 2
}
\examples{
\dontrun{
# Define the base prompt and image attributes
base_prompt = "A sunset over a serene lake"
removed_from_image = "The sun"
stable_diffusion = "Moderate"

# Generate image prompts
res <- createImagePrompt_v2(Base_prompt = base_prompt, removed_from_image = removed_from_image,
stable_diffusion = stable_diffusion, len = 100)

# Print the generated prompts
print(res)
}
}
\author{
Satoshi Kume
}
