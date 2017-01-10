
extractChats<-function(logContents) {
  #lines containing text chats  
  chatLog<-logContents[grepl(": <.*?>", logContents$text),]
  chatLog$text<-gsub("[Server thread/INFO]: ", "", chatLog$text, fixed=TRUE) #strip server crap
  
  chatLog
}