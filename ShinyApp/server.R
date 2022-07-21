#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#install.packages("devtools")
#library(devtools)
#install_github("ricardo-bion/ggradar")

library(shiny)
library(spotifyr)
library(tidyverse)
library(tidyverse)
library(spotifyr)
library(dplyr)
library(ggplot2)
library(tm)
library(syuzhet)
library(NLP)
library(wordcloud2)
library(RColorBrewer)
library(fmsb)
library(magick)
library(rsvg)
library(gtools)
library(cowplot)
library(DT)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(ggradar)
library(jpeg)
library(RCurl)
library(grid)

# Function to authenticate user's id and secret
# This part of code is originate from a blog on towardDataScience written by Azaan Barlas:
# https://towardsdatascience.com/combining-spotify-and-r-an-interactive-rshiny-app-spotify-dashboard-tutorial-af48104cb6e9
authenticate <- function(id, secret) {
  # authenticate the spotify client stuff
  Sys.setenv(SPOTIFY_CLIENT_ID = id)
  Sys.setenv(SPOTIFY_CLIENT_SECRET = secret)
  
  access_token <- get_spotify_access_token()
}



# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  
  ##### Authentication ######
  # This part of code is originate from a blog on towardDataScience written by Azaan Barlas:
  # https://towardsdatascience.com/combining-spotify-and-r-an-interactive-rshiny-app-spotify-dashboard-tutorial-af48104cb6e9
  validate <- eventReactive(input$valid, {authenticate(input$spotifyId, input$spotifySec)})
  output$valMessage <- renderText({ validate() })
 
  
  ######## Spotify Trend - songs ############
  
  
  ####### data processing
  songs_all = read_csv("data/songs.csv",show_col_types = FALSE)
  songs = read_csv("data/songs_clean.csv",show_col_types = FALSE)
  songs_key = read_csv("data/songs_key.csv",show_col_types = FALSE)
  musical_keys=c("C","C#","D","D#","E","F","F#","G","G#","A","A#","B")

  output$songs_table = DT::renderDT({
    songs_dt = songs_all %>%
      filter(year<=2019 & year >=2000) %>%
      select(artist,song,year,danceability,energy,speechiness,acousticness,instrumentalness,liveness,valence)
    songs_dt[,4:10] = round(songs_dt[,4:10],2)
    songs_dt
  })
  
  output$songs_overview = renderPlotly({
    g = songs_all%>%
      filter(year>=2000&year<=2019)%>%
      ggplot(aes(x=year))+
      geom_bar()+
      theme_light()
    ggplotly(g)
  })
  
  output$songs_features_lineplot = renderPlotly({
    
    g= songs %>%
      filter(year<=input$songs_years[2] & year >=input$songs_years[1]) %>%
      ggplot(mapping=aes(x=year,y=Score,color=Features))+
      #geom_point(shape=4,size=1)+
      geom_smooth()+
      theme_light()
    ggplotly(g)
  })
  
  output$songs_key = renderPlot({
    songs_key %>%
      filter(year<=input$songs_years[2] & year >=input$songs_years[1]) %>%
      ggplot(aes(x=year,y=key,color=key))+
      geom_point(shape="♪",size=10)+
      scale_y_continuous(breaks=c(0:11),labels=musical_keys)+
      scale_color_gradient(low = "red",high = "cyan")+
      theme_light()
  })
  
  
  output$songs_compare = renderPlot({
    songs %>% 
      pivot_wider(names_from = Features,values_from = Score)%>%
      filter(year==input$songs_compare1 | year ==input$songs_compare2) %>%
      ggradar()
  })
  
  
  output$songs_comparekey1 = renderValueBox({
    key1=songs_key[songs_key$year==input$songs_compare1,]$key
    valueBox(
      musical_keys[key1+1],
      paste0("Most Common Key in ",as.character(input$songs_compare1)),
      icon = icon("music",lib='glyphicon'),
      color = "green")
  })
  
  output$songs_comparekey2 = renderValueBox({
    key2=songs_key[songs_key$year==input$songs_compare2,]$key
    valueBox(
      musical_keys[key2+1],
      paste0("Most Common Key in ",as.character(input$songs_compare2)),
      icon = icon("music",lib='glyphicon'),
      color = "green")
  })
  
  ######## Spotify Trend - albums ############
  
  
  ####### data processing
  albums_all = read_csv("data/albums.csv",show_col_types = FALSE)
  albums = read_csv("data/albums_clean.csv",show_col_types = FALSE)
  musical_keys=c("C","C#","D","D#","E","F","F#","G","G#","A","A#","B")
  
  output$albums_table = DT::renderDT({
    albums_dt = albums_all %>%
      filter(year<=2021 & year >=1960) %>%
      select(album,ars_name,rel_date,gens,danceability,energy,speechiness,acousticness,instrumentalness,liveness,valence)
    albums_dt[,5:11] = round(albums_dt[,5:11],2)
    albums_dt
  })
  
  output$albums_overview = renderPlotly({
    g = albums_all%>%
      filter(year>=1960&year<=2021)%>%
      ggplot(aes(x=year))+
      geom_bar()+
      labs(title="Number of albums in Each Year",y="albums")+
      theme_light()
    ggplotly(g)
  })
  
  output$albums_features_lineplot = renderPlotly({
    
    g1 = albums %>%
      filter(year<=input$albums_years[2] & year >=input$albums_years[1]) %>%
      ggplot(aes(x=year,y=Score,color=Features))+
      geom_smooth()+
      theme_light()+
      labs(title="Musical Features Trends")
    ggplotly(g1)
  })
  
  words = eventReactive(input$album_botton, {
    tmp=albums_all%>%
      filter(year<=input$albums_years[2] & year >=input$albums_years[1]) %>%
      pull(gens)%>%
      str_split(pattern=", ")%>%
      map_df(as_tibble)%>%
      group_by(value)%>%
      summarise(freq=n())%>%
      arrange(desc(freq))%>%
      slice(1:50)
    return(tmp)})
  
  output$albums_genres = renderWordcloud2({
    words=words()
    wordcloud2(words,size=1.5,color=brewer.pal(12, "Paired"))
  })
  
  output$albums_compare = renderPlot({
    albums %>% 
      pivot_wider(names_from = Features,values_from = Score)%>%
      filter(year==input$albums_compare1 | year ==input$albums_compare2) %>%
      ggradar()
  })
  
  
  output$albums_genres1 = renderValueBox({
    tmp=albums_all%>%
      filter(year==input$albums_compare1) %>%
      pull(gens)%>%
      str_split(pattern=", ")%>%
      map_df(as_tibble)%>%
      group_by(value)%>%
      summarise(freq=n())%>%
      arrange(desc(freq))%>%
      slice(1)
    valueBox(
      tmp,
      paste0("Genres in ",as.character(input$albums_compare1)),
      icon = icon("music",lib='glyphicon'),
      color = "green")
  })
  
  
  output$albums_genres2 = renderValueBox({
    tmp=albums_all%>%
      filter(year==input$albums_compare2) %>%
      pull(gens)%>%
      str_split(pattern=", ")%>%
      map_df(as_tibble)%>%
      group_by(value)%>%
      summarise(freq=n())%>%
      arrange(desc(freq))%>%
      slice(1)
    valueBox(
      tmp,
      paste0("Genres in ",as.character(input$albums_compare2)),
      icon = icon("music",lib='glyphicon'),
      color = "green")
  })
  
  ############## Trend - Artists ################
  
  artists = eventReactive(input$topartists_botton,{read_csv("data/artists.csv",show_col_types = FALSE)})
  
  output$topartists_image = renderPlot({
    artists=artists()
    g=ggplot()+
      scale_x_continuous(limits=c(0.75,5.25),position="top")+
      scale_y_continuous(limits=c(2013,2021),breaks=seq(2013,2021,1))+
      labs(
        x="Rank",
        y="Year"
      )+
      theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_text(size=25),
        axis.title.y = element_text(size=25),
        axis.text.x = element_text(size=15),
        axis.text.y = element_text(size=15)
      )
    a=(input$topartists_years[1]-2013)*5+1
    b=(input$topartists_years[2]-2012)*5
    for(i in a:b){
      artist_image = readJPEG(getURLContent(artists[i,4]))
      ymin=artists[i,]$Year-0.5
      xmin=artists[i,]$rank-0.5
      g=g+annotation_raster(artist_image, ymin = ymin,ymax= ymin+1,xmin = xmin,xmax = xmin+1)
      if(input$topartists_text){
        g=g+ggplot2::annotate("text",x=artists[i,]$rank,y=artists[i,]$Year,label=artists[i,]$artist,color="white",size=5)
      }
    }
    g
  })
  
  ######## Artist Analysis ############ 
  
  data=eventReactive(input$button, {
     return(get_artist_audio_features(isolate(input$artSearch)))})
  
  output$artKeyBar<-renderPlot({
    data()%>%
      ggplot(mapping=aes(x=key_mode,fill=key_mode))+
      geom_bar()+theme_classic()+theme(axis.text.x=element_blank(), axis.ticks.x = element_blank(),legend.title = element_blank())+
      labs(title="Distribution of songs located in different key mode",caption ="Data from Sporitfy",x="key mode",y="number of songs")})
  
  output$artimage<-renderPlot({
    data=data()
    get_artist(data[1,2], authorization = get_spotify_access_token())->artist
    ggdraw() + draw_image(artist$images[1,"url"])
  })
                               
  output$table<-DT::renderDT({data=data()
                            data[,c("danceability","energy","speechiness","acousticness","liveness","valence")]->audio_table
                            return(datatable(audio_table, rownames=data[,"track_id"]))})

  output$artFeatSum<-renderPlot({
    data=data()
    data[,c("danceability","energy","speechiness","acousticness","liveness","valence")]->data_spider
    data.frame(row.names=data[,"track_id"],data_spider)->data_spider
    data_mean<-data_spider%>%
      summarise_if(is.numeric, mean)
    rownames(data_mean)<-"Average"
    rbind(data_mean,data_spider)->data_spider
    max_min <- data.frame(
      danceability = c(1, 0), energy = c(1, 0), speechiness = c(1, 0),
      acousticness = c(1, 0), liveness = c(1, 0), valence = c(1, 0))
    
    rownames(max_min) <- c("Max", "Min")
    data_spider<- rbind(max_min, data_spider)
    
    data_spider
    
    return(radarchart(data_spider[c("Max","Min","Average"),], axistype=1 , 
               
               #custom polygon
               pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 , 
               
               #custom the grid
               cglcol="grey", cglty=1, axislabcol="black", caxislabels=seq(0,1,0.25), cglwd=1,
               
               #custom labels
               vlcex=0.8,
               title=paste0("Audio features of ",data[1,1])
    ))})
  
  output$artFeatScatter<-renderPlotly({
    data=data()
    print(input$featByY)
    print(input$featByX)
    data[,c("danceability","energy","speechiness","acousticness","liveness","valence","album_name")]->data_audio
    scatter<-data_audio%>%
      ggplot(mapping=aes_string(x=input$featByX,y=input$featByY,color="album_name"))+geom_jitter() +
      geom_vline(xintercept = 0.5) +
      geom_hline(yintercept = 0.5) +
      scale_x_continuous(limits = c(0, 1)) +
      scale_y_continuous(limits = c(0, 1)) +
      labs(x= input$featByX, y= input$featByY,color="Album name") +
      ggtitle("Audio features quadrant")
      return(ggplotly(scatter))
    })
  
  album=reactive({
  data()%>%distinct(album_name)%>%pull(album_name)
  })
 
  observe({  album=album()
    updateSelectInput(session=session,"album1",choices = album(),selected=album[1])
    
  })
  observe({  album=album()
    updateSelectInput(session=session,"album2",choices= album(),selected=album[3])
    
  })
 
  output$albComp<-renderPlot({
    create_beautiful_radarchart <- function(data, color = "#00AFBB", 
                                            vlabels = colnames(data), vlcex = 0.7,
                                            caxislabels = NULL, title = NULL, ...){
      radarchart(
        data, axistype = 1,
        # Customize the polygon
        pcol = color, pfcol = scales::alpha(color, 0.5), plwd = 2, plty = 1,
        # Customize the grid
        cglcol = "black", cglty = 1, cglwd = 0.8,
        # Customize the axis
        axislabcol = "black", 
        # Variable labels
        vlcex = vlcex, vlabels = vlabels,
        caxislabels = caxislabels, title = title, ...
      )
    }
    data=data()
    comparison_spider<-data%>%group_by(album_name)%>%
      summarise(danceability=mean(danceability),
                energy=mean(energy),
                speechiness=mean(speechiness),
                acousticness=mean(acousticness),
                liveness=mean(liveness),
                valence=mean(valence))
    comparison_spider[,2:7]->content_spider
    data.frame(content_spider)->content_spider
    comparison_spider$album_name->row.names(content_spider)
    max_min <- data.frame(
      danceability = c(1, 0), energy = c(1, 0), speechiness = c(1, 0),
      acousticness = c(1, 0), liveness = c(1, 0), valence = c(1, 0))
    
    rownames(max_min) <- c("Max", "Min")
    content_spider<- rbind(max_min, content_spider)
    
    op <- par(mar = c(1, 2, 2, 2))
    create_beautiful_radarchart(
      data = content_spider[c("Max","Min",input$album1,input$album2),], caxislabels = c(0, 0.25, 0.5, 0.75, 1),
      color = c("#00AFBB", "#E7B800", "#FC4E07"),title=paste0(rownames(content_spider[input$album1,])," VS ",rownames(content_spider[input$album2,])
      ))
    legend(
      x = 0.6, y=1.3,legend = rownames(content_spider[c(input$album1,input$album2),]), col = c("#00AFBB", "#E7B800", "#FC4E07"),
      text.col = "black", cex = 0.8, pt.cex = 0.8,bty = "n", pch = 20,title="Album Chosen")
    par(op)
    
    return(content_spider)
    
  })
  
  
  
  ######## User Profile ############ 
  # get user's top 10 songs.
  top10_track <- eventReactive(input$valid, {
    
    tracks <- get_my_top_artists_or_tracks("tracks", limit=10)
    
    # If no top songs, we create a back up list from all-time popular songs
    if (is.null(tracks) || is.null(dim(tracks))){
      songs_at <- read_csv("data/songs_alltime.csv")
      names <- songs_at[1:10,] %>% pull(Title)
      tracks <- data.frame()
      
      for (name in names){
        row = search_spotify(name, type=c("track"))
        tracks <- rbind(tracks, row[1,])
      }
    }
    
    # clean up the top song dataframe
    tidy_track <- tracks %>% 
      select(name, album.name, id, artists) %>% 
      unnest() %>% 
      select(name, name1, album.name,id) %>% 
      rename(song = name) %>% 
      rename(artist = name1) %>% 
      mutate(album.name = paste("《", album.name, "》", spe="")) %>% 
      rename(album = album.name)
    
    return(tidy_track)
  })
  
  
  output$topTra <- renderFormattable({
    
    id <- top10_track() %>% distinct(id) %>% pull(id)
    
    audio_feat <- get_track_audio_features(id) %>% 
      select(c("energy", "acousticness", "danceability","liveness", 
               "speechiness", "valence", "id"))
    
    df <- top10_track() %>% 
      left_join(audio_feat, by="id") %>%
      filter(!duplicated(id)) %>% 
      select(-id)
    
    
    # Get audio features for user's top ten songs
    #audio_feat <- get_track_audio_features(id) %>% 
      #select(c("energy", "acousticness", "danceability","liveness", 
               #"speechiness", "valence", "id"))
    
    #df <- top10_track %>% 
      #left_join(audio_feat, by="id") %>% 
      #filter(!duplicated(id)) %>% 
      #select(-id)

    formattable(df,
                align = c(rep("l", 3),rep("r", 6)),
                list(
                  'energy' = color_bar("#FA614B"),
                  'acousticness' = color_bar("#FA614B"),
                  'danceability' = color_bar("#FA614B"),
                  'liveness' = color_bar("#FA614B"),
                  'speechiness' = color_bar("#FA614B"),
                  'valence' = color_bar("#FA614B")
                  # area(col = 2:7) ~ color_tile("#DeF7E9", "#71CA97")
                ))
  })
  
  #################################################################
  ################Try to pull favorite artist name ################
  
  top3_artist <- eventReactive(input$valid, {
    
    artists <- get_my_top_artists_or_tracks("artists", limit=3)
    
    if (is.null(artists) || is.null(dim(artists))){
      artists <- read_csv("data/artists_alltime.csv")
      names <- artists[1:3,] %>% pull(Artist)
    }else{
      names <- artists %>% pull(name)
    }
    
    return(names)
    
  })
  
  #################################################################
  
  
  
  output$favArt1 <- renderValueBox({
    
    valueBox(value = tags$p(top3_artist()[1], style = "font-size: 80%;"), 
             "Your Favorite Artist #1", icon=icon("heart"))
  })
  
  output$favArt2 <- renderValueBox({
    
    valueBox(value = tags$p(top3_artist()[2], style = "font-size: 80%;"), 
             "Your Favorite Artist #2", icon=icon("heart"),
             color = "yellow")
  })
  
  output$favArt3 <- renderValueBox({
    
    valueBox(value = tags$p(top3_artist()[3], style = "font-size: 80%;"), 
             "Your Favorite Artist #3", icon=icon("heart"),
             color = "purple")
  })
  
  
  #################################################################
  ################top 50 artists' genres ################
  
    artist_ids <- eventReactive(input$valid, {
    
    # Get user's top 50 songs and their artist
    top_50_track <- get_my_top_artists_or_tracks(type="tracks",
                                                 limit = 50)
    
    if(is.null(top_50_track) || is.null(dim(top_50_track))){
      
      df <- read_csv("data/artists_alltime.csv")
      names <- df[1:50,] %>% pull(Artist)
      ids <- list()
      
      for (name in names){
        id <- search_spotify(name, type=c("artist")) %>% pull(id)
        ids <- append(ids, id[1])
      }
      
    }  else{
      
      ids <- top_50_track %>% 
        select(artists) %>% 
        unnest(cols=c(artists)) %>% 
        distinct(id) %>% 
        pull(id)
      
    }
    
    return(ids)
    })
  
  #################################################################
  
  
  genres = eventReactive(input$profile_botton,{
    return(get_artists(ids=artist_ids()) %>% 
      select(genres))
  })
  
  output$userFavGen <- renderWordcloud2({
    
    #get artists' genres
    genres <- genres()
    
    genre_list=list()
    
    for (x in genres$genres){
      genre_list = append(genre_list, x)
    }
    
    # get most frequent genres
    freq_genre <- unlist(genre_list) %>% 
      as_tibble() %>% 
      group_by(value) %>% 
      summarise(n=n()) %>% 
      arrange(desc(n))
    
    wordcloud2(freq_genre,
               size=1.5,
               #backgroundColor = "black",
               color=brewer.pal(12, "Paired"))
    
  })
  
  
  
  
  observe({ 
    tracks = top10_track()
    songs = tracks %>% distinct(song) %>% pull(song)
    updateSelectInput(session=session,"topTraList",choices = songs,selected=songs[1])
  })
  
  
  output$userTraFeat <- renderPlotly({
    
    tracks <- top10_track()
    ids <- tracks %>% distinct(id) %>% pull(id)
    
    song_id <- tracks %>% 
      filter(song==as.character(input$topTraList)) %>% 
      pull(id)
    
    audio_feat <- get_track_audio_features(ids) %>% 
      select(c("energy", "acousticness", "danceability","liveness", 
               "speechiness", "valence", "id"))
    
    avg_feat <- audio_feat[,-7] %>% 
      sapply(mean)
    
    song_feat <- audio_feat %>% 
      filter(id == song_id) %>% 
      select(!id) %>% 
      as.numeric()
    
    #### Song vs average spider plot
    fig <- plot_ly(
      type = 'scatterpolar',
      fill = 'toself',
      mode = "markers"
    ) 
    fig <- fig %>%
      add_trace(
        r = avg_feat,
        theta = colnames(audio_feat)[-7],
        name = 'Average of Top 10 Songs'
      ) 
    fig <- fig %>%
      add_trace(
        r = song_feat,
        theta = colnames(audio_feat)[-7],
        name = input$topTraList
      ) 
    fig <- fig %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0,1)
          )
        )
      )
    
    fig %>% layout(title = paste(input$topTraList,'vs. The Average'))
  })
  
  
})
