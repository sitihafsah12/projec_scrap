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
  titles = head(titles, 12),
  dates = head(dates, 12),
  links = head(links, 12),
  stringsAsFactors = FALSE
)

# MONGODB
message('Connecting to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

message('Checking Existing Data in MongoDB Atlas')
existing_data <- atlas_conn$find(fields = '{"links": 1, "_id": 0}')

message('Filtering New Data')
new_data <- data %>%
  filter(!links %in% existing_data$links)

message('Inserting New Data into MongoDB Atlas')
if (nrow(new_data) > 0) {
  atlas_conn$insert(new_data)
  message('New data inserted.')
} else {
  message('No new data to insert.')
}

rm(atlas_conn)
