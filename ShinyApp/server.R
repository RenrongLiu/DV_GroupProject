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

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  
  access_token <- get_spotify_access_token()
  
 
  
  ######## Spotify Trend ############
  
  
  
  ######## Artist Analysis ############ 
  
  data=reactive({input$button
     return(get_artist_audio_features(isolate(input$artSearch)))})
  
  output$artKeyBar<-renderPlot({
    data()%>%
      ggplot(mapping=aes(x=key_mode,fill=key_mode))+
      geom_bar()+theme_classic()+theme(axis.text.x=element_blank(), axis.ticks.x = element_blank(),legend.title = element_blank())+
      labs(title="Distribution of songs located in different key mode",caption ="Data from Sporitfy",x="key mode",y="number of songs")})
  
  output$genreCloud<-renderPlot({ data_pop<-get_artist_top_tracks(
    data()[1,2],
    market = "US",
    authorization = get_spotify_access_token(),
    include_meta_info = FALSE
  )
  data_pop[,c(9,10)]->data_pop
  frequency=round(data_pop$popularity**2,0)
  wordcloud(words = data_pop$name,
            freq = frequency,
            random.order=FALSE,
            min.freq = 10,
            maxWords=500,
            ordered.colors=TRUE)})
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
  
  output$artFeatScatter<-renderPlot({
    data=data()
    data[,c("danceability","energy","speechiness","acousticness","liveness","valence","album_name")]->data_audio
    data_audio%>%
      ggplot(mapping=aes(x=as.name(input$featByX),y=as.name(input$featByY),color=album_name)+geom_jitter() +
      geom_vline(xintercept = 0.5) +
      geom_hline(yintercept = 0.5) +
      scale_x_continuous(limits = c(0, 1)) +
      scale_y_continuous(limits = c(0, 1)) +
      labs(x= input$featByX, y= input$featByY,color="Album name") +
      ggtitle("Audio features quadrant"))})
  album=reactive({
  data()%>%select(album_name)%>%distinct()%>%pull()
  })
 
  observe({  updateSelectInput(session=session,"album1",choices = album())
    
  })
  observe({   updateSelectInput(session=session,"album2",choices= album())
    
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
  
  access_token <- get_spotify_access_token()
  top_track <- get_my_top_artists_or_tracks("tracks", limit=10)

  
  
  
  ######## User Profile ##############

  
})
