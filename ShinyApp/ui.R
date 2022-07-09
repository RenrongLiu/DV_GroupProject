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
  dashboardPage(
    
    dashboardHeader(title="ProjectName"),
    
    dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "home", icon=icon("home")),
        menuItem("Spotify Trend", tabName = "trend", icon=icon("chart-line")),
        menuItem("Artist Analysis", tabName = "artist", icon=icon("microphone")),
        menuItem("User Profile", tabName = "user", icon=icon("user-circle")),
        menuItem("About Us", tabName = "us", icon=icon("paperclip"))
      )
    ),
    
    dashboardBody(
      
      tabItems(
        
        tabItem(tabName = "home",
                h2("Home Page"),
                fluidRow(
                       box(
                         width=6,
                         title="About Spotify API",
                         solidHeader = TRUE,
                         status="primary",
                         collapsible = TRUE,
                         p("Put Spotify API intro here"),
                         br(),
                         # put video here, following the format:
                         # tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/T1-k7VYwsHg", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA)
                         tags$iframe()
                       ),
                       
                       box(
                         width=6,
                         title="About the Project",
                         solidHeader = TRUE,
                         status="primary",
                         collapsible = TRUE,
                         p("Put project description here")
                       )
                )
                ),
        
        tabItem(tabName = "trend",
                h2(" Audio Features of TOP 10 Items on Spotify in Year:"),
                selectInput("trendYear", label=NULL, choices = c(2012:2022)),
                
                tabsetPanel(
                  tabPanel("Artists",
                           fixedRow(
                             box(
                               width=4,
                               status = "primary",
                               radioButtons("artRB", label="Please select the feature:",
                                            choices = list("energy", "instrumentalness", "danceability",
                                                           "liveness", "loudness", "speechiness",
                                                           "valence", "common key"),
                                            selected = "0"),
                               
                             ),
                             
                             box(
                               width=8,
                               plotOutput("trendArt", height = "400px")
                             )
                           ),
                           
                           box(width=12,
                               title="Who is in TOP 10 Artists",
                               status="primary",
                               solidHeader = TRUE,
                               collapsible = TRUE)),
                  
                  tabPanel("Albums",
                           fixedRow(
                             box(
                               width=4,
                               status = "primary",
                               radioButtons("albRB", label="Please select the feature:",
                                            choices = list("energy", "instrumentalness", "danceability",
                                                           "liveness", "loudness", "speechiness",
                                                           "valence", "common key"),
                                            selected = "0"),
                               
                             ),
                             
                             box(
                               width=8,
                               plotOutput("trendAlb", height = "400px")
                             )
                           ),
                           
                           box(width=12,
                               title="Which are TOP 10 Albums",
                               status="primary",
                               solidHeader = TRUE,
                               collapsible = TRUE)),
                  
                  tabPanel("Tracks",
                           fixedRow(
                             box(
                               width=4,
                               status = "primary",
                               radioButtons("traRB", label="Please select the feature:",
                                            choices = list("energy", "instrumentalness", "danceability",
                                                           "liveness", "loudness", "speechiness",
                                                           "valence", "common key"),
                                            selected = "0"),
                               
                             ),
                             
                             box(
                               width=8,
                               plotOutput("trendTra", height = "400px")
                             )
                           ),
                           
                           box(width=12,
                               title="Which are TOP 10 Songs",
                               status="primary",
                               solidHeader = TRUE,
                               collapsible = TRUE))
                )),
        
        tabItem(tabName = "artist",
                tabsetPanel(
                  tabPanel("Artist Search",
                           textInput("artSearch", "Please enter the name of an artist:"),
                           submitButton("Submit"),
                           
                           br(),
                           
                           fluidRow(
                             box(width = 6,
                                 title="Artist's genre",
                                 status="primary",
                                 solidHeader = TRUE,
                                 wordcloud2Output("genreCloud", height = "400px")),
                             
                             box(width = 6,
                                 title="Artist's Most Common Keys",
                                 status="primary",
                                 solidHeader = TRUE,
                                 plotOutput("artKeyBar", height = "400px"))
                           )),
                  
                  tabPanel("Feature Summary",
                           box(width = 12,
                               title="Audio Feature Summary",
                               status="primary",
                               solidHeader = TRUE,
                               collapsible = TRUE,
                               plotOutput("artFeatSum", height = "400px")),
                           
                           box(width = 12,
                               title="Let's take a closer look",
                               status="primary",
                               solidHeader = TRUE,
                               
                               column(3,
                                      radioButtons("featByRB", label="Show features by:",
                                                   choices = list("Tracks", "Albums"),
                                                   selected = "0"),
                                      selectInput("featByX", label="Feature on the X-axis",
                                                  choices = list("energy", "instrumentalness", "danceability",
                                                                 "liveness", "loudness", "speechiness",
                                                                 "valence", "common key")),
                                      selectInput("featByY", label="Feature on the Y-axis",
                                                  choices = list("energy", "instrumentalness", "danceability",
                                                                 "liveness", "loudness", "speechiness",
                                                                 "valence", "common key"))),
                               
                               column(9, plotOutput("artFeatScatter", height="400px"))
                           )),
                  
                  tabPanel("Album Feature Comparison",
                           box(
                             width = 12,
                             title="Feature Differences Between Two Albums",
                             status="primary",
                             solidHeader = TRUE,
                             
                             column(3,
                                    selectInput("album1", "Select the first album:", choice=c(1,2)),
                                    selectInput("album2", "select the second album:", choice=c(1,2))),
                             
                             column(9, plotOutput("albComp", height = "400px"))
                           ))
                )),
        
        tabItem(tabName = "user"),
        
        tabItem(tabName = "us",
                h3("Authors")
                
                box(
                  width = 12,
                  title = "Yikai Jin",
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  collapsed = TRUE,
                  tags$img(),
                  p()
                ),
                
                box(
                  width = 12,
                  title = "Renrong Liu",
                  status = "success",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  collapsed = TRUE,
                  tags$img(),
                  p()
                ),
                
                box(
                  width = 12,
                  title = "Ruizhi Xu",
                  status = "info",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  collapsed = TRUE,
                  tags$img(),
                  p()
                ),
                
                box(
                  width = 12,
                  title = "Yue Pan",
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  collapsed = TRUE,
                  tags$img(),
                  p()
                ),
                
                box(
                  width = 12,
                  title = "Junzhe Zhu",
                  status = "danger",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  collapsed = TRUE,
                  tags$img(),
                  p()
                ))
        
      )
      
    )
    
    
  )
)

