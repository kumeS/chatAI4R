#' Get URLs of RIKEN Press Releases
#'
#' This function retrieves the URLs of press releases from the RIKEN website for a given year.
#'
#' @title get_riken_pressrelease_urls
#' @description Retrieves the URLs of press releases from the RIKEN website for a given year.
#' @param year The year for which press release URLs are to be retrieved.
#' @importFrom rvest read_html html_nodes html_attr
#' @importFrom magrittr %>%
#' @return A character vector of URLs for the press releases of the specified year.
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' get_riken_pressrelease_urls(2023)
#' }

get_riken_pressrelease_urls <- function(year){

  # Create URL
  url <- paste0("https://www.riken.jp/press/", year, "/index.html")

  # Read HTML from the URL
  webpage <- rvest::read_html(url)

  # Extract links from the HTML
  links <- webpage %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href")

  # Filter links that start with "/press/year" and do not end with "/index.html" or equal "/press/year/"
  links1 <- links[grepl(paste0("^[/]press[/]", year), links)]  %>%
    .[!grepl(paste0("^[/]press[/]", year, "[/]index.html"), .)] %>%
    .[. != paste0("/press/", year, "/")]

  # Append the base URL to the relative links
  links2 <- paste0("https://www.riken.jp", links1)

  # Return the links
  return(links2)
}

