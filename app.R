library(shiny)
library(bslib)  # Bootstrap
library(tidyverse)   # lubridate included
### below packages for yearly heatmap
library(ragg)
library(showtext)

#data <- read.csv("audio_features_calendar.csv")
trend_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/avg_trends.csv")
trend_data <- trend_data %>%
  mutate(month = factor(month, levels = month.name))


energy_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/energy_calendar.csv")
valence_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/valence_calendar.csv")
loudness_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/loudness_calendar.csv")
speechiness_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/speechiness_calendar.csv")
acousticness_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/acousticness_calendar.csv")
instrumentalness_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/instrumentalness_calendar.csv")
liveness_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/liveness_calendar.csv")
tempo_data <- read.csv("https://raw.githubusercontent.com/djunga/BillboardScrape/main/tempo_calendar.csv")

calendar_data_choices <- list(
  energy = energy_data,
  valence = valence_data,
  loudness = loudness_data,
  speechiness = speechiness_data,
  acousticness = acousticness_data,
  instrumentalness = instrumentalness_data,
  liveness = liveness_data,
  tempo = tempo_data
)


metric_choices <- list(
  energy = c("avg_energy", energy_data),
  valence = c("avg_valence", valence_data),
  loudness = c("avg_loudness", loudness_data),
  speechiness = c("avg_speechiness", speechiness_data),
  acousticness = c("avg_acousticness", acousticness_data),
  instrumentalness = c("avg_instrumentalness", instrumentalness_data),
  liveness = c("avg_liveness", liveness_data),
  tempo = c("avg_tempo", tempo_data)
)

# Define UI
ui <- page_sidebar(
  title = "Billboard - Spotify Audio Features Dashboard",

    # Dropdown box for selecting a choice
    sidebar = sidebar(
                selectInput("selected_feature", "Select variable for Y-axis:",
                choices = names(calendar_data_choices),
                selected = names(calendar_data_choices)[1])
                ),

  navset_card_tab(
    nav_panel("Features Scatterplot", plotOutput("scatterPlot")),
    nav_panel("Calendar", plotOutput("heatmap"))
  ),
)

# ui <- fluidPage(
#   titlePanel = "Billboard - Spotify Audio Features Dashboard", 
#   sidebarLayout(
#     sidebarPanel(
#     # Dropdown box for selecting a choice
#     selectInput("selected_feature", "Select variable for Y-axis:",
#                 choices = names(calendar_data_choices), 
#                 selected = names(calendar_data_choices)[1]),
#   
#     ),
#   navset_card_tab(
#     nav_panel("Features Scatterplot", plotOutput("scatterPlot")),
#     nav_panel("Calendar", plotOutput("heatmap"))
#   ),
#   ),
# )



# color ramp
pubu <- RColorBrewer::brewer.pal(9, "BuPu")
col_p <- colorRampPalette(pubu)

theme_calendar <- function(){
  
  f = "sans"
  
  theme(aspect.ratio = 1/2,
        
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(family = f),
        
        panel.grid = element_blank(),
        panel.background = element_blank(),
        
        strip.background = element_blank(),
        strip.text = element_text(family = f, face = "bold", size = 15),
        
        legend.position = "top",
        legend.text = element_text(family = f, hjust = .5),
        legend.title = element_text(family = f, size = 9, hjust = 1),
        
        plot.caption =  element_text(family = f, hjust = 1, size = 8),
        panel.border = element_rect(colour = "grey", fill=NA, size=1),
        plot.title = element_text(family = f, hjust = .5, size = 26, 
                                  face = "bold", 
                                  margin = margin(0,0,0.5,0, unit = "cm")),
        plot.subtitle = element_text(family = f, hjust = .5, size = 16)
  )
}

# Define server logic
server <- function(input, output) {
  output$scatterPlot <- renderPlot({
    selected_col <- paste0("avg_", input$selected_feature)
    ggplot(trend_data, mapping=aes(x = month, y = .data[[selected_col]])) +
      geom_point(size = 3) +
      labs(x = "Month", y = input$selected_col) +
      theme_minimal()
  })
  
  output$heatmap <- renderPlot({
    selected_col <- input$selected_feature
    ggplot(data = calendar_data_choices[[selected_col]], aes(weekday, -week, fill = pcat)) +
      geom_tile(colour = "white", size = .4)  + 
      geom_text(aes(label = day, colour = text_col), size = 2.5) +
      guides(fill = guide_colorsteps(barwidth = 25, 
                                     barheight = .4,
                                     title.position = "top")) +
      scale_fill_manual(values = c("white", col_p(13)),
                        na.value = "grey90", drop = FALSE) +
      scale_colour_manual(values = c("black", "white"), guide = FALSE) + 
      facet_wrap(~month, nrow = 4, ncol = 3, scales = "free") +
      labs(title = "Average Energy Per Week", 
           subtitle = "Billboard 100, 2023",
           caption = "Data: Spotify",
           fill = "avg energy") +
      theme_calendar()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
