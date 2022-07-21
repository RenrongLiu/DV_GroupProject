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
  
    dashboardHeader(title="MusicTrend.com"),

    #################### Dashboard siderbar ####################
      dashboardSidebar(
        tags$head(includeCSS("custom.css")),
        sidebarMenu(
          class="sidebar accordion",
          menuItem("Home", tabName = "home", icon=icon("home")),
          hr(class="sidebar-hr-gradient"),
          menuItem(
            "Trends", tabName = "trend", icon=icon("chart-line"),
            menuSubItem("Songs",tabName="TrendSongs", icon=icon("music")),
            menuSubItem("Albums",tabName="TrendAlbums", icon=icon("file")),
            menuSubItem("Artists",tabName="TrendArtists", icon=icon("users"))
          ),
          menuItem(
            "Artist Analysis", tabName = "artist", icon=icon("address-card"),
             menuSubItem("Artist Summary",tabName="artSum", icon=icon("file-audio")),
             menuSubItem("Feature Summary",tabName="featSum", icon=icon("chart-bar")),
             menuSubItem("Album Comparison",tabName="albComp", icon=icon("sliders-h")),
             menuSubItem("Sample Data",tabName="sampData", icon=icon("database"))
                   ),
          menuItem(
            "User Profile", tabName = "user", icon=icon("user-circle"),
             menuSubItem("Top 10 Songs",tabName="topSong", icon=icon("headphones")),
             menuSubItem("Artists & Genres",tabName="artGen", icon=icon("users"))
                   ),
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
                    collapsed = FALSE,
                    tags$span(
                      "Spotify is one of the most popular audio streaming platforms, which includes millions of subscribers. In this project, we will focus on analyzing musical audio features and other miscellaneous data acquired from", tags$a(href="https://developer.spotify.com/", strong("Spotify API")), "which is an interface for developers to retrieve and manage Spotify data over the internet. Audio features we use include danceability, energy, valence, speechiness, liveness, acousticness, and key mode.",
                      br(),
                      br(),
                      tags$strong("Our application has three major components:  "),
                      br(),
                      br(),
                      tags$strong("Spotify Trends:"),
                      "You can explore the top artists, tracks, and albums from previous years to 2021, and comparing the musical features and key changing trends among the songs, albums, and artists. The page will provide you the overall idea of the musical feature taste transformation in the time duration.",
                      br(),
                      br(),
                      tags$strong("Artist Analysis:"),
                      " You can serch for your interested artists to see his or her image and the artists’ most common keys in the songs. To further learn your searched artist, audio feature summary will be provided with six components (danceability, energy, valence, sppechiness, liveness, and acousticness), and you can learn the artists’ songs and albums from different musical features in a radar chart. At last, this page includes the album comparision for the artist, you are welcome to choose two of the albums from your searching artist to compare the overall musical features in the songs. ",
                      br(),
                      br(),
                      tags$strong("User Profile:"),
                      " The other interactive part in our project is understanding your Spotify playlist. We need your permission to link your Spotify account, and to give your summary of the top 10 songs, top 3 singers from you listening history. Also there will be a Radar plot be provided to compare your chosen two songs. On the page of your top 3 artists, there is also a wordcloud to check your most-frequently listing genre in your listenging library."
                  )),
                  # Spotify API Intro###########
                       box(
                         width=6,
                         title="About Spotify API",
                         solidHeader = TRUE,
                         status="success",
                         background="black",
                         collapsible = TRUE,
                         collapsed = FALSE,
                         p("Technically, we using Spotify API to accesses user related data as the main data sources for our project. The Spotify’s Web API can dicover music, manage the labrary, control audio playbacks. We mainly get information such as albms, artist, tracks, and users from Spotify’s Web API. "),
                         p("In the trending part, we also use the Spotify dataset from Kaggle, which including all the top songs in recent years, and it also be captured by Spotify API. "),
                         p(tags$strong("To using our Artist Analysis and User Profile tabs to check fabulous data visualization, the following token assess procedure is needed to go through, therefore, please follow the tutorials. ")),
                         br(),
                         p("If you still have questions, you can check the following videos to learn more about Spotify API:"),
                         # put video here, following the format:
                         tags$iframe(width="450", height="280", src="https://www.youtube.com/embed/yAXoOolPvjU", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA)
                         
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
                             h5("Step 1: Go to", tags$a("https://developer.spotify.com/dashboard/"), "and login with your Spotify information"),
                             h5("Step 2: Create an app with name and description temp, then find the client ID and Client Secret"),
                             h5('Step 3: Go to \"Edit Settings\", set \"Redirect URLs\" to http://localhost:1410/.'),
                             h5("Step 4: Copy and paste the ID and Secret into the designated dialog boxes, and click validate. If a string jumps out below, it means you have successfully acquired the access token."),
                             h5("Step 5: Allow spotify to authenticate your account"),
                             h5("Now you should be good to go! Click one of the tabs above and learn more about your music")
                             # h6("Step 4: When prompted with the message are you ..., make sure to click NOT YOU and login yourself. Now you're good to go! "),
                             # verbatimTextOutput("txtout"), # generated from the server
                      )
                  ),
                  ####Research Questions and Data
                  
                    box(width=6,
                        title="Research Questions & Method of Analysis",
                        solidHeader = TRUE,
                        status="success",
                        background="black",
                        collapsible = TRUE,
                        collapsed = FALSE,
                        tags$span(
                          tags$strong("·"),"How do the most popular songs’ feature trends change over time?",
                          br(),
                          tags$strong("·"), "What are the significant musical features of my favorite artist?",
                          br(),
                          tags$strong("·"),"How do the two albums of the same artist have different musical features?",
                          br(),
                          tags$strong("·")," What is my personal taste in music?",
                          br(),
                          tags$strong("·"),"  Who is my most-frequently listening artist?",
                          br(),
                          br(),
                          br(),
                          "We are using",tags$strong(" Times Series Analysis and Text Analysis"), "in our application. We are using:",
                          tags$ul(
                            tags$li("Scatter plot"),
                            tags$li("Bar chart"),
                            tags$li("Line Chart"),
                            tags$li("Radar plot"),
                            tags$li("Spider plot"),
                            tags$li("Wordcloud"),
                            tags$li("..."),
                            br()
                            )
                          )
                        ),
                    box(width=6,
                        title="Data Resources",
                        solidHeader = TRUE,
                        status="success",
                        background="black",
                        collapsible = TRUE,
                        collapsed = FALSE,
                        tags$span(
                          "We mainly have three tabs in our appliance, the Trending tab using the Kaggle dataset and data we grab from Wikipedia. We include the data table in each tab of Trending part, and also the linking to the dataset. The musical data variable using in our application is following:",
                          tags$ul(
                          tags$li("artist: Name of the Artist"),
                          tags$li("song: Name of the Track"),
                          tags$li("year: Release Year of the track"),
                          tags$li("danceability: how suitable a track is for dancing"),
                          tags$li("energy: perceptual measure of intensity and activity"),
                          tags$li("key: Integers map to pitches using standard Pitch Class notation"),
                          tags$li("speechiness: the presence of spoken words in a track"),
                          tags$li("acousticness: binary variable whether the track is acoustic"),
                          tags$li("liveness: the presence of an audience in the recording"),
                          tags$li("instrumentalness: Predicts whether a track contains no vocals"),
                          tags$li("valence: the musical positiveness conveyed by a track")
                          ),
                          "The other two tabs( Artist Analyst and User Profile) are grabbing the dataset from Spotify API, the Artist Analyst tab have the page of you searching artist songs, which including the song ID on Spotiry and songs' musical features"
                         
                          )
                        
                    )
                  )

                ),
        
        #################### Trend page - Songs ####################
        tabItem(
          tabName = "TrendSongs",
          div(
            class="top-container",
            strong("Music Trends of Songs: Top Hits Spotify", class="trends-h2")
          ),
          box(
            title=a("Data Overview (click to visit the dataset at Kaggle.com)",href="https://www.kaggle.com/datasets/paradisejoy/top-hits-spotify-from-20002019"),
            status="success",
            background = "black",
            width="100%",
            DT::dataTableOutput("songs_table"),
            plotlyOutput("songs_overview",width="100%")
          ),
          
          box(
            title="Musical Trend",
            status="success",
            background = "black",
            width="100%",
            noUiSliderInput(
              label="Select years: ",
              inputId="songs_years",
              value=c(2000,2019),
              min=2000,
              max=2019,
              step=1,
              width="100%",
              height="10px",
              color="#000000",
              format=wNumbFormat(decimals=0)
            ),
            fluidRow(
              column(6,plotlyOutput("songs_features_lineplot",height="400px",width="100%")),
              column(6,plotOutput("songs_key",height="400px",width="100%"))
            ),
            fluidRow(
              column(6,p("")),
              column(6,p("C & G groups are the most common keys "))
            )
          )
          ,
          box(
            title="Compare Two Years",
            status="success",
            background = "black",
            width="100%",
            
            fluidRow(
              column(6,
                     selectInput(
                       inputId =  "songs_compare1", 
                       label = "Select Year 1:",
                       choices = 2000:2019,
                       selected = 2000
                     )
                     ),
              column(6,
                     selectInput(
                       inputId =  "songs_compare2", 
                       label = "Select Year 2:",
                       choices = 2000:2019,
                       selected = 2019
                     ))
            ),
            plotOutput("songs_compare",height="400px",width = "100%"),
            fluidRow(
              column(6,valueBoxOutput("songs_comparekey1",width="100%")),
              column(6,valueBoxOutput("songs_comparekey2",width="100%"))
            )
          ),
          
        ),
        #################### Trend page - Albums ####################
        tabItem(
          tabName = "TrendAlbums",
          div(
            class="top-container",
            strong("Music Trends of Albums: Top 5000 Albums of All Time", class="trends-h2")
          ),
          box(
            title=a("Data Overview (click to visit the dataset at Kaggle.com)",href="https://www.kaggle.com/datasets/lucascantu/top-5000-albums-of-all-time-spotify-features"),
            status="success",
            background = "black",
            width="100%",
            DT::dataTableOutput("albums_table"),
            plotlyOutput("albums_overview",width="100%")
          ),
          
          box(
            title="Musical Trend",
            status="success",
            background = "black",
            width="100%",
            noUiSliderInput(
              label="Select years: ",
              inputId="albums_years",
              value=c(1960,2021),
              min=1960,
              max=2021,
              step=1,
              width="100%",
              height="10px",
              color="#000000",
              format=wNumbFormat(decimals=0)
            ),
            plotlyOutput("albums_features_lineplot",height="400px",width="100%"),
            h2("Genres in these years: "),
            actionButton("album_botton","Click to Show WordCloud (May take 10 seconds)"),
            wordcloud2Output("albums_genres",height="400px",width="100%")
          ),
          box(
            title="Compare Two Years",
            status="success",
            background = "black",
            width="100%",
            
            fluidRow(
              column(6,
                     selectInput(
                       inputId =  "albums_compare1", 
                       label = "Select Year 1:",
                       choices = 1960:2021,
                       selected = 1960
                     )
              ),
              column(6,
                     selectInput(
                       inputId =  "albums_compare2", 
                       label = "Select Year 2:",
                       choices = 1960:2021,
                       selected = 2021
                     ))
            ),
            plotOutput("albums_compare",height="400px",width = "100%"),
            fluidRow(
              column(6,valueBoxOutput("albums_genres1",width="100%")),
              column(6,valueBoxOutput("albums_genres2",width="100%"))
            )
          ),
          
        ),
        # Artist page##########
        tabItem(tabName = "artSum",
                div(
                  class="top-container",
                  strong("Artist Analysis", class="trends-h2")),
                
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
                )
        ),
        
        
        
        tabItem(tabName = "featSum",
                div(
                  class="top-container",
                  strong("Artist's Feature Analysis", class="trends-h2")),
                
                box(width = "100%",
                    title="Audio Feature Summary",
                    status="success",
                    background="black",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    column(12,
                           plotOutput("artFeatSum", height = "400px"))),
                
                
                fluidRow(
                  box(width = "100%",
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
        
        
        
        tabItem(tabName = "albComp",
                div(
                  class="top-container",
                  strong("Artist's Album Comparison", class="trends-h2")),
                
                fluidRow(                           
                  box(
                    width = "100%",
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
        
        
        
        
        tabItem(tabName = "sampData",
                div(
                  class="top-container",
                  strong("Sample Artist's Feature Data", class="trends-h2")),
                
                fluidRow(
                  box(
                    width="100%",
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
        ),
                
        #User page ###########
        tabItem(tabName = "topSong",
                div(
                  class="top-container",
                  strong("Your Favorite Songs & Audio Features", class="trends-h2")),
                
                box(width="100%",
                    title="Top 10 Songs",
                    status="success",
                    background = "black",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    p(strong("Notice:"), "If you are not a frequent Spotify user, Spotify API may not have your listening history. Thus, we will replace all contents in User Profile page with Spotify's data of alltime favorites."),
                    br(),
                    formattableOutput("topTra"),
                    style = "overflow-x: scroll;"),
                
                fluidRow(
                  box(width="100%",
                      status="success",
                      background = "black",
                      title="One Song's Feature vs. Your Average Music Taste",
                      solidHeader = TRUE,
                      column(3,
                             selectInput("topTraList",
                                         "Pick a song:",
                                         choice="")),
                      
                      column(9,
                             plotlyOutput("userTraFeat"))
                  ))
        ),
        
        
        
        tabItem(tabName = "artGen",
                div(
                  class="top-container",
                  strong("Your Top 3 Artists & Favorite Genres", class="trends-h2")),
                
                br(),
                fluidRow(
                  valueBoxOutput("favArt1"),
                  valueBoxOutput("favArt2"),
                  valueBoxOutput("favArt3")
                ),
                
                fluidRow(
                  box(
                    width="100%",
                    status="success",
                    background = "black",
                    wordcloud2Output("userFavGen"))
                )
        ),
        
        
        
        #About us ############
        tabItem(tabName = "us",
                div(
                  class="top-container",
                  strong("Authors", class="trends-h2")),
                fluidRow(
                  box(
                    width = 12,
                    title = "Yikai Jin",
                    status = "primary",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    collapsed = FALSE,
                    column(width = 3,
                           img(
                             src = 'yikai_jin.jpg',
                             align = "left",
                             height = 200
                           )),
                    column(width = 9,
                           p("I am Yikai Jin from BARM, and it is nice to meet all of you in the Data Visualization class. The following is a little information about me."),
                           p("I finished my bachelor's degree in Statistics and Applied Mathematics at the University of Wisconsin- Madison in 2019. With the covid-19 coming suddenly,  I deferred my offer of BARM in the year 2020, and use one year to work as an IT consultant, and my attending projects are mainly about IT Governance and IT regulation, and also I did much research on AIOPs during the year. I pursuing my master's degree at JHU to improve my business understanding and data analytics."),
                           br(),
                           strong("Email: yjin32@jh.edu")
                           )
                  ),
                  
                  box(
                    width = 12,
                    title = "Renrong Liu",
                    status = "success",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    collapsed = FALSE,
                    column(width = 3,
                           img(
                             src = 'renrong_liu.jpg',
                             align = "left",
                             height = 200
                           )),
                    column(width = 9,
                           p("I am Renrong Liu, a full-time MS BARM student at Carey."),
                           p("My undergrad major is marketing, and I worked as an analyst in an investment consulting firm in Beijing afterward. I am interested in data visualization because I hope this course could help me learn more techniques for interactive visualizations. In my spare time, I watch TV series like GoT and HoC."),
                           br(),
                           strong("Email: rliu57@jh.edu")
                           )
                  ),
                  
                  box(
                    width = 12,
                    title = "Ruizhi Xu",
                    status = "info",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    collapsed = FALSE,
                    column(width = 3,
                           img(
                             src = 'ruizhi_xu.jpg',
                             align = "left",
                             height = 200
                           )),
                    column(width = 9,
                           p("I'm Ruizhi from MS Business Analytics and Risk Management program. The major of my undergraduate study is Business Administration, which is belonging to the management department. I used to have interns in commercial banks and portfolio management companies."),
                           p("As mentioned above, the major of my undergraduate is management-related, and I don't have any data-related courses until my graduate study. In this program, I found the data-related course quite attractive for me, I took courses, such as Data Analytics, Data Science and Business Intelligence, Big Data Machine Learning, etc. I found that I feel fulfilled when I do those data-related projects. It is also interesting to study the mechanism behind the algorithms. Although this class is not about data mining or machine learning, from my understanding, data visualization could be an indispensable component in data mining or machine learning. Before the data preprocessing, we need to do some exploratory data analysis to firgue out the possible patterns of our dataset and get a direction for our data preprocessing. After we finish the modeling and prediction part, data visualization is also important for us to present our results to others. Visual plots could be more intuitive and direct for people to understand no matter whether they have professional knowledge or not.  I have already taken a course to use Python and Tableau to do the visualization, it will be a pleasure to take a course based on R. In the Data Science course, we were taught to use ggplot to do some basic visualization and hope could learn more advanced material based on R in this class."),
                           p("Currently, I'm a full-time student at Carey, so the majority of my time is spent on my curricula. Besides, I'm the Teaching Assistant of Professor Changmin in another class. In my free time, I used to play electronic games, board games, or mahjong with my friends. Recently we found a community gym and we could play a variety of sports there, basketball is my favorite sport and I began to watch NBA when I was in primary school. The detective novel is another interest of mine, and Higashino Keigo is my favorite writer."),
                           br(),
                           strong("Email: rxu38@jh.edu")
                           )
                  ),
                  
                  box(
                    width = 12,
                    title = "Yue Pan",
                    status = "warning",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    collapsed = FALSE,
                    column(width = 3,
                           img(
                             src = 'yue_pan.jpeg',
                             align = "left",
                             height = 200
                           )),
                    column(width = 9,
                           p("I am Yue Pan from Business Analytics and Risk Management program. I majored in International Trade and Economics at Central South University, China. I am a full-time student who would love to read, travel, and vlog in my spare time. See my videos here https://www.bilibili.com/video/BV1Va41177LX?spm_id_from=333.999.0.0 "),
                           p("In my senior year, I interned in an IT consulting team at KPMG as a business consultant, during which I self-studied multiple data visualization tools, including Tableau, Qliksense, and PowerBI. Fulfilled by the sense of achievement and innovation while creating and finishing dashboards and reports, I found myself interested in data visualization. As the last stage of a data project which directly connects with users, data visualization will greatly influence the performance of the project, which means it can improve the performance of the background data processing, model construction, data mining, or other complicated algorithms and it can also jeopardize them. With the need for further, systematic knowledge of data visualization, I felt so excited to know that our program opened this course."),
                           br(),
                           strong("Email: ypan29@jh.edu")
                           )
                  ),
                  
                  box(
                    width = 12,
                    title = "Junzhe Zhu",
                    status = "danger",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    collapsed = FALSE,
                    column(width = 3,
                           img(
                             src = '635.jpg',
                             align = "left",
                             height = 200
                           )),
                    column(width = 9,
                           p("My name is Junzhe Zhu. I had my undergraduate degree from the University of California, Davis, double major in managerial economics and statistics. "),
                           p("My motivation to take this course is to learn more techniques for data visualization and better facilitate myself as a DS/DA. Building an interactive web application using RShiny is one of the topics that particularly attracts me to take this course."),
                           br(),
                           strong("Email: jzhu81@jhu.edu")
                           )
                  ))),
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
                    tags$li(a("Spotify most streamed songs by ChartMaster",href="https://chartmasters.org/spotify-most-streamed-songs/")),
                    tags$li(a("Spotify most streamed albums by ChartMaster",href="https://chartmasters.org/spotify-most-streamed-albums/?y=alltime")),
                    tags$li(a("Inserting an image to ggplot2",href="https://stackoverflow.com/questions/9917049/inserting-an-image-to-ggplot2")),
                    tags$li(a("Combining Spotify and R — An Interactive Rshiny App + Spotify Dashboard Tutorial",href="https://towardsdatascience.com/combining-spotify-and-r-an-interactive-rshiny-app-spotify-dashboard-tutorial-af48104cb6e9")),
                    tags$li(a("How to create Radar Charts in R with Plotly",href="https://plotly.com/r/radar-chart/")),
                    tags$li(a("Inserting an image to ggplot2",href="https://stackoverflow.com/questions/9917049/inserting-an-image-to-ggplot2")),
                    tags$li(a("BEAUTIFUL RADAR CHART IN R USING FMSB AND GGPLOT PACKAGES"),href="https://www.datanovia.com/en/blog/beautiful-radar-chart-in-r-using-fmsb-and-ggplot-packages/"),
                    tags$li(a("spotifyr overview"),href="https://www.rcharlie.com/spotifyr/")
                  )
                  
                  
                  
                )
        )
        
      ########## end ###########
      )
      
    )
    
    
  )
)

1