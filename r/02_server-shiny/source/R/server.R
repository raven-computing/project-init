${{VAR_COPYRIGHT_HEADER}}

server <- function(input, output){
  callModule(module1Server, "Example")
    observeEvent(input$action1, {
      if(is.na(input$txtComment) || (input$txtComment == "")){
        showModal(
          modalDialog(
            title="Missing comment!",
            "Please provide a comment.",
            fade=TRUE,
            easyClose=TRUE
          )
        )
        return()
      }
      showNotification(
        "Thank you for your comment!",
        type="message",
        duration=5
      )
    }
  )
}
