#' Summarize Text via Web Scraping of Google Search
#'
#' Scrape text information from Google Search and summarize it using LLM.
#' Uses OpenAI API key for execution. Translation to Japanese requires a Deepl API key.
#'
#' @title Text Summary via Web Scraping
#' @description Scrapes Google Search results for the provided query and summarizes the content.
#' @param query The search query. Default is "LLM".
#' @param t Time period for search. 'w' for last week, 'm' for last month, 'y' for last year.
#'      Default is 'w'.
#' @param gl Geographical location based on ISO 3166-1 alpha-2 country code. Default is 'us'.
#' @param hl Language for search results based on ISO 639-1 language code. Default is 'en'.
#' @param URL_num Number of URLs to scrape. Default is 5.
#' @param verbose A boolean value indicating if details should be printed. Default is TRUE.
#' @param translateJA A boolean value indicating if results should be translated to Japanese.
#'      Default is FALSE.
#' @return Returns a list of summaries.
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_attr html_text read_html
#' @importFrom assertthat assert_that is.string is.count noNA
#' @importFrom utils URLencode
#' @export
#' @author Satoshi Kume
#' @examples
#' \dontrun{
#' summaryWebScrapingText(query = "LLM", t = "w", gl = "us", hl = "en", URL_num = 5)
#' }

summaryWebScrapingText <- function(query = "LLM",
                                   t = "w",
                                   gl = "us",
                                   hl = "en",
                                   URL_num = 5,
                                   verbose = TRUE,
                                   translateJA = FALSE){

  # Validate the inputs
  assertthat::assert_that(assertthat::is.string(query))
  assertthat::assert_that(assertthat::is.string(t))
  assertthat::assert_that(assertthat::is.string(gl))
  assertthat::assert_that(assertthat::is.string(hl))
  assertthat::assert_that(assertthat::is.count(URL_num))
  assertthat::assert_that(assertthat::noNA(URL_num))

  # Mapping the time period parameter
  tbs <- switch(t,
                "w" = "tbs=qdr:w", # Last week
                "m" = "tbs=qdr:m", # Last month
                "y" = "tbs=qdr:y", # Last year
                "tbs=qdr:m")

# URL encoding
url <- utils::URLencode(paste0("https://www.google.com/search?q=", query,
                        "&gl=", gl, "&hl=", hl, "&", tbs, "&num=", URL_num))

# Perform Google search and extract URLs
page_url <- xml2::read_html(url) |>
        rvest::html_nodes("a") |>
        rvest::html_attr("href")
page_url <- page_url[startsWith(page_url, "/url?q=")]
page_url <- sub("^/url\\?q\\=(.*?)\\&sa.*$", "\\1", page_url)
page_url <- page_url[!startsWith(page_url, "https://accounts.google.com")]
page_url <- page_url[!startsWith(page_url, "https://www.youtube.com")]

# Fetch text and summarize
res <- list()
for(n in seq_len(length(page_url))){
#n <- 1
if(verbose){cat("\nSearch: ", page_url[n])}

webpage <- rvest::read_html(page_url[n]) |>
  rvest::html_nodes("p") |>
  rvest::html_text()

#Using Hidden Functions
res0 <- `.TextSummary_v1`(webpage)
res[[n]] <- res0
names(res[[n]]) <- page_url[n]

# Translate to Japanese if translateJA is TRUE
if(translateJA){
  res0j <- deepRstudio::deepel(res0, target_lang = "JA")$text
  res[[n]][2] <- res0j
  #str(res)
  if(verbose){cat("\nJapanese text: \n", res0j)}
}

}

# Return the summarized results
return(res)

}


