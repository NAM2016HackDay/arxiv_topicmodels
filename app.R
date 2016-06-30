

library(shiny)
library(LDAvis)

load("ldavis.RData")
load("topics.RData")

server <- function(input, output) {
  output$myChart <- renderVis(LDAvis.json)
  
  output$myTable <- renderDataTable(output_data)
}

ui <- fluidPage(
  headerPanel("Topic Modelling astro-ph"),

  tabsetPanel(
    tabPanel("Introduction",
             br(),
             p("Topic modelling of all abstracts from astro-ph since the 1st of May, 2016, using Latent Dirichlet Allocation (LDA)."),
             br(),
             h3("Instructions:"),
             p("1. Click the ldaVis tab above to view the content of the topics, and their projected distribution in two dimensions through Principal Components Analysis (PCA)."),
             p("2. Set the relevance metric slider in the top right to 0.6 to show the most representative terms in each topic."),
             p("3. Click the Data tab to view a table of the underlying data. Each topic corresponds to the numbers in the visualisation. Clcik the heading titles to sort. You can find a particular paper using the search bar at the top right."),
             br(),
             em("Developed by Christopher Lovell at the National Astronomy Meeting 2016, Nottingham"),
             img(src = "NAM2016.png", height = 40),
             img(src = "RASLogo.png", height = 40)),
    tabPanel("ldaVis",visOutput('myChart')),
    tabPanel("Data", dataTableOutput('myTable'))
  )
)

shinyApp(ui = ui, server = server)
