library(shiny)
library(bslib)  # Bootstrap
library(tidyverse)   # lubridate included
### below packages for yearly heatmap
library(ragg)
library(showtext)

#setwd("C:/Users/pebbl/Desktop/Shiny R Practice/MyShinyWebApp")

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

# function for converting the month column in the metric dataframes to factor
transform_month_factor <- function(df) {
  df <- df %>% 
        mutate(month = factor(month, levels = month.name),
               weekday = factor(weekday, levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))
              )
  return (df)
}

# Custom CSS for title panel
custom_css <- "
.title-panel {
  background-color: #333;
  color: white;
  padding: 10px;
  font-size: 20px;
  font-weight: bold;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.icon-links {
  display: flex;
  gap: 20px;
}
.icon-links a {
  color: white;
  font-size: 1.5em;
}
"

# Define UI
ui <- page_sidebar(
  title =
    div(
      class = "title-panel",
      "Billboard Hot 100™ - Spotify Audio Features",
      div(
        class = "icon-links",
        a(href = "https://github.com/djunga", icon("github"), target = "_blank"),
        a(href = "https://www.linkedin.com/in/toram1", icon("linkedin"), target = "_blank")
      )
    ),
    # Dropdown box for selecting a choice
    sidebar = sidebar(
                selectInput("selected_feature", "Select Spotify Audio Feature:",
                choices = names(calendar_data_choices),
                selected = names(calendar_data_choices)[1])
                ),

  navset_card_tab(
    nav_panel("Features Scatterplot", plotOutput("scatterPlot")),
    nav_panel("Calendar Heatmap", plotOutput("heatmap"))
  ),
  tags$head(
    tags$style(HTML(custom_css))
  )
)


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

    max_point <- trend_data[which.max(trend_data[[selected_col]]), ]
    min_point <- trend_data[which.min(trend_data[[selected_col]]), ]
    
    ggplot(trend_data, mapping=aes(x = month, y = .data[[selected_col]], group=1)) +
      geom_point(size = 3) +
      geom_point(data=max_point, mapping=aes(x=month, y=.data[[selected_col]]), size = 6, pch=17, color="red") + 
      geom_point(data=min_point, mapping=aes(x=month, y=.data[[selected_col]]), size = 6, pch=17, color="blue") + 
      #annotate("text", x = max_point$month, y = max_point[[selected_col]], label = "Some text") +
      geom_line(linetype = "dashed") +
      labs(title = paste0("Average ", stringr::str_to_title(input$selected_feature), " By Month"),
          x = "Month", y = paste0("Average ", stringr::str_to_title(input$selected_feature))) +
      theme_classic()
  })
  
  output$heatmap <- renderPlot({
    selected_col <- input$selected_feature
    
    df <- transform_month_factor(calendar_data_choices[[selected_col]])
    ggplot(data = df, aes(weekday, -week, fill = pcat)) +
      geom_tile(colour = "white", size = .4)  + 
      geom_text(aes(label = day, colour = text_col), size = 2.5) +
      guides(fill = guide_colorsteps(barwidth = 25, 
                                     barheight = .4,
                                     title.position = "top")) +
      scale_fill_manual(values = c("white", col_p(13)),
                        na.value = "grey90", drop = FALSE) +
      scale_colour_manual(values = c("black", "white"), guide = FALSE) + 
      facet_wrap(~month, nrow = 4, ncol = 3, scales = "free") +
      labs(title = paste0("Average ", stringr::str_to_title(selected_col), " Per Week"), 
           subtitle = "Billboard 100, 2023",
           caption = "Data: Spotify Developer API",
           fill = paste0("avg ", selected_col)) +
      theme_calendar()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
