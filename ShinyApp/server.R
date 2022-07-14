#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(spotifyr)
library(tidyverse)
library(wordcloud)
library(tidyverse)
library(spotifyr)
library(dplyr)
library(ggplot2)
library(tm)
library(syuzhet)
library(NLP)
library(wordcloud)
library(RColorBrewer)
library(fmsb)
library(magick)
library(rsvg)
library(gtools)
library(cowplot)
library(DT)
library(shinythemes)
library(shinyWidgets)

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
 
  
  ######## Spotify Trend ############
  
  
  
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
  
  
  output$topTra <- renderFormattable({
    
    top_track <- get_my_top_artists_or_tracks(type="tracks", limit=10)
    
    top10_tra <- top_track %>% 
      select(name, album.name, id, artists) %>% 
      unnest() %>% 
      select(name, name1, album.name,id) %>% 
      rename(Song = name) %>% 
      rename(Artist = name1) %>% 
      mutate(album.name = paste("《", album.name, "》", spe="")) %>% 
      rename(Album = album.name)
    
    id <- top10_tra %>% pull(id)
    audio_feat <- get_track_audio_features(id) %>% 
      select(c("energy", "acousticness", "danceability","liveness", 
               "speechiness", "valence", "id"))
    
    df <- top10_tra %>% 
      left_join(audio_feat, by="id") %>% 
      filter(!duplicated(id)) %>% 
      select(-id)

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
  
  
  #artist_name <- get_my_top_artists_or_tracks(limit=3) %>% 
  #  pull(name)
  
  artist_name = c("Taylor Swift", "Justin Bieber", "Justin Timberlake")
  
  output$favArt1 <- renderValueBox({
    
    valueBox(artist_name[1], 
             "Your Favorite Artist #1", icon=icon("heart"))
  })
  
  output$favArt2 <- renderValueBox({
    
    valueBox(artist_name[2], 
             "Your Favorite Artist #2", icon=icon("heart"),
             color = "yellow")
  })
  
  output$favArt3 <- renderValueBox({
    
    valueBox(artist_name[3], 
             "Your Favorite Artist #3", icon=icon("heart"),
             color = "purple")
  })
  
  
  output$userFavGen <- renderWordcloud2({
    
    top_50_track <- get_my_top_artists_or_tracks(type="tracks",
                                                 limit = 50)
    
    artist_id <- top_50_track %>% 
      select(artists) %>% 
      unnest(cols=c(artists)) %>% 
      select(id) %>% 
      distinct() %>% 
      pull(id)
    
    genres <- get_artists(ids=artist_id) %>% 
      select(genres)
    
    genre_list=list()
    
    for (x in genres$genres){
      genre_list = append(genre_list, x)
    }
    
    freq_genre <- unlist(genre_list) %>% 
      as_tibble() %>% 
      group_by(value) %>% 
      summarise(n=n()) %>% 
      arrange(desc(n))
    
    wordcloud2(freq_genre,
               size=1.5,
               backgroundColor = "black",
               color=brewer.pal(12, "Paired"))
    
  })
  
  output$userTraFeat <- renderPlotly({
    
    id <- get_my_top_artists_or_tracks("tracks", limit=10) %>% pull(id)
    
    audio_feat <- get_track_audio_features(id) %>% 
      select(c("energy", "acousticness", "danceability","liveness", 
               "speechiness", "valence", "id"))
    
    avg_feat <- audio_feat[,-7] %>% 
      sapply(mean)
    
    fig <- plot_ly(
      type = 'scatterpolar',
      r = avg_feat,
      theta = colnames(audio_feat)[-7],
      fill = 'toself',
      mode="markers"
    )
    
    fig <- fig %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0,1)
          )
        ),
        showlegend = F
      )
    
    fig
  })
  
  
})
