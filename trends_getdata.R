
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggradar)

songs = read_csv("data/songs.csv")
table(songs$year)
summary(songs)
songs_clean = songs %>%
  filter(year<=2019 & year >=2000) %>%
  select(year,danceability,energy,speechiness,acousticness,instrumentalness,liveness,valence) %>%
  group_by(year) %>%
  summarise(across(everything(), mean)) %>%
  pivot_longer(c(2:8),names_to = "Type",values_to = "Score")
write_csv(songs_clean,"songs_clean.csv")
  ggplot(aes(x=year,y=Score,color=Type))+
  geom_line()+
  theme_light()

table(songs$year)
song

albums = read_csv("data/albums.csv")
table(albums$rel_date)

albums1=albums%>%
  mutate(year=substr(rel_date,nchar(rel_date)-3,nchar(rel_date)))
table(albums1$year)

artists = read_csv("data/artists.csv")


