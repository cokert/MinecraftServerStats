library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(googleVis)

applyFilter <- function(data, dates, users = NULL, assailants=NULL)
{
  #convert inputs to posixct
  startd <- as.POSIXct(dates[1])
  stopd <- as.POSIXct(dates[2])
  
  #filter users and date range
  d<-data
  if (!is.null(users))
  {
    d<-filter(d, usr %in% users)
  }
  if (!is.null(assailants))
  {
    d <- filter(d, assailant %in% assailants)
  }
  if (is.null(d$datetime))
  {
    d<-filter(d, joined >= startd & joined <= stopd)
  }
  else
  {
    d<-filter(d, datetime>=startd & datetime<=stopd)
  }
  
  d
}

shinyServer(function(input, output) {
  
  ##
  ## playtimePlot
  ##
  output$playtimePlot <- renderPlot({
    
    d <- applyFilter(playtime, input$dates, input$users)
    
    #get cumulative time played
    d <- d %>% 
      group_by(usr) %>% 
      arrange(left) %>% 
      mutate(cumtime = cumsum(as.integer(sessiontime)), cumtimeh = cumsum(as.numeric(sessiontime, units="hours")))
    
    ggplot(d, aes(left, cumtimeh, col=usr)) + 
      facet_grid(.~usr) + 
      geom_point() + 
      theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 1)) +
      labs(x="", y="") + ggtitle("Cumulative time played (hours)")
  })
  
  ##
  ## playTable
  ##
  output$playTable <- renderDataTable({
    d<- applyFilter(playtime, input$dates, input$users)
    d$sessiontime<-as.numeric(d$sessiontime, units="hours")
    d
  })
  
  ##
  ## cumDeaths
  ##
  output$cumDeaths <- renderPlot({
    d<-applyFilter(deaths, input$dates, input$users, input$assailants)
    
    d <- d %>% group_by(usr) %>% mutate(d1=1, cdeaths=cumsum(d1), d1=NULL)
    
    print(ggplot(d, aes(as.POSIXct(datetime), cdeaths, col=assailant)) + 
            facet_grid(.~usr) + 
            geom_point() +
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
            labs(x="",y=""), ggtitle="Cumulative deaths")
  })
  
  ##
  ## deathBars
  ##
  output$deathBars <- renderGvis({
    d<-applyFilter(deaths, input$dates, input$users, input$assailants)
    
    #total deaths
    #print(barplot(table(d$usr), las=2))
    d <- d %>% group_by(usr) %>% summarize(Deaths=n())
    return(gvisColumnChart(d, "usr", "Deaths", options=list(height="600px")))
  })
  
  ##
  ## deathContingencyTable
  ##
  output$deathContingencyTable <- renderTable({ 
    
    d<-applyFilter(deaths, input$dates, input$users, input$assailants)
    deathTable<- d %>% group_by(usr,assailant) %>% summarise(times=n()) %>% spread(assailant, times, fill=0)
    
    cbind(
      rbind(deathTable, c("Total", colSums(deathTable[,-1]))), 
      Total=c(rowSums(deathTable[,-1]), sum(deathTable[,-1])))
    })
  
  ##
  ## deathsFirstsTable
  ##
  output$deathsFirstsTable <- renderDataTable({
    d <- applyFilter(deaths, input$dates, input$users, assailants = input$assailants)
    d <- d %>% group_by(assailant) %>% arrange(datetime) %>% slice(1)
    d[order(d$datetime),]
  })
  
  ##
  ## deathsFullTable
  output$deathsFullTable <- renderDataTable({
    applyFilter(deaths, input$dates, input$users, input$assailants)
  })
  
  ##
  ## achievementsBarPlot
  ##
  output$achievementsBarPlot <- renderPlot({
    d<-applyFilter(achievements, input$dates, input$users)
    d<-d %>% group_by(usr) %>% summarise(count=n())
    
    ggplot(d, aes(usr, count, fill=usr)) +
            geom_bar(stat="identity")
  })
  
  ##
  ## achievementsFirstsTable
  ##
  output$achievementsFirstsTable <- renderDataTable({
    d <- applyFilter(achievements, input$dates, input$users)
    d <- d %>% group_by(achievement) %>% arrange(datetime) %>% slice(1)
    d[order(d$datetime),]
  })
  
  ##
  ## Achievements
  ##
  output$achievements <- renderDataTable({
    applyFilter(achievements, input$dates, input$users)
  }, options = list(pageLength=50))
  
  ##
  ## ChatLog
  ##
  output$ChatLog <- renderDataTable({
    applyFilter(chatLog, input$dates)
  }, options = list(pageLength=50))
  
  ##
  ## FullLog
  ##
  output$FullLog <- renderDataTable({
    applyFilter(logContents, input$dates)
  }, options = list(pageLength=50))
  
})