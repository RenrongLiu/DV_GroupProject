#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(bslib)
library(formattable)
library(wordcloud2)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    #theme = "sketchy.css",
    
    titlePanel(title="ProjectName"),
    
    sidebarLayout(sidebarPanel(
      sidebarMenu(
        menuItem("Project Description", tabName = "intro", icon=icon("paperclip")),
        menuItem("Spotify Trends", tabName = "trend", icon=icon("chart-line")),
        menuItem("Artists Analysis", tabName = "artist", icon=icon("microphone")),
        menuItem("User Profile", tabName = "user", icon=icon("user-circle"))
      )
    ), 
    
    mainPanel(
      tabItems(
        # Project description page
        tabItem(tabName = "intro",
                # group member profile image and name
                column(4,
                       h3("Group members"),
                       br(),
                       br(),
                       
                       tags$img(),
                       br(),
                       p("Renrong Liu"),
                       br(),
                       br(),
                       
                       tags$img(),
                       br(),
                       p("Yikai Jin"),
                       br(),
                       br(),
                       
                       tags$img(),
                       br(),
                       p("Yue Pan"),
                       br(),
                       br(),
                       
                       tags$img(),
                       br(),
                       p("Ruizhi Xu"),
                       br(),
                       br(),
                       
                       tags$img(),
                       br(),
                       p("Junzhe Zhu")
                       ),
                # detailed project description
                column(8,
                       h3("Project Introduction"),
                       br(),
                       br(),
                       wellPanel(
                         p("detailed project description")
                       ))),
        
        tabItem(tabName = "trend"),
        
        tabItem(tabName = "artist",
                tabsetPanel(
                  tabPanel("Artist Search", textInput("search", 
                                                      "Please enter the name of an artist:"),
                           helpText("Note: Please enter the name exactly as appears in Spotify."),
                           submitButton("Submit"),
                           
                           fluidRow(column(6,
                                           wordcloud2Output("genre_cloud"))),
                                    
                                    column(6,
                                           plotOutput("key_barplot"))),
                  
                  tabPanel("Artist Features", plotOutput("artist_feature")),
                  tabPanel("Album comparison", 
                           column(6, 
                                  box(selectInput("album1", "Select the first album:", choice=c(1,2)),
                                      selectInput("album2", "select the second album:", choice=c(1,2)))),
                                  plotOutput("feature_comparison")
                           
                           ))
                ),
        
        tabItem(tabName = "user",
                tabsetPanel(
                  tabPanel("Favorite Songs", formattableOutput("UserTopTrack"),
                           style = "height:300px; overflow-y: scroll; overflow-x: scroll;"),
                  tabPanel("Favorite Artists", formattableOutput("UserTopArtist"),
                           style = "height:300px; overflow-y: scroll; overflow-x: scroll;"),
                  # Musical analysis, spider plot/
                  tabPanel("Unamed", plotOutput("FeatAnalysis"))
                )))
      )
    ))
)

