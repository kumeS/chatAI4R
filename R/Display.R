#' Display Images and Optionally Write Them to File
#'
#' This function displays images that are stored in a list. It also has options for saving the images to a .Rds or .png file.
#'
#' @title Display Images and Optionally Write Them to File
#' @description This function takes in a list of images, displays each image, and optionally writes each image to a .Rds or .png file.
#'
#' @param img A list. The list of images to display. Each image in the list should be of class "Image".
#' @param write A logical. Whether to write the images to .png files. Defaults to FALSE.
#' @param Rds A logical. Whether to save the images as .Rds files. Defaults to FALSE.
#' @param mar A numeric. The margin size for the plot. Defaults to 0.05.
#'
#' @importFrom graphics par
#' @importFrom assertthat assert_that
#' @importFrom EBImage display
#' @importFrom png writePNG
#' @importFrom grDevices as.raster
#'
#' @return Invisible NULL. The function is called for its side effect of displaying images and optionally writing them to file.
#'
#' @export Display
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Create a list of images
#' img <- list(image1, image2, image3)
#'
#' # Display the images
#' Display(img)
#'
#' # Display the images and write them to .png files
#' Display(img, write = TRUE)
#'
#' # Display the images and save them as .Rds files
#' Display(img, Rds = TRUE)
#' }

Display <- function(img, write = FALSE, Rds = FALSE, mar = 0.05){
  # Store the current graphics parameters
  oldpar <- graphics::par(no.readonly = TRUE)

  # Make sure to restore the original graphics parameters when the function exits
  on.exit(graphics::par(oldpar))

  # Ensure that the input is a list and that the first element is of class "Image"
  assertthat::assert_that(is.list(img), length(img) > 0, class(img[[1]]) == "Image")

  # Set display method to raster
  options(EBImage.display = "raster")

  #Save as Rds
  if(Rds){
    r <- paste0("Img_", formatC(length(dir(pattern = "[.]Rds"))+1, flag = "0", width = 3), ".Rds")
    saveRDS(img, file = r)
    }

  # Iterate over the images in the list and display each one
  img0 <- list()
  for(n in seq_along(img)){
    #n <- 3
    EBImage::display(img[[n]])

    f <- paste0("Img_", formatC(length(dir(pattern = "[.]png"))+1, flag = "0", width = 3), ".png")
    if(write){
      if (dim(img[[n]])[3] != 4) {
          img0[[n]] <- EBImage::rotate(img[[n]], angle=-90)
          alpha_channel <- matrix(0, nrow = dim(img0[[n]])[1], ncol = dim(img0[[n]])[2])
          img0[[n]] <- abind::abind(img0[[n]], alpha_channel, along = 3)
      }
      #save image
      png::writePNG(img0[[n]], target = f)
    }
  }

  # Depending on the length of img, different configurations are chosen for displaying
  ans <- switch (length(img),
  "1" = c(1,1),
  "2" = c(1,2),
  "3" = c(1,3),
  "4" = c(2,2),
  "5" = c(2,3),
  "6" = c(2,3),
  "7" = c(2,4),
  "8" = c(2,4),
  "9" = c(3,3),
  "10" = c(3,4))

  graphics::par(mfrow=ans, mar=rep(mar, 4))
  for(n in seq_len(length(img))){
  #n <- 1
  plot(t(grDevices::as.raster(img[[n]]@.Data, max=max(img[[n]]@.Data))))
}
}
