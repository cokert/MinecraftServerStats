
extractPlaytime<-function(logContents){ 
  
  #joined/left
  patJoined<-"\\]: (.*) (joined) the game"
  tJoined<-logContents[grepl(patJoined, logContents$text),]
  tJoined<-tJoined %>% mutate(usr=str_match(tJoined$text, patJoined)[,2], state = str_match(tJoined$text, patJoined)[,3], text=NULL)
  
  patLeft<-"\\]: (.*) (left) the game"
  tLeft<-logContents[grepl(patLeft, logContents$text),]
  tLeft<-tLeft %>% mutate(usr=str_match(tLeft$text, patLeft)[,2], state = str_match(tLeft$text, patLeft)[,3], text=NULL)
  t<-rbind(tJoined, tLeft)
  
  dt <- soAnswer1(t)
  
  dt <- dt %>% mutate(sessiontime=left-joined) %>% select(usr, joined, left, sessiontime)
}


soAnswer1<-function(dt) { 
  #SO question/answer here: http://stackoverflow.com/questions/35932291/reshaping-data-in-r-with-login-logout-times
  
  setDT(dt)
  
  ## order the data by user and datetime
  dt <- dt[order(usr, datetime)]
  ## add an 'order' column, which is a sequence from 1 to lenght()  
  ## for each user
  dt[, order := seq(1:.N), by=usr]
  
  ## split the left and joins
  dt_left <- dt[state == "left"]
  dt_joined <- dt[state == "joined"]
  
  ## assuming 'left' is after 'joined', shift the 'order' back for left
  dt_left[, order := order - 1]
  
  ## join user an dorder (and subsetting relevant columns) 
  ## keeping when there's a 'joined' but not a 'left'
  dt <- dt_left[, .(usr, order, datetime)][dt_joined[, .(usr, order, datetime)], on=c("usr", "order"), nomatch=NA]
  
  ## clean up temp vars
  #rm(c("dt_left", "dt_joined", "t"))
  
  ## rename columns
  setnames(dt, c("datetime", "i.datetime"), c("left", "joined"))

  dt
}