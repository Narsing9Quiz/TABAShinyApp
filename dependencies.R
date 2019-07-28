
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