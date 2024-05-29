message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)

message('Scraping Data')
url <- "https://lambeturah.co.id"
page <- tryCatch(read_html(url), error = function(e) {
  message("Error reading HTML: ", e)
  NULL
})

if (!is.null(page)) {
  titles <- page %>% html_nodes(xpath = '//h3[@class="title"]/a') %>% html_text()
  dates <- page %>% html_nodes(xpath = '//p[@class="small-post-meta"]/span[2]') %>% html_text()
  links <- page %>% html_nodes(xpath = '//h3[@class="title"]/a') %>% html_attr("href")

  data <- data.frame(
    time_scraped = Sys.time(),
    titles = head(titles, 5),
    dates = head(dates, 5),
    links = head(links, 5),
    stringsAsFactors = FALSE
  )

  message('Input Data to MongoDB Atlas')
  atlas_conn <- tryCatch(mongo(
    collection = Sys.getenv("ATLAS_COLLECTION"),
    db         = Sys.getenv("ATLAS_DB"),
    url        = Sys.getenv("ATLAS_URL")
  ), error = function(e) {
    message("Error connecting to MongoDB: ", e)
    NULL
  })

  if (!is.null(atlas_conn)) {
    tryCatch({
      atlas_conn$insert(data)
      message("Data inserted successfully")
    }, error = function(e) {
      message("Error inserting data: ", e)
    })
    rm(atlas_conn)
  }
} else {
  message("Skipping MongoDB insertion due to previous errors")
}
