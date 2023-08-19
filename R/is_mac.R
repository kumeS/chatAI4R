#' Check if the System is Running on Mac OS
#'
#' This function determines whether the current system is running on Mac OS.
#' It utilizes the system information provided by R to check the operating system name,
#' and returns TRUE if it is Mac OS (Darwin), and FALSE otherwise.
#'
#' @title Check Mac OS (Darwin)
#' @description Determines if the current system is running on Mac OS (Darwin).
#' @return Logical value indicating whether the system is Mac OS. Returns TRUE if Mac OS, FALSE otherwise.
#' @export is_mac
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' if (is_mac()) {
#'   print("This is a Mac OS system.")
#' } else {
#'   print("This is not a Mac OS system.")
#' }
#' }

is_mac <- function() {
  return(unname(Sys.info()["sysname"] == "Darwin"))
}

