
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

# setup working dir
setwd('C:\\ISB\\TextAnalysis\\TAProjectShinnyApp\\TAProjectShinnyApp');  getwd()

# Define server logic required to build a language model  and plotting word clouds and co-occurrence graphs.
server <- function(input, output) {
  
  
  
  
  Dataset <- reactive({
    if (is.null(input$file)) { return(NULL) }
    else{
      Data <- readLines(input$file$datapath)
      #ud_model_english <- udpipe_download_model(language = "english")
      #nokia = readLines('https://raw.githubusercontent.com/sudhir-voleti/sample-data-sets/master/text%20analysis%20data/amazon%20nokia%20lumia%20reviews.txt')
      payLoad = Data
      payLoadDoc =  text.clean(payLoad, remove_numbers=FALSE)
      
      str(payLoadDoc)
      english_model = udpipe_load_model("C:\\ISB\\TextAnalysis\\TABAAssignment\\TABAAssignmentShinyApp\\english-ewt-ud-2.4-190531.udpipe")
      x <- udpipe_annotate(english_model, payLoadDoc) #%>% as.data.frame() %>% head()
      x <- as.data.frame(x)
      
      return(x)
    }
  })
  
  
  output$corelation_Graphs <- renderPlot({
    
    posStr <- c("ADJ","NOUN","PROPN","ADV","VERB")
    posStrSeleted <- posStr[c(input$ADJ,input$NOUN,input$PROPN,input$ADV,input$VERB)]
    print(posStrSeleted)
    
    x <- select(Dataset(),-c("sentence"))
    
    # Sentence Co-occurrences for nouns or adj only
    data_cooc <- cooccurrence(     # try `?cooccurrence` for parm options
      x = subset(head(x,100), upos %in% posStrSeleted), 
      term = "lemma", 
      group = c("doc_id", "paragraph_id", "sentence_id"))  # 0.02 secs
    str(data_cooc)
    #head(data_cooc)
    print('reached corelationGraphs')
    
    wordnetwork <- head(data_cooc, 50)
    nrow(data_cooc)
    nrow(wordnetwork)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
    print('reached wordnetwork')
    
    ggraph(wordnetwork, layout = "fr") +  
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none") +
      
      labs(title = "Cooccurrences within 3 words distance", subtitle = posStrSeleted)
    
    
  })
  
  
  #get top 100 rows without sentence colm
  output$udpipe_tag_parsing_Out = renderTable({
    x <- select(Dataset(),-starts_with("sentence"))
    head(x,100)
  })
  
  
  # Downloadable as csv
  output$udpipe_tag_parsing_100rows_Output <- downloadHandler(filename = function() {
    paste('udpipe_tag_parsing_100rows_Output_.csv', sep=',')
  },
  content = function(file) {
    print("in download")
    write.csv(Dataset(), file)
  },contentType = 'text/csv')
  
  #plot wordcloud of nouns
  output$noun_Cloud <- renderPlot({
    all_nouns_ = Dataset() %>% subset(., upos %in% "NOUN"); #all_nouns$token[1:20]
    print("all nouns filtered")
    top_nouns_ = txt_freq(all_nouns_$lemma)
    #head(top_nouns$key, 20)
    
    wordcloud(words = top_nouns_$key, 
              freq = top_nouns_$freq, 
              min.freq = 1, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
    
  })
  
  #plot wordcloud of verbs
  output$verb_Cloud <- renderPlot({
    all_verbs_ = Dataset() %>% subset(., upos %in% "VERB") 
    print("all verbs filtered")
    top_verbs_ = txt_freq(all_verbs_$lemma)
    #head(top_verbs$key, 20)
    
    
    wordcloud(words = top_verbs_$key, 
              freq = top_verbs_$freq, 
              min.freq = 1, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
    
  })
  
  
  #reactiviely plot cooccurance graphs
  output$plotCorelationGraphsReactively <- reactive({
    print("reached plotCorelationGraphsReactively")
    
    
    posStr <- c("ADJ","NOUN","PROPN","ADV","VERB")
    # Accessing posStr vector elements using logical indexing.
    posStrSeleted <- posStr[c(input$ADJ,input$NOUN,input$PROPN,input$ADV,input$VERB)]
    print(posStrSeleted)
    
  })
  
  
  text.clean = function(x,                    # x=text_corpus
                        remove_numbers=TRUE, 	    # whether to drop numbers? Default is TRUE	
                        remove_stopwords=TRUE)	    # whether to drop stopwords? Default is TRUE
    
  { library(tm)
    print("Payload is being cleaned")
    regExpspl = "^[^<>{}\"/|;:.,~!?@#$%^=&*\\]\\\\()\\[¿§«»ω⊙¤°℃℉€¥£¢¡®©0-9_+]*$";
    
    print(length(x))
    print('payload used')
    x  =  gsub("<.*?>", " ", x,ignore.case = T)               # regex for removing HTML tags
    
    # print(x)
    x  =  stripWhitespace(x)                  # removing white space
    x  =  iconv(x, "latin1", "ASCII", sub="") # Keep only ASCII characters
    x  =  gsub("[^[:alnum:]]", " ", x,ignore.case = T)        # keep only alpha numeric 
    x  =  tolower(x)                          # convert to lower case characters
    
    x  = iconv(x, from = 'UTF-8', to = 'ASCII//TRANSLIT')
    x = str_replace_all(x, "[^[:alnum:]]", " ")
    x  =  gsub(regExpspl, "", x,ignore.case = T)
    x = str_replace_all(x, regExpspl, "")
    
    
    print(x)
    print(length(x))
    
    
    return(x) }  # func ends
  
  
  
}


