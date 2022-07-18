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
library(plotly)

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
          menuItem(
            "Spotify Trends", tabName = "trend", icon=icon("chart-line"),
            menuItem("Artists",tabName="TrendArtists", icon=icon("users")),
            menuItem("Songs",tabName="TrendSongs", icon=icon("music")),
            menuItem("Albums",tabName="TrendAlbums", icon=icon("file"))
          ),
          menuItem("Artist Analysis", tabName = "artist", icon=icon("microphone")),
          menuItem("User Profile", tabName = "user", icon=icon("user-circle")),
          hr(class="sidebar-hr-gradient"),
          menuItem("About Us", tabName = "us", icon=icon("paperclip")),
          menuItem("Reference", tabName = "reference", icon=icon("book")),
          menuItem("Visit Our Github", icon = icon("send", lib='glyphicon'), href = "https://github.com/RenrongLiu/DV_GroupProject")
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
                  # Project intro ##########
                  box(
                    width=6,
                    title="About the Project",
                    solidHeader = TRUE,
                    status="success",
                    background="black",
                    collapsible = TRUE,
                    collapsed = TRUE,
                    p("Spotify is one of the most popular audio streaming platforms, which including millions of subscribers. We are applying musical audio features analysis for the popular tracks on Spotify. The audio features can be seperated to different categories such as the mood, properties, and context. We mainly using danceability, energy, valence, sppechiness, liveness, and acousticness those six features to analysis the tracks.  "),
                    p("Our application has three major components:  "),
                    p("Spotify Trends:You can explore the top artists, tracks, and albums from year 2013 to 2021, and comparing the musical features trends among the songs. The page will provide you the overall idea of the musical feature taste transformation in the time duration."),
                    p("Artist Analysis: You can serch for your interested artists to see his or her image and the artists’ most common keys in the songs. To further learn your searched artist, audio feature summary will be provided with six components (danceability, energy, valence, sppechiness, liveness, and acousticness), and you can learn the artists’ songs and albums from different musical features. At last, this page includes the album comparision for the artist, you are welcome to choose two of the album from your searching artist to compare the overall musical features in the songs. "),
                    p("User Profile: The other interactive part in our project is understanding your Spotify list. We need your permission to link your Spotify account, and to give your summary of the top 10 songs, top 3 singers from you listening history. In addition, we would based on your favorite tracks, artists and genres to provide some cusomized recommendation, and it can provide advisory for your music. ")
                  ),
                  # Spotify API Intro###########
                       box(
                         width=6,
                         title="About Spotify API",
                         solidHeader = TRUE,
                         status="success",
                         background="black",
                         collapsible = TRUE,
                         collapsed = TRUE,
                         p("Technically, we using Spotify API to accesses user related data as the main data sources for our project. The Spotify’s Web API can dicover music, manage the labrary, control audio playbacks. We mainly get information such as albms, artist, tracks, and users from Spotify’s Web API. "),
                         br(),
                         # put video here, following the format:
                         tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/yAXoOolPvjU", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA),
                         tags$iframe()
                       )
                  ),
                
                fluidRow(
                  box(width=12,
                      column(6,
                             h3(strong("Get your Spotify access token here:")),
                             textInput("spotifyId", "Client ID: ", ""),
                             textInput("spotifySec", "Client Secret: ", ""),
                             actionButton("valid", "Validate"),
                             br(),
                             br(),
                             p(strong("If validation successes, you should see your Spotify access token below:")),
                             wellPanel(textOutput("valMessage"))
                             ),
                      
                      column(6,
                             h3(strong("Instructions")),
                             br(),
                             h6("Step 1: Go to https://developer.spotify.com/dashboard/ and login with your Spotify information"),
                             h6("Step 2: Create an app with name and description temp, then find the client ID and Client Secret"),
                             h6("Step 3: Copy and paste the ID and Secret into the designated dialog boxes, and click validate."),
                             h6("Step 4: Allow spotify to authenticate your account"),
                             h6("Now you should be good to go! Click one of the tabs above and learn more about your music")
                             # h6("Step 4: When prompted with the message are you ..., make sure to click NOT YOU and login yourself. Now you're good to go! "),
                             # verbatimTextOutput("txtout"), # generated from the server
                      )
                  )
                )

                ),
        
        #################### Trend page - Songs ####################
        tabItem(
          tabName = "TrendSongs",
          div(
            class="top-container",
            strong("Trends at Spotify: Artists", class="trends-h2")
          ),
          div(
            class="top-container2",
            div(
              class="trends-slider",
              noUiSliderInput(
                inputId="songs_years",
                label="",
                value=c(2000,2019),
                min=2000,
                max=2019,
                step=1,
                width="400px",
                height="10px",
                color="#000000",
                format=wNumbFormat(decimals=0)
              )
            ),
            a("Data Source",href="https://www.kaggle.com/datasets/paradisejoy/top-hits-spotify-from-20002019")
          ),
          box(
            plotlyOutput("songs_features_lineplot",height="400px",width="100%"),
            title="Musical Features Trend",
            status="success",
            background = "black",
            width="100%",
            height="500px"
          ),
          box(
            title="Most Common Key",
            status="success",
            background = "black",
            plotOutput("songs_key",height="400px",width="100%"),
            width="100%"
          ),
          box(
            title="Compare Two Years",
            status="success",
            background = "black",
            selectInput(
              inputId =  "songs_year1", 
              label = "Select Year:",
              choices = 2000:2019,
              selected = 2000
            ),
            plotOutput("songs_key",height="600px"),
            width="100%"
          )
        ),
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
                            
                           
                           fluidRow(
                             box(width = 12,
                                 title="Let's take a closer look",
                                 status="success",
                                 background="black",
                                 solidHeader = TRUE,
                                 
                                 column(3,
                                        
                                        selectInput("featByX", label="Feature on the X-axis",
                                                    choices = list("energy", "acousticness", "danceability",
                                                                   "liveness", "speechiness",
                                                                   "valence"),selected="liveness"),
                                        selectInput("featByY", label="Feature on the Y-axis",
                                                    choices = list("energy", "acousticness", "danceability",
                                                                   "liveness", "speechiness",
                                                                   "valence"),selected="energy")),
                                 
                                 column(9, plotlyOutput("artFeatScatter", height="400px"))
                             )
                           )
),
                  
                  tabPanel("Album Feature Comparison",
                           
                           fluidRow(                           
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
                           ))
),
                  tabPanel("Datatable",
                           fluidRow(
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
                               
                             )
                           )
)
                )),
        #User page ###########
        tabItem(tabName = "user",
                div(
                  class="top-container",
                  strong("Your Customized Profile", class="trends-h2")),

                tabsetPanel(
                  tabPanel("Top 10 Songs",
                           br(),
                           box(width=12,
                               title="Top 10 Songs",
                               status="success",
                               background = "black",
                               solidHeader = TRUE,
                               collapsible = TRUE,
                               textOutput("missTra"),
                               br(),
                               formattableOutput("topTra"),
                               style = "overflow-x: scroll;"),
                           
                           fluidRow(
                             box(width=12,
                                 status="success",
                                 #background = "black",
                                 column(3,
                                        selectInput("topTraList",
                                                    "Pick a song:",
                                                    choice="")),
                                 
                                 column(9,
                                        plotlyOutput("userTraFeat"))
                                 ))
                         ),
                  
                  tabPanel("Favorite Artists",
                           br(),
                           textOutput("missArt"),
                           br(),
                           fluidRow(
                             valueBoxOutput("favArt1"),
                             valueBoxOutput("favArt2"),
                             valueBoxOutput("favArt3")
                           ),
                           
                           fluidRow(
                             box(
                               width=12,
                               status="success",
                               background = "black",
                               wordcloud2Output("userFavGen"))
                             )
                           ),
                  
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
                )),
        ######## Reference ###########
        tabItem(tabName = "reference",
                div(
                  class="top-container",
                  strong("References", class="trends-h2")),
                box(
                  width="100%",
                  status="success",
                  background = "black",
                  tags$ol(
                    tags$li(a("ggplot2 gradient color (in Chinese) ggplot2 颜色渐变（离散颜色）设置", href="https://www.cnblogs.com/mmtinfo/p/12105987.html")),
                    tags$li(a("Font Awesome icon 4",href="https://fontawesome.com/v4/icons/")),
                    tags$li(a("Google Fonts",href="https://fonts.google.com/?category=Display"))
                  )
                  
                  
                  
                )
        )
        
      ########## end ###########
      )
      
    )
    
    
  )
)

1