
# set image urls -- for ease, I'm calling them here
top_right <- "./Indian_School_of_Business,_Hyderabad_Logo.png"
top_left <- "./UDPipeImage.jpg"



if (!require(shiny)) {install.packages('shiny')}
if (!require(udpipe)){install.packages("udpipe")}

suppressPackageStartupMessages({
  if (!require(udpipe)){install.packages("udpipe")}
  if (!require(textrank)){install.packages("textrank")}
  if (!require(lattice)){install.packages("lattice")}
  if (!require(igraph)){install.packages("igraph")}
  if (!require(ggraph)){install.packages("ggraph")}
  if (!require(wordcloud)){install.packages("wordcloud")}
  if (!require(dplyr)){install.packages("dplyr")}
  if (!require(dplyr)){install.packages("shinyWidgets")}
  
  
  library(textrank)
  library(lattice)
  library(igraph)
  library(ggraph)
  library(ggplot2)
  library(wordcloud)
  library(stringr)
  library(dplyr)
})

library(udpipe)
library(shiny)
require(stringr)
library(wordcloud)
install.packages("shinyWidgets")
library(shinyWidgets)

# setup working dir
setwd('C:\\ISB\\TextAnalysis\\TAProjectShinnyApp\\TAProjectShinnyApp');  getwd()



# Define UI for application that renders annotation table and draws a wordclouds and cooccurances
ui <- fluidPage(
  
  tags$h2("UDPIPE based Annotation App"),
  setBackgroundImage(src = "UDPipeImage.jpg"),
  
  # Application title
  titlePanel("TABA Project"),
  
  
  
  
  # Show a plot of the generated distribution
  mainPanel(
    
    tabsetPanel(type = "tabs",
                
                
                tabPanel("A: File Upload",           
                         fileInput("file", "Upload data (txt file)"),
                p("APP Description:"),br(),
                p("
                  This App uses udpipe library to generate Parts of speech annotation based on English Model.
                  Fucntionality is as described."),p("
                  Use Tab A to Upload any text file, in english, using standard upload functionality."),br(),p("

                  Use Tab B to intiate annotation using udpipe librabry based on English language Model. This takes a few seconds for processing. "),p("
                  After the process, we can view table of annotated documents as table with first 100 rows. "),p("
                  U can download the actual full file using the download button after the table is rendered."),br(),p("

                  Use Tab C to view the noud and verb wordclouds on the text corpus uploaded."),br(),p("

                  Use Tab D to Select list of Universal part-of-speech tags (upos) using check box for plotting co-occurrences. "),p("
                  and press List of upos required in app – "),p("
                  adjective (ADJ)"),p("
                  noun(NOUN)"),p("
                  proper noun (PROPN)"),p("
                  adverb (ADV)"),p("
                  verb (VERB)"),p("
                  Note: Default selection is adjective (ADJ), noun (NOUN), proper noun (PROPN). "),p("
                   Drop sentence column from the data frame. Use dataTableOutput function for displaying the output in shiny. Show only about a 100 rows of the annotated DF in the app and give user an option to download the full file as a .csv."),p("
                  3-	Third tab should display two wordclouds, one for all the nouns in the corpus and another for all the verbs in the corpus"),p("
                  4-	Fourth tab should display a plot of top-30 co-occurrences at document level using a network plot as mentioned in point C.  "),p("
                  ")),
                
                tabPanel("B: English Model Output",
                         p("English language model based annotation will populate here."),
                         br(),
                         # Button
                         downloadButton(outputId = 'udpipe_tag_parsing_100rows_Output' ,label = "Download",class = NULL),
                         br(),
                         tableOutput('udpipe_tag_parsing_Out')),
                tabPanel("C: Get WordClouds",p('Noun Cloud'), plotOutput('noun_Cloud'), br(), 
                         p('Verb Cloud'),br(),
                         plotOutput('verb_Cloud')),
                
                
                tabPanel("D: top-30 co-occurrences",
                         checkboxInput("ADJ", 'adjective (ADJ)', value = TRUE, width = NULL),
                         checkboxInput("NOUN", 'noun(NOUN)', value = TRUE, width = NULL),
                         checkboxInput("PROPN", 'proper noun (PROPN)', value = TRUE, width = NULL),
                         checkboxInput("ADV", 'adverb (ADV)', value = FALSE, width = NULL),
                         checkboxInput("VERB", 'verb (VERB)', value = FALSE, width = NULL),br(),
                         p('corelation Graphs'),br(),submitButton("Submit"),
                         plotOutput('corelation_Graphs')
                )
                
                
                
                
                
                
                
                
                
    ) # end of tabsetPanel
  )#main panel 
)
