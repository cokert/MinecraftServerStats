library(shiny)

shinyUI(
  bootstrapPage(
    
    # Application title
    titlePanel("Evidence that Chad is bad at Minecraft"),
    div(style="margin-left:60px;margin-right:60px",
    sliderInput('dates',
                label = 'dates:',
                min=min(playtime$joined, na.rm=T),
                max=max(playtime$left, na.rm=T),
                value = c(min(playtime$joined, na.rm=T), 
                          max=max(playtime$left, na.rm=T)),
                width="100%")),
    tabsetPanel(
      tabPanel("Playtime",
               plotOutput("playtimePlot", height=600),
               dataTableOutput("playTable")
      ),
      tabPanel("Deaths",
               plotOutput("cumDeaths", height=600),
               htmlOutput("deathBars", height=600),
               tableOutput("deathContingencyTable"),
               h2("First deaths by assailant"),
               dataTableOutput("deathsFirstsTable"),
               h2("All deaths"),
               dataTableOutput("deathsFullTable")
      ),
      tabPanel("Filters",
               checkboxGroupInput('users', 'users:',
                                  unique(playtime$usr),
                                  selected = playtime$usr),
               checkboxGroupInput('assailants', 'assailants:',
                                  unique(deaths$assailant),
                                  selected = deaths$assailant)

      ),
      tabPanel("Achievements",
               plotOutput('achievementsBarPlot'),
               h2("First to get"),
               dataTableOutput("achievementsFirstsTable"),
               h2("All achivements"),
               dataTableOutput('achievements')
      ),
      tabPanel("Chat Log",
               dataTableOutput('ChatLog')
      ),
      tabPanel("Full Log Output",
               dataTableOutput("FullLog")
      )
    )
  )
)
