#' Display Images as a Movie
#'
#' This function takes a list of images (of type EBImage) and creates a movie
#' by displaying the images in sequence.
#' The movie can be saved in either mp4 or mov format.
#'
#' @title Display Images as a Movie
#' @description Create a movie from a list of EBImage type images,
#'    with specified interval, repetition, and output format.
#' @param img A list of EBImage type images to be displayed in the movie.
#' @param interval Numeric value specifying the time interval between frames. Default is 1.
#' @param N_repeat Integer value specifying the number of times the sequence
#'    should be repeated. Default is 3.
#' @param Output_format String specifying the output file format.
#'    Should be either "mp4" or "mov". Default is "mp4".
#' @importFrom assertthat assert_that is.number is.count is.string
#' @importFrom animation saveVideo ani.options
#' @return No return value, but a movie file is saved in the working directory.
#' @export DisplayAsMovie
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#'   img_list <- list(image1, image2, image3) # Example images of EBImage type
#'   DisplayAsMovie(img_list, interval = 2, N_repeat = 2, Output_format = "mov")
#' }

DisplayAsMovie <- function(img, interval = 1, N_repeat = 3, Output_format = "mp4"){

  # windows
  #oopts = ani.options(ffmpeg = "z:/R/ffmpeg.exe")
  # mac
  #oopts = ani.options(ffmpeg = "ffmpeg")

  assertthat::assert_that(is.list(img))
  assertthat::assert_that(assertthat::is.number(interval))
  assertthat::assert_that(assertthat::is.count(N_repeat))
  assertthat::assert_that(assertthat::is.string(Output_format))

  animation::saveVideo({
    # Corrected to use the 'interval' parameter
    animation::ani.options(interval = interval)
    for(n in 1:N_repeat){
      Display(img)
    }
  }, video.name = paste0("Movie_",
                         formatC(length(dir(pattern = paste0("[.]", Output_format)))+1, flag = "0", width = 3),
                         ".", Output_format),
  other.opts = "-b:v 300k -b:a 128k -vcodec h264 -acodec aac -pix_fmt yuv420p")
}


