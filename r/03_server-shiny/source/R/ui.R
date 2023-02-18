${{VAR_COPYRIGHT_HEADER}}

ui <- tagList(
  navbarPage(
    "Project Init - ${{VAR_PROJECT_NAME}}",
    tabPanel("Main",
      sidebarPanel(
        h4("Project Init Example Project: "),
        br(),
        h5("Name: ", tags$b("${{VAR_PROJECT_NAME}}")),
        br(),
        h5("Description: ", tags$b("${{VAR_PROJECT_DESCRIPTION}}")),
        br(),
        h5("Provided by: ", tags$b("${{VAR_PROJECT_ORGANISATION_NAME}}")),
        br(),
        h5("E-Mail: ", tags$b("${{VAR_PROJECT_ORGANISATION_EMAIL}}")),
        br(), br(),
        h5("This is an example side bar panel."),
        h5("Enter a comment about this page."),
        textInput("txtComment", "Comment:", placeholder="Your comment..."),
        actionButton("action1", "Action", class = "btn-primary")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Example",
            h5("${{VAR_PROJECT_SLOGAN_STRING}}")
          )
        )
      )
    ),
    tabPanel("Example Tab", module1UI("Example", "Example"))
  )
)
