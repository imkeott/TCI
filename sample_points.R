# random points tci 
library(readr)
library(here)
library(raster)
library(rgdal)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(lubridate)
library(hrbrthemes)
library(tidyr)
#laptop
i_am("Desktop/Uni/praktikum/data/sample_points.R")
wd <- here("Desktop","Uni","praktikum","data")
setwd(wd)

# load data
#data <- read_csv("random_points2.csv",show_col_types = FALSE)
csv_files <- list.files(path = "gee_points", pattern = "*.csv", full.names = TRUE)
data <- data.frame()
for (csv_datei in csv_files) {
  daten <- read.csv(csv_datei)
  data <- rbind(data, daten)
}
# new column point id
data$pointID <- seq_along(data$system.index)
# seperate data
new_rows <- apply(data, MARGIN = 1, FUN = function(x){
  ## years to rows
  col_array <- x[2] ## array field
  col_geo   <- x[3] ##lonlat
  col_id    <- x[4] ##pointid
  
  split_array <- strsplit(col_array, "],") ## split to list
  
  ## combine lists
  new_rows <- lapply(split_array, function(y) {
    data.frame(array = y, pointID = rep(col_id, length(y)), LonLat = rep(col_geo, length(y)), stringsAsFactors = FALSE)
  })
})
df_points <- do.call(rbind, new_rows)
df_points <- do.call(rbind, df_points)
# remove brackets and lonlat character
df_points$array <- gsub("\\[|\\]", "", df_points$array)
df_points$LonLat <- gsub('\\{"type":"Point","coordinates":\\[|\\]\\}', '', df_points$LonLat)
# seperate array
#df_points2 <- within(df_points,array<-data.frame(do.call('rbind',strsplit(as.character(array),',',fixed = TRUE))))
df_points <- separate(data= df_points, col = array, into = c("TCI_detr", "TCI", "T2M", "PPT", "count", "change", "year"),sep = ",")
df_points <- separate(data= df_points, col = LonLat, into = c("Lon", "Lat"),sep = ",")
# change datatype of coulumns
df_points <- as.data.frame(sapply(df_points, function(x) as.numeric(as.character(x))))
# point id to factor
df_points$pointID <- as.factor(df_points$pointID)
################################################################################
## humidity according to Lang
################################################################################
df_points$regenfaktor <- df_points$PPT/df_points$T2M
df_points$humid <- ifelse(df_points$regenfaktor < 40, "arid",
                          ifelse(df_points$regenfaktor <60, "semiarid",
                          ifelse(df_points$regenfaktor < 100, "semihumid",
                                 ifelse(df_points$regenfaktor < 160, "humid", "perhumid"))))
################################################################################
## warm and cold 
################################################################################
# everything above mean warm, everything below cold
df_points$temp_class <- ifelse(df_points$T2M < mean(df_points$T2M), "cold","warm")

################################################################################
## wet and dry 
################################################################################
# everything above mean warm, everything below cold
df_points$ppt_class <- ifelse(df_points$PPT < mean(df_points$PPT), "dry","wet")

################################################################################
## wet, dry, warm and cold
################################################################################
# everything above mean warm, everything below cold
df_points$tp_class <- ifelse(df_points$PPT < mean(df_points$PPT) & df_points$T2M < mean(df_points$T2M), "cold_dry",
                             ifelse(df_points$PPT > mean(df_points$PPT) & df_points$T2M < mean(df_points$T2M), "cold_wet",
                                    ifelse(df_points$PPT > mean(df_points$PPT) & df_points$T2M > mean(df_points$T2M), "warm_wet","warm_dry")))


################################################################################
## plots
################################################################################
df_filter_semihumid <- df_points %>% filter(humid == "semihumid")
custom_colors <- rainbow(100) 
ggplot(df_filter_semihumid, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("semihumid")#+
  #scale_color_manual(values = custom_colors) 

df_filter_humid <- df_points %>% filter(humid == "humid")
ggplot(df_filter_humid, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("humid")

df_filter_perhumid <- df_points %>% filter(humid == "perhumid")
ggplot(df_filter_perhumid, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("perhumid")

df_filter_arid <- df_points %>% filter(humid == "arid")
ggplot(df_filter_arid, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("arid")

df_filter_semiarid <- df_points %>% filter(humid == "semiarid")
ggplot(df_filter_semiarid, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("semiarid")
  

## plot all points
ggplot(df_points, aes(x=count, y=TCI_detr, color=tp_class)) +
  geom_point(size=0.5) +
  xlab("N Pixel")+
  ylab("TCI detrended")+
  ggtitle("all")
################################################################################
## facet wrap

## humidity
ggplot(df_points, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  facet_wrap(~humid)+
  xlab("N Pixel")+
  ylab("TCI detrended")

## temp
ggplot(df_points, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  facet_wrap(~temp_class)+
  xlab("N Pixel")+
  ylab("TCI detrended")


## wet dry 
ggplot(df_points, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  facet_wrap(~ppt_class)+
  xlab("N Pixel")+
  ylab("TCI detrended")

## warm,cold,wet,dry
ggplot(df_points, aes(x=count, y=TCI_detr, color=pointID)) +
  geom_point(size=0.5, show.legend = F) +
  facet_wrap(~tp_class)+
  xlab("N Pixel")+
  ylab("TCI detrended")

