#' Display Images and Optionally Write Them to Disk
#'
#' This function displays a list of EBImage objects, and optionally writes them to disk as PNG files.
#'
#' @title Display Images and Optionally Write Them to Disk
#' @description Displays a list of EBImage objects. If write is TRUE, it also writes them to the disk.
#'
#' @param img A list of EBImage objects. These are the images to display and optionally write to disk.
#' @param write A boolean. Defaults to FALSE. If TRUE, the function writes the images to disk as PNG files.
#' @param Rds A boolean. Defaults to FALSE. If TRUE, the function saves the images as Rds files.
#'
#' @importFrom assertthat assert_that
#' @importFrom EBImage display rotate
#' @importFrom abind abind
#' @importFrom png writePNG
#' @importFrom grDevices as.raster
#' @importFrom graphics par plot
#'
#' @return This function doesn't return anything. It displays images and optionally writes them to disk.
#'
#' @export
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' # Load an image
#' img <- list(EBImage::readImage(system.file("images", "sample-color.png", package="EBImage")))
#'
#' # Display the image
#' Display(img)
#'
#' # Display and write the image to disk
#' Display(img, write = TRUE)
#' }

Display <- function(img, write = FALSE, Rds = FALSE){
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
  "4" = c(1,4),
  "5" = c(2,4),
  "6" = c(2,4),
  "7" = c(2,4),
  "8" = c(2,4),
  "9" = c(3,3),
  "10" = c(3,4))

  graphics::par(mfrow=ans, mar=rep(0, 4))
  for(n in seq_len(length(img))){
  #n <- 1
  plot(t(grDevices::as.raster(img[[n]]@.Data, max=max(img[[n]]@.Data))))
}
}
