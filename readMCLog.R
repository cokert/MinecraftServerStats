
readMCLog<- function (fileName) {
  
  f<-readLines(fileName)
  #extract times
  times<-sapply(f, substring, 2,9)
  
  #get just the name component to extract date
  ss<-strsplit(fileName, "/")[[1]]
  name<-ss[length(ss)]
  
  #get date of filename (or current if filename is latest.log
  #and make vector same length as # of lines read
  if(name != "latest.log"){
    d1<-substr(name,1,10)
  } else {
    d1<-substring(now(),1,10)
  }
  dates<-rep(d1,length(f))
  
  #strip off time in lines
  f<-sapply(f, substring, 12)
  
  #paste date/time together for processing by lubridate
  dts<-paste(dates, times)
  datetme<-ymd_hms(dts)
  
  #put date and text together in a dataframe (no strings as factors)
  data.frame(datetime=datetme, text=f, row.names=NULL, stringsAsFactors = F)
}