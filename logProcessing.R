require(dplyr)
require(stringr)
require(data.table)
require(tidyr)
require(ggplot2)
require(RCurl)
require(lubridate)
require(config)

source("readMCLog.R")
source("loadFiles.R")
source("extractChats.R")
source("extractAchievements.R")
source("extractPlaytime.R")
source("extractDeaths.R")

conf<-config::get()
server<-conf$server
user<-conf$userName
password<-conf$password

logContents<-loadFiles(server=server, user=user, pass=password, 1)

chatLog<-extractChats(logContents)

achievements<-extractAchievements(logContents)

playtime<-extractPlaytime(logContents)

deaths<-extractDeaths(logContents)

#get overrall deaths per user
#deathOverallTotals<-data.frame(usr=deathTable$usr, deaths=rowSums(deathTable[,-1]))
#join times with deaths, then calculate deaths/hourplayed stat
#stats<-timesum%>% left_join(deathOverallTotals, copy=T)
#stats<-stats %>% mutate(deathspertime = deaths/as.integer(time, units="hours"))
