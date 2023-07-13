#' Display Images
#'
#' @title Display Images
#' @description This function displays images that are returned by the generateImage4R function.
#' @param img A list of images, as returned by the generateImage4R function.
#' @importFrom assertthat assert_that
#' @importFrom EBImage display
#' @importFrom graphics par
#' @export Display
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' # Generate images
#' results <- generateImage4R(content = "Japanese gal girl")
#' # Display the generated images
#' Display(results)
#' }

Display <- function(img){
  # Store the current graphics parameters
  oldpar <- graphics::par(no.readonly = TRUE)

  # Make sure to restore the original graphics parameters when the function exits
  on.exit(graphics::par(oldpar))

  # Ensure that the input is a list and that the first element is of class "Image"
  assertthat::assert_that(is.list(img), length(img) > 0, class(img[[1]]) == "Image")

  # Set display method to raster
  options(EBImage.display = "raster")

  # Iterate over the images in the list and display each one
  for(n in seq_along(img)){
    EBImage::display(img[[n]])
  }
}
