ui <- dashboardPage(

#Header--------------------------------------------------------------------
dashboardHeader(title = "CEPD DPC"),

#Sidebar-------------------------------------------------------------------
dashboardSidebar(
  sidebarMenu(
    fileInput('file1', 'All Answers Report',accept = c('text/csv','text/comma-separated-values','.csv')),
    fileInput('file2', 'Means Report',accept = c('text/csv','text/comma-separated-values','.csv')),
    actionButton("Load", "Load Files"),width = 3)
),

#Body----------------------------------------------------------------------
dashboardBody(
  tags$head(
    tags$link(
      rel = "stylesheet", 
      type = "text/css", 
      href = "radar_style.css")
  ),
  
  useShinyjs(),
  introjsUI(), 
  
  fluidRow(
    div(
      id = "box1", 
      column(
        width = 6,
        uiOutput("box1")
      )
      
      ,
      column(
        width = 6,
        uiOutput("box2")
      )

 
  ))      
  
#End Body----------------------------------------------------------------------
  ))

#mimics your environment and includes all packages needed to run shiny app on server
#rsconnect::writeManifest()