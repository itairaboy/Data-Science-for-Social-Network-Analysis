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
library(lubridate)

# Twitter oauth
api_key <- "TOshp3u6mh579Sc0vSRDjaH8C"
api_secret <- "l21zwJaNNr1AhVo5vizHM2Q49oqg0Ifvw0iJFY59eUVLV8JKrp"
access_token <- "3346131345-A4oLaqju3Qp8G1YEKEOqmp7WGydVaIBo0Qqwa49"
access_token_secret <- "pAy9QdtzU0EvJt1mBmM9qYykyP0FmB9bCsk0YG36vMuMk"

setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)


# Data --------------------------------------------------------------------

# Past tweets
files <- list.files(path = "data", pattern = "\\.csv$", full.names = TRUE)

past_tweets <- map_df(files,
                      read_csv,
                      col_types = cols(
                        text = col_character(),
                        favorited = col_logical(),
                        favoriteCount = col_double(),
                        replyToSN = col_character(),
                        created = col_datetime(format = ""),
                        truncated = col_logical(),
                        replyToSID = col_double(),
                        id = col_double(),
                        replyToUID = col_double(),
                        statusSource = col_character(),
                        screenName = col_character(),
                        retweetCount = col_double(),
                        isRetweet = col_logical(),
                        retweeted = col_logical(),
                        longitude = col_double(),
                        latitude = col_double()
                      ))

# Obtener tweets de COVID-19 de hoy
tweets <-
  searchTwitter("#Covid-19",
                n = 3000,
                lang = "es",
                geocode = "-33.4569397,-70.6482697,22km")

# Convertir en DF
present_tweets <- twListToDF(tweets)

# Guardar nuevos tweets
present_tweets %>% 
  write_csv(paste0("data/", str_remove_all(today(), "-"), "_covid19.csv"),
            na = "")

# Join past y present tweets
tw_df <- full_join(past_tweets, present_tweets)

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

# Crear grafo
graph <- graph.data.frame(edges[, 1:2], directed = TRUE, vertices = nodes)

# Guardar grafo
write.graph(graph, "entrega1.graphml", format = "graphml")

