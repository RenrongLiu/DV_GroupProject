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
library(shinythemes)
library(shinyWidgets)

# Define UI for application that draws a histogram
shinyUI(
  
  dashboardPage(
    skin="black",
  
    dashboardHeader(title="Project Name"),

    #################### Dashboard siderbar ####################
      dashboardSidebar(
        tags$head(includeCSS("custom.css")),
        sidebarMenu(
          class="sidebar accordion",
          menuItem("Home", tabName = "home", icon=icon("home")),
          hr(class="sidebar-hr-gradient"),
          menuItem("Spotify Trends", tabName = "trend", icon=icon("chart-line")),
          menuItem("Artist Analysis", tabName = "artist", icon=icon("microphone")),
          menuItem("User Profile", tabName = "user", icon=icon("user-circle")),
          hr(class="sidebar-hr-gradient"),
          menuItem("About Us", tabName = "us", icon=icon("paperclip"))
        )
      ),
    
    dashboardBody(
      tabItems(
        #################### home page####################
        
        tabItem(tabName = "home",
                div(
                  class="top-container",
                  strong("Home Page", class="trends-h2")),
                
                fluidRow(
                  # Spotify API Intro###########
                       box(
                         width=6,
                         title="About Spotify API",
                         solidHeader = TRUE,
                         status="success",
                         background="black",
                         collapsible = TRUE,
                         p("Put Spotify API intro here"),
                         br(),
                         # put video here, following the format:
                         # tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/T1-k7VYwsHg", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA)
                         tags$iframe()
                       ),
                       
                  # Project intro ##########
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
        
        #################### Trend page ####################
        tabItem(
          tabName = "trend",
          div(
            class="top-container",
            strong("Trends at Spotify", class="trends-h2"),
            div(
              class="trends-slider",
              noUiSliderInput(
                inputId="trendYear",
                label="",
                value=c(2013,2021),
                min=2013,
                max=2021,
                step=1,
                width="400px",
                height="10px",
                color="#000000",
                format=wNumbFormat(decimals=0)
              )
            )
          ),
            
                
                tabsetPanel(
                  tabPanel("Artists",
                           fixedRow(
                             box(
                               width=4,
                               status = "primary",
                               radioButtons("artRB", label="Please select the feature:",
                                            choices = list("energy", "acousticness", "danceability",
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
                                            choices = list("energy", "acousticness", "danceability",
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
                                            choices = list("energy", "acousticness", "danceability",
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
        # Artist page##########
        tabItem(tabName = "artist",
                div(
                  class="top-container",
                  strong("Artist Analysis", class="trends-h2")),
                tabsetPanel(
                  tabPanel("Artist Search",
                           textInput("artSearch", "Please enter the name of an artist:","Ariana Grande"),
                           actionButton("button","Submit"),
                           
                           br(),
                           
                           fluidRow(
                             box(width = 6,
                                 title="Artist's image",
                                 status="success",
                                 background="black",
                                 solidHeader = TRUE,
                                 plotOutput("artimage")),
                             
                             box(width = 6,
                                 title="Artist's Most Common Keys",
                                 status="success",
                                 background="black",
                                 solidHeader = TRUE,
                                 plotOutput("artKeyBar", height = "400px"))
                           )),
                  
                  tabPanel("Feature Summary",
                           box(width = 12,
                               title="Audio Feature Summary",
                               status="success",
                               background="black",
                               solidHeader = TRUE,
                               collapsible = TRUE,
                               column(12,
                               plotOutput("artFeatSum", height = "400px"))),
                            
                           
                           
                           box(width = 12,
                               title="Let's take a closer look",
                               status="success",
                               background="black",
                               solidHeader = TRUE,
                               
                               column(3,
                                
                                      selectInput("featByX", label="Feature on the X-axis",
                                                  choices = list("energy", "acousticness", "danceability",
                                                                 "liveness", "speechiness",
                                                                 "valence")),
                                      selectInput("featByY", label="Feature on the Y-axis",
                                                  choices = list("energy", "acousticness", "danceability",
                                                                 "liveness", "speechiness",
                                                                 "valence"))),
                               
                               column(9, plotOutput("artFeatScatter", height="400px"))
                           )),
                  
                  tabPanel("Album Feature Comparison",
                           box(
                             width = 12,
                             title="Feature Differences Between Two Albums",
                             status="success",
                             background="black",
                             solidHeader = TRUE,
                            
                             
                             column(3,
                                    selectInput("album1", "Select the first album:", choice=""),
                                    selectInput("album2", "select the second album:", choice="")),
                             
                             column(9, plotOutput("albComp", height = "400px"))
                           )),
                  tabPanel("Datatable",
                           box(
                             width=12,
                             title="Data table of audio features",
                             status="success",
                             background="black",
                             solidHeader=TRUE,
                             column(12,
                                    h5("note: row name is the track id"),
                                    DT::dataTableOutput("table")
                                    )
                             
                           ))
                )),
        #user page ###########
        tabItem(tabName = "user",
                div(
                  class="top-container",
                  strong("Your Customized Profile", class="user-h2")),

                tabsetPanel(
                  tabPanel("Your Favorites",
                           box(width=12,
                               title="Top 10 Songs",
                               status="success",
                               background = "black",
                               solidHeader = TRUE,
                               collapsible = TRUE,
                               formattableOutput("topTra"),
                               style = "overflow-x: scroll;"),
                           
                           box(width=12,
                               status="success",
                               background = "black",
                               fixedRow(
                                 valueBoxOutput("favArt1"),
                                 valueBoxOutput("favArt2"),
                                 valueBoxOutput("favArt3")
                               )),
                               
                           fixedRow(
                             width=12,
                             column(6,
                                    plotOutput("userFavGen")),
                             column(6,
                                    plotOutput("userTraFeat"))
                           )),
                  
                  tabPanel("Recommendation",
                           fixedRow(
                             box(
                              width=4,
                              radioButtons("seedSel", 
                                            label="Get recomendations from my:",
                                            choices = list("Favorite tracks",
                                                          "Favorite artists",
                                                          "Favorite genres"))
                           ),
                           
                            box(
                              width = 8,
                              textOutput("favSeed")
                            )),
                           
                           box(width=12,
                               title="Your Customized Recommendation",
                               status="success",
                               background = "black",
                               solidHeader = TRUE,
                               collapsible = TRUE,
                               formattableOutput("recTra"))
                )
                )),
        #About us ############
        tabItem(tabName = "us",
                div(
                  class="top-container",
                  strong("Authors", class="trends-h2")),
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

