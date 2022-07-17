library(tidyverse)
library(dplyr)
library(ggplot2)


songs = read_csv("data/songs.csv")
table(songs$year)


albums = read_csv("data/albums.csv")
table(albums$rel_date)

albums1=albums%>%
  mutate(year=substr(rel_date,nchar(rel_date)-3,nchar(rel_date)))
table(albums1$year)
