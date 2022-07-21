
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggradar)
library(png)
library(jpeg)
library(RCurl)
library(grid)

################ songs #######################

songs = read_csv("ShinyApp/data/songs.csv")
#songs = unique(songs)
#songs %>% write_csv("ShinyApp/data/songs.csv")
table(songs$year)
summary(songs)
songs_num = songs%>%
  filter(year<=2019 & year >=2000) %>%
  group_by(year)%>%
  summarise(n=n())
write_csv(songs_num,"ShinyApp/data/songs_num.csv")
songs_clean = songs %>%
  filter(year<=2019 & year >=2000) %>%
  select(year,danceability,energy,speechiness,acousticness,instrumentalness,liveness,valence) %>%
  group_by(year) %>%
  summarise(across(everything(), mean)) %>%
  pivot_longer(c(2:8),names_to = "Features",values_to = "Score")
write_csv(songs_clean,"ShinyApp/data/songs_clean.csv")
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

write_csv(songs_key,"ShinyApp/data/songs_key.csv")
  
songs_key %>%
  ggplot(aes(x=year,y=key,color=key))+
  geom_point(shape="♪",size=8)+
  scale_y_continuous(breaks=c(0:11),labels=c("C","C#","D","D#","E","F","F#","G","G#","A","A#","B"))+
  scale_color_gradient(low = "cyan",high = "red")+
  theme_light()

songs=read_csv("ShinyApp/data/songs_clean.csv")
songs %>%
  filter(year==2000 | year == 2019) 
  ggradar()
  
  
################ albums #######################

albums = read_csv("ShinyApp/data/albums.csv")
table(albums$rel_date)

#albums=albums%>%
#  mutate(year=substr(rel_date,nchar(rel_date)-3,nchar(rel_date)))%>%
#table(albums$year)
#albums=albums[,-1]
write_csv(albums,"ShinyApp/data/albums.csv")
table(albums$year)

albums_clean = albums %>%
  mutate(year=as.numeric(substr(rel_date,nchar(rel_date)-3,nchar(rel_date))))%>%
  filter(year>=1960 & year <=2021) %>%
  select(year,danceability,energy,speechiness,acousticness,instrumentalness,liveness,valence) %>%
  group_by(year) %>%
  summarise(across(everything(), mean)) %>%
  pivot_longer(c(2:8),names_to = "Features",values_to = "Score")

albums_num = albums%>%
  filter(year<=2021 & year >=1960) %>%
  group_by(year)%>%
  summarise(n=n())
write_csv(albums_num,"ShinyApp/data/albums_num.csv")
write_csv(albums_clean,"ShinyApp/data/albums_clean.csv")

tmp=albums%>%
  filter(year<=2021 & year >=1960) %>%
  pull(gens)%>%
  str_split(pattern=", ")%>%
  map_df(as_tibble)%>%
  group_by(value)%>%
  summarise(freq=n())%>%
  arrange(desc(freq))%>%
  slice(1:20)

wordcloud2(tmp,size=1.5,color=brewer.pal(12, "Paired"))


############## artists ##############

artists = read_csv("ShinyApp/data/artists.csv")
#artists = artists%>%pivot_longer(c("1","2","3","4","5"),names_to = "rank",values_to = "artist")
#artists %>% write_csv("ShinyApp/data/artists.csv")

g=qplot()+
  scale_x_continuous(expand = c(0, 0))+
  scale_y_continuous(expand = c(0, 0))+
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) 
for(i in 1:45){
  artist_image = readJPEG(getURLContent(artists[i,4]))
  ymin=(artists[i,]$Year-2013)/9
  xmin=(artists[i,]$rank-1)/5
  print("ymin")
  print(ymin)
  g=g+annotation_raster(artist_image, ymin = ymin,ymax= ymin+1/9,xmin = xmin,xmax = xmin+1/5)
  print(g)
}
my_image <-  readJPEG(getURLContent(artists[3,4]))