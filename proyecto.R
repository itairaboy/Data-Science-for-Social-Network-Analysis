# 
# Data Science for Social Network Analysis
# Entrega 1
# Grupo 5
# Hugo Gebrie - Jorge Lira - Itai Raboy
#
# Setup -------------------------------------------------------------------

library(lattice)
library(igraph)
library(tm)
library(twitteR)
library(rgexf)
library(tidyverse)
library(graphTweets)

# Twitter oauth
api_key <- "TOshp3u6mh579Sc0vSRDjaH8C"
api_secret <- "l21zwJaNNr1AhVo5vizHM2Q49oqg0Ifvw0iJFY59eUVLV8JKrp"
access_token <- "3346131345-A4oLaqju3Qp8G1YEKEOqmp7WGydVaIBo0Qqwa49"
access_token_secret <- "pAy9QdtzU0EvJt1mBmM9qYykyP0FmB9bCsk0YG36vMuMk"

setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)


# Data --------------------------------------------------------------------

# Obtener tweets de COVID-19
tweets <-
  searchTwitter("#Covid-19",
                n = 3000,
                lang = "es",
                geocode = "-33.393043,-70.579348,19km")

# Convertir en DF
tw_df <- twListToDF(tweets)

# Cada user es un nodo
nodes <-
  getNodes(
    edges,
    source = "source",
    target = "target",
    "favorited",
    "retweetCount",
    "longitude",
    "latitude"
  )

# Cada tweet es una arista, dirigida quien es el RT ej: @user #Covid-19
edges <-
  getEdges(
    tw_df,
    "text",
    "screenName",
    str.length = NULL,
    "favorited",
    "retweetCount",
    "longitude",
    "latitude"
  )

# Crear grafo
graph <- graph.data.frame(edges[, 1:2], directed = TRUE, vertices = nodes)

# Guardar grafo
write.graph(graph, "test2.graphml", format = "graphml")
