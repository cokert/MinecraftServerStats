
extractAchievements<-function(logContents){ 
  #pattern for achievments
  pat<-"\\]: (.*) has just earned the achievement (.*)"
  #get just rows with achievements
  ach<-logContents[grepl(pat, logContents$text),]
  #extract achievements (and remove text column)
  ach<-ach %>% mutate(usr=str_match(ach$text, pat)[,2], achievement = str_match(ach$text, pat)[,3], text=NULL)
  
  ach
}