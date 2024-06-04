message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)

message('Scraping Data')
url <- "https://lambeturah.co.id/posts"
page <- read_html(url)

titles <- page %>% html_nodes(xpath = '//h3[@class="title"]/a') %>% html_text()
dates <- page %>% html_nodes(xpath = '//p[@class="small-post-meta"]/span[2]') %>% html_text()
links <- page %>% html_nodes(xpath = '//h3[@class="title"]/a') %>% html_attr("href")

data <- data.frame(
  time_scraped = Sys.time(),
  titles = head(titles, ),
  dates = head(dates, ),
  links = head(links, ),
  stringsAsFactors = FALSE
)

# MONGODB
message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

atlas_conn$insert(data)
rm(atlas_conn)
