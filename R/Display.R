#' Display Images and Optionally Write Them to File	#' Display Images and Optionally Write Them to File
#'	#'
#' @title Display Images and Optionally Write Them to File	#' @title Display Images and Optionally Write Them to File
#' @description This function displays images that are stored in a list. It also has options for saving the images to a .Rds or .png file.	#' @description This function displays images that are stored in a list. It also has options for saving the images to a .Rds or .png file.
#'	#'
#' @param img A list. The list of images to display. Each image in the list should be of class "Image".	#' @param img A list. The list of images to display. Each image in the list should be of class "Image".
#' @param write_file A logical. Whether to write the images to .png files. Defaults to FALSE.	#' @param write_file A logical. Whether to write the images to .png files. Defaults to FALSE.
#' @param Rds A logical. Whether to save the images as .Rds files. Defaults to FALSE.	#' @param Rds A logical. Whether to save the images as .Rds files. Defaults to FALSE.
#' @param mar A numeric. The margin size for the plot. Defaults to 0.05.	#' @param mar A numeric. The margin size for the plot. Defaults to 0.05.
#' @param mfRow A logical. Whether to use row-wise layout for multiple images. Defaults to TRUE.	#' @importFrom graphics par
#' @importFrom graphics par
#' @importFrom assertthat assert_that	#' @importFrom assertthat assert_that
#' @importFrom EBImage display	#' @importFrom EBImage display
#' @importFrom png writePNG	#' @importFrom png writePNG
#' @importFrom grDevices as.raster	#' @importFrom grDevices as.raster
#'	#'
#' @return Invisible NULL. The function is called for its side effect of displaying images and optionally writing them to file.	#' @return Invisible NULL. The function is called for its side effect of displaying images and optionally writing them to file.
#'	#'
#' @export Display	#' @export Display
#' @author Satoshi Kume	#' @author Satoshi Kume
#'	#'
#' @examples	#' @examples
#' \dontrun{	#' \dontrun{
#' # Create a list of images	#' # Create a list of images
#' img <- list(image1, image2, image3)	#' img <- list(image1, image2, image3)
#'	#'
#' # Display the images	#' # Display the images
#' Display(img)	#' Display(img)
#'	#'
#' # Display the images and write them to .png files	#' # Display the images and write them to .png files
#' Display(img, write_file = TRUE)	#' Display(img, write_file = TRUE)
#'	#'
#' # Display the images and save them as .Rds files	#' # Display the images and save them as .Rds files
#' Display(img, Rds = TRUE)	#' Display(img, Rds = TRUE)
#' }

Display <- function(img, write_file = FALSE, Rds = FALSE, mar = 0.05, mfRow = TRUE){
  # Store the current graphics parameters
  oldpar <- graphics::par(no.readonly = TRUE)

  # Make sure to restore the original graphics parameters when the function exits
  on.exit(graphics::par(oldpar))

# Ensure that all elements in the list are of class "Image"	# Ensure that the input is a list and that the first element is of class "Image"
assertthat::assert_that(is.list(img), length(img) > 0, all(sapply(img, function(x) class(x) == "Image")))
  # Set display method to raster
  options(EBImage.display = "raster")

  # Save as Rds
  if(Rds){
    r <- paste0("Img_", formatC(length(dir(pattern = "[.]Rds"))+1, flag = "0", width = 3), ".Rds")
    saveRDS(img, file = r)
    }

  # Create an empty list to store images
  img0 <- list()

  # Iterate over the images in the list and display each one
  for(n in seq_along(img)){

    EBImage::display(img[[n]])

    # Define the file name
    x <- length(dir(pattern = "^Img_"))
    y <- max(as.numeric(sub("[.]png$", "", sub("^Img_", "", dir(pattern = "^Img_")))))
    if( x < y ){
    f <- paste0("Img_", formatC(y+1, flag = "0", width = 3), ".png")
    }else{
    f <- paste0("Img_", formatC(x+1, flag = "0", width = 3), ".png")
    }

    # If the image is RGBA, rotate it and write it out
    if(write_file){
      if(dim(img[[n]])[3] == 4){
        img0[[n]] <- EBImage::rotate(img[[n]], angle=-90)
        alpha_channel <- matrix(0, nrow = dim(img0[[n]])[1], ncol = dim(img0[[n]])[2])
        img0[[n]] <- abind::abind(img0[[n]], alpha_channel, along = 3)
        dimnames(img0[[n]]) <- NULL
      } else {
        img0[[n]] <- EBImage::rotate(img[[n]], angle=-90)
      }

      # Save image
      png::writePNG(img0[[n]], target = f)
    }
  }

  # Determine the display configuration based on the length of the image list
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

  if(mfRow){
  graphics::par(mfrow=ans, mar=rep(mar, 4))
  }else{
  graphics::par(mfcol=ans, mar=rep(mar, 4))
  }

  # Display the images
  if(length(img) != 1){
  for(n in seq_len(length(img))){
    EBImage::display(img[[n]])
  }
  }
}

