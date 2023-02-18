${{VAR_COPYRIGHT_HEADER}}

library("shiny")

# Module UI function
module1UI <- function(id, label="Tab One"){
  ns <- NS(id)
  tagList(
    sidebarPanel(
      h2(tags$b("Gaussian Distribution")),
      h5("Change the parameters of the function and look at how the distribution changes."),
      h5("The standard normal distribution has an expected value of 0 and a standard deviation of 1")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Density Function",
          h4("The density function of the Gaussian distribution"),
          br(),
          sliderInput(
            ns("sliderE"),
            "Expected value:",
            min=-5,
            max=5,
            value=0,
            step=0.1,
            animate=TRUE
          ),
          sliderInput(
            ns("sliderS"),
            "Standard deviation:",
            min=0,
            max=10,
            value=1,
            step=0.1,
            animate=TRUE),
          fluidRow(
            column(
              6,
              plotOutput(
                ns("plot1"),
                brush=ns("brush")
              )
            ),
            img(
              src="normal_distribution.png",
              height=70,
              width=225
            )
          )
        )
      )
    )
  )
}

# Module server function
module1Server <- function(input, output, session){
  output$plot1 <- renderPlot({
    sigma=input$sliderS
    mi=input$sliderE
    x=seq(-7,7, length=400)
    y=(1/(sigma*sqrt(2*pi)))*exp(-0.5*(((x-mi)/sigma)^2))
    plot(
      x, y,
      type="l",
      lwd=2,
      xlim=c(-7,7),
      ylim=c(0,1),
      main="Gaussian Distribution",
      xlab="",
      ylab=""
    )
    grid(
      col="lightgray",
      lty="dotted",
      lwd=par("lwd"),
      equilogs=TRUE
    )
  })
}
