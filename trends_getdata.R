
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
  pivot_longer(c(2:8),names_to = "Features",values_to = "Score")
write_csv(songs_clean,"data/songs_clean.csv")
songs_clean%>%
  ggplot(aes(x=year,y=Score,color=Features))+
  geom_point(shape="♪",size=4)+
  theme_light()

songs_key = songs %>%
  select(year,key) %>%
  filter(year<=2019 & year >=2000) %>%
  group_by(year,key) %>%
  summarise(n=n()) %>%
  arrange(year,desc(n)) %>%
  group_by(year) %>%
  slice(1) %>%
  ungroup

write_csv(songs_key,"data/songs_key.csv")
  
songs_key %>%
  ggplot(aes(x=year,y=key,color=key))+
  geom_point(shape="♪",size=4)+
  scale_y_continuous(breaks=c(0:11),labels=c("A","A#","B","C","C#","D","D#","E","F","F#","G","G#"))

table(songs$year)
song

albums = read_csv("data/albums.csv")
table(albums$rel_date)

albums1=albums%>%
  mutate(year=substr(rel_date,nchar(rel_date)-3,nchar(rel_date)))
table(albums1$year)

artists = read_csv("data/artists.csv")


