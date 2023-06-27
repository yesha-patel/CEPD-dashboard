server = function(input, output) {
  #reactive for graph  
  dataRaw <- reactive({
    if(input$Load == 0){return()}
    inFile <- input$file1
    if (is.null(inFile)){return(NULL)}
    my_data <- read.csv(inFile$datapath)
    my_data <- SubsetAA(my_data)
    my_data <- Cleanup(my_data)
    my_data
  })
  
  #reactive for download
  dataMeans <- reactive({
    if(input$Load == 0){return()}
    inFile <- input$file2
    if (is.null(inFile)){return(NULL)}
    my_data <- read.csv(inFile$datapath)
    my_data <-read.csv("Means Report.csv")
    my_data <- Means(my_data)
    my_data
  })
  
  #this section is for the letters report
  output$table1 <- renderFormattable({
    req(dataMeans())
    dataMeans <- dataMeans()
    dataMeans <- dataMeans[order(-dataMeans$"value"),]
    dataMeans <- cbind(dataMeans$experimentID,dataMeans$blockID, dataMeans$treatmentNumber, dataMeans$shortTreatmentName, dataMeans$value, dataMeans$letterGrouping)
    colnames(dataMeans) <-c("Experiment ID",'Block ID', 'Treatment #','Treatment Name', 'Value', 'Letter Grouping')
    dataMeans <- as.data.frame(dataMeans)  
    formattable(dataMeans, align=c('l','l','l','l','c','l'))
    
    }
  )
  
  #Control filters
  output$negControl <- renderUI({
    selectizeInput(
      inputId = "negControl",
      label = "Select Negative Controls",
      choices = unique(dataRaw()$"shortTreatmentName"),
      multiple = TRUE
    )
  })
  
  output$posControl <- renderUI({
    selectizeInput(
      inputId = "posControl",
      label = "Select Positive Controls",
      choices = unique(dataRaw()$"shortTreatmentName"),
      multiple = TRUE
    )
  })
  
  
  # Downloadable csv of selected dataset ----
  output$downloadMeans <- downloadHandler(
    filename = function() {
      paste(input$file2, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(dataMeans(), file, row.names = FALSE)
    }
  )
  
#Download Raw Data ------------------------------------------------------------
  #need to fix table up 
    output$downloadRaw <- downloadHandler(
    filename = function() {
      paste(input$file1, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(dataRaw(), file, row.names = FALSE)
    }
  )
  
  
  #this section is for the violin plots
  
  
  #color code positive and negative against tests
  output$Graph <- renderPlot({
    req(dataRaw())
    dataRaw <- dataRaw()
    #how do i sort here? 
    dataRaw$Control <- ifelse(dataRaw$shortTreatmentName%in%input$posControl,"Positive Control",ifelse(dataRaw$shortTreatmentName%in%input$negControl,"Negative Control","Test"))
    ggplot(dataRaw, aes(x=shortTreatmentName, y=value, fill=Control)) + 
      geom_violin(trim=FALSE)+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))+
      scale_fill_manual(values = MyColour)+
      xlab("Treatments")+
      ylab("Disease Severity")+
      guides(fill=guide_legend(title="Type"))+
      theme(plot.margin = margin(2,2,2.5,2.2, "cm")) +
      theme(panel.background = element_rect(fill = "white"))+
      theme(panel.grid.major = element_line(linetype = "dotted"))+
      theme(panel.grid.major = element_line(colour = "black"))+
      theme(text = element_text(size = 15))+
      theme(legend.position="bottom",
            legend.title=element_blank())
    
  }
  ,height = 600, width = 600
  )
  
 


#letters report UI-------------------------------------------------------------
output$box1 <- renderUI({
#box---------------------------------------------------------------------------
    div(
    style = "position: relative",
    tabBox(
      id = "box1",
      width = 400,
      height = 800,
      tabPanel(
        title = "Letters Report",
#Download button --------------------------------------------------------------      
         div(
          style = "position: absolute; left: 0.5em; bottom: 0.5em;",
          dropdown(
            downloadButton(outputId = "downloadMeans", label = "Download Means Report"),
            size = "xs",
            icon = icon("download", class = "opt"), 
            up = TRUE
          )
        ),
#Plot--------------------------------------------------------------------------  
        withSpinner(
          formattableOutput("table1"),
          type = 4,
          color = "#CC0000",
          size = 0.2
        ),

#------------------------------------------------------------------------------
      ),

)
)
})

#Violin Plots UI-------------------------------------------------------------
  output$box2 <- renderUI({
    #box---------------------------------------------------------------------------
    div(
      style = "position: relative",
      tabBox(
        id = "box2",
        width = 700,
        height = 800,
        tabPanel(
          title = "Violin Plot",
          div(style="display:inline-block;",uiOutput("negControl")),
          div(style="display:inline-block;",uiOutput("posControl")),
#Download button --------------------------------------------------------------
           div(
            style = "position: absolute; left: 0.5em; bottom: 0.5em;",
            dropdown(
              #fix download buttont to be download cvs
              downloadButton(outputId = "downloadPlot", label = "Download Raw Data"),
              size = "xs",
              icon = icon("download", class = "opt"), 
              up = TRUE
            )
          ),
#Zoom--------------------------------------------------------------------------
div(
  style = "position: absolute; right: 0.5em; bottom: 0.5em",
  conditionalPanel(
    "input.box2 == 'Violin Plot'",
    actionBttn(
      inputId = "Violin",
      icon = icon("search-plus", class = "opt"),
      style = "fill",
      color = "danger",
      size = "xs"
    )
  )
),
#Plot--------------------------------------------------------------------------  
          withSpinner(
            plotOutput("Graph", width = "100%"),
            type = 4,
            color = "#CC0000",
            size = 0.2
          ),

 #------------------------------------------------------------------------------
        )
        
      )
    )
  })
#zoomed in plot----------------------------------------------------------------
  observeEvent((input$Violin), {
    showModal(modalDialog(
      renderPlot({
        dataRaw <- dataRaw()
        dataRaw$Control <- ifelse(dataRaw$shortTreatmentName%in%input$posControl,"Positive Control",ifelse(dataRaw$shortTreatmentName%in%input$negControl,"Negative Control","Test"))
        ggplot(dataRaw, aes(x=shortTreatmentName, y=value, fill=Control, reorder(Control))) + 
          geom_violin(trim=FALSE)+
          theme(axis.text.x = element_text(angle = 45, hjust = 1))+
          scale_fill_manual(values = MyColour)+
          xlab("Treatments")+
          ylab("Disease Severity")+
          guides(fill=guide_legend(title="Type"))+
          theme(plot.margin = margin(2,2,2.5,2.2, "cm")) +
          theme(panel.background = element_rect(fill = "white"))+
          theme(panel.grid.major = element_line(linetype = "dotted"))+
          theme(panel.grid.major = element_line(colour = "black"))+
          #theme(text = element_text(size = 15))+
          theme(legend.position="bottom",
                legend.title=element_blank()) + 
          theme(
          axis.title = element_text(size = 20),
          text = element_text(size = 20),
          plot.title = element_text(size = 26)
        )
      }, height = 600),
      easyClose = TRUE,
      size = "l",
      footer = NULL
    ))
  })  
  
#end of server------------------------------------------------------------------
  }



