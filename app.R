

library(shiny)
library(LDAvis)

load("ldavis.RData")

server <- function(input, output) {
  output$myChart <- renderVis(LDAvis.json)
}

ui <- fluidPage(
  headerPanel("Topic Modelling astro-ph"),
  
  
  
  tabsetPanel(
    tabPanel("Introduction",
             br(),
             p("LDA topic modelling of all abstracts from astro-ph in 2016. Click the ldaVis tab above to view the content of the topics, and their projected distribution in two dimensions using PCA."),
             br(),
             strong("NOTE: set the relevance metrix slider in the top right to 0.6 to show the most representative terms in each topic."),
             br(),
             p("Developed by Christopher Lovell at the National Astronomy Meeting 2016, Nottingham"),
             img(src = "NAM2016.png", height = 40),
             img(src = "RASLogo.png", height = 40)),
    tabPanel("ldaVis",visOutput('myChart')),
    tabPanel("this")
  )
)

shinyApp(ui = ui, server = server)
