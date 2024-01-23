# Tidy Tudesday 2024-01-02: Bring your own data from 2023

# Load required packages -------------------------------------------------------
library(ggplot2)                # plotting
library(dplyr)                  # data manipulation
library(colorspace)             # transparent colours
library(ggtext)                 # element_markdown for subtitle formatting
library(multipanelfigure)       # arrange multiple plots in a single figure

# Load and prepare data --------------------------------------------------------

## Paths relative to project root
dir_path <- dir_path <- "2024/2024-01-02-bring-your-own-data/"
quakes_path <- paste0(dir_path, "groningen-earthquakes-2023.csv")
outline_path <- paste0(dir_path, "groningen-field-outline.csv")

## Earthquake catalog
quakes <- readr::read_csv(file = quakes_path)

quakes <- quakes %>%
  mutate(
    Easting = location_X / 1000,
    Northing = location_Y / 1000,
    date = lubridate::as_date(date),
    time = lubridate::hms(time),
    datetime = date + time
  )

## Field outline
outline <- readr::read_csv(file = outline_path)

outline <- outline %>% mutate(
  X = X / 1000,
  Y = Y / 1000
)

# Construct individual plots ---------------------------------------------------

transparent_orange <- adjust_transparency("darkorange", alpha = 0.7)
title_string <- "Earthquakes in Groningen during 2023"
subtitle_string <- '__TidyTuesday__ 2024-01-02   ||   __Data:__ KNMI   ||   __Plot:__ @zakvarty <br><br>'

p1 <- ggplot(data = quakes, aes(x = Easting, y = Northing)) +
  geom_polygon(data = outline, aes(x = X, y = Y)) +
  geom_point(aes(size = mag), col = transparent_orange) +
  xlab("Easting (km)") +
  ylab("Northing (km)") +
  ggtitle(title_string, subtitle_string) +
  scale_size_continuous(name = "Magnitude") +
  guides(
    size = guide_legend(
      title.position = "top",
      label.position = "bottom",
      title.hjust = 1)) +
  coord_fixed() +
  theme_minimal() +
  theme(
    legend.key = element_rect(fill = "grey20", colour = "grey20"),
    legend.position = c(0.9,0.9),
    legend.direction = "horizontal",
    plot.title.position = "plot",
    plot.subtitle = element_markdown(size = 11, hjust = 0.5),
    plot.title = element_text(size = 21, hjust = 0.5),
    axis.text = element_text(size = 11))
p1

p2 <- ggplot(data = quakes) +
    geom_segment(
      aes(x = datetime, xend = datetime, y = 0, yend = mag),
      colour = "darkorange",
      lwd = 0.6) +
    xlab("") +
    ylab("Magnitude") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 11),
      axis.text.x = element_text(face = "bold"))
p2

# Combine into single figure ---------------------------------------------------

figure <- multi_panel_figure(columns = 7, rows = 5, panel_label_type = "none")

figure %<>%
  fill_panel(p1, row = 1:4, column = 1:7) %<>%
  fill_panel(p2, row = 5, column = 2:6)

figure_path <- paste0(dir_path, "2024-01-02_bring-your-own-data.png")
save_multi_panel_figure(figure, filename = figure_path)
