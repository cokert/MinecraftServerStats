loadFiles <- function(server = "", user="", pass="", timeOffset=1) {
  
  if(!dir.exists("logs")) { dir.create("logs") }
  
  if (server!=""){
    #encode user and password for going into URL
    userpass<-paste(user, ":", pass, sep="")
    
    #get files from FTP server 
    basePath<-paste("ftp://", server, "/logs/", sep="") 
    filesonserver <- unlist(strsplit(getURL(basePath, ftp.use.epsv=F, dirlistonly=T, userpwd=userpass), "\n"))
    curlCon=getCurlHandle(ftp.use.epsv=FALSE)
    filesonserver<-gsub("\r","",filesonserver)
    
    localfiles<-dir("logs")
    
    #get files on server not on local server (and always download latest.log)
    filesonserver <- c(filesonserver[!(filesonserver %in% localfiles)], "latest.log") 
    #get full path to server's files (basePath + filename), using sapply
    filesonserverfull <-sapply(basePath, paste, filesonserver, sep="")
    
    getfileFTP<-function(url,destfile, c){
      message(destfile)
      fcontents<-getBinaryURL(url, userpwd=userpass)
      writeBin(fcontents, destfile)
    }
    
    mapply(getfileFTP, 
           filesonserverfull, 
           paste("logs/", filesonserver, sep=""), 
           #curlCon)
           "NULL")
  }  
  
  #process local files
  filepaths<-file.path(getwd(), "logs", dir("logs"))
  
  #call readMCLog for each file
  filecontents<-lapply(filepaths, readMCLog)
  
  #concat list of dfs into single df and remove save messages
  logContents<-do.call(rbind,filecontents)
  logContents<-logContents[!grepl("[Server thread/INFO]: Saved the world", logContents$text, fixed=TRUE),]
  logContents<-logContents[!grepl("[Server thread/INFO]: Saving...", logContents$text, fixed=TRUE),]
  logContents<-logContents[!grepl("[Server thread/INFO]: Saving is already turned on.", logContents$text, fixed=TRUE),]
  
  #apply timeoffset
  logContents$datetime<-logContents$datetime + timeOffset * 60 * 60 #convert seconds to hours
  
  logContents
}
