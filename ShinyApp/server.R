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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  access_token <- get_spotify_access_token()
  top_track <- get_my_top_artists_or_tracks("tracks", limit=10)
  
  ######## Spotify Trend ############
  
  
  
  ######## Artist Analysis ############
  
  
  
  ######## User Profile ##############

  
})
