
extractDeaths<-function(logContents){
  #deaths
  pat <- "\\]: (\\w*).*(Creeper|Skeleton|Zombie|Zombie Pigman|Cave Spider|Spider|Enderman|Slime|fell from a high place|swim in lava|burned to death|starved to death|Witch using magic|Ender Dragon|Shulker|blew up|fell out of the world|Ghast)$"
  deathRows<-logContents[grepl(pat, logContents$text),]
  deaths<-deathRows %>% mutate(usr=str_match(deathRows$text, pat)[,2], assailant=str_match(deathRows$text, pat)[,3], text=NULL)
  
  #rename rows to sensible things
  deaths$assailant<-gsub("fell from a high place", "gravity", deaths$assailant)
  deaths$assailant<-gsub("swim in lava", "lava", deaths$assailant)
  deaths$assailant<-gsub("burned to death", "fire", deaths$assailant)
  deaths$assailant<-gsub("starved to death", "starved (idiot)", deaths$assailant)
  deaths$assailant<-gsub("Witch using magic", "witch", deaths$assailant)
  
  deaths
}