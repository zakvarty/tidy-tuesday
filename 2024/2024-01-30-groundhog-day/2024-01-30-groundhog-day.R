# Tidy Tuesday 2024-01-30: Groundhog day

# Path relative to project root -----------------------------------------------
dir_path <- file.path(".", "2024", "2024-01-30-groundhog-day")

# ------------------------------------------------------------------------------
# Load required packages -------------------------------------------------------
# ------------------------------------------------------------------------------
library(tidytuesdayR)           # loading data
library(ggplot2)                # plotting
library(dplyr)                  # data manipulation
library(maps)
library(mapdata)                # US map
library(ggimage)                # image files a plotting characters
library(ggtext)                 # element_markdown for subtitle formatting
library(camcorder)              # record process

#-------------------------------------------------------------------------------
# Load data --------------------------------------------------------------------
#-------------------------------------------------------------------------------
tues_data <- tidytuesdayR::tt_load('2024-01-30')

groundhogs <- tues_data$groundhogs
predictions <- tues_data$predictions

# ------------------------------------------------------------------------------
# Data Wrangling ---------------------------------------------------------------
# ------------------------------------------------------------------------------

## main plot ----------------------------------------

state_map <- ggplot2::map_data(map = "state")

hogs <- groundhogs %>%
  transmute(
    region = factor(stringr::str_to_lower(region)),
    latitude = latitude,
    longitude = longitude) %>%
  filter(region %in% unique(state_map$region))

## annotations ----------------------------------------
img_path <- file.path(dir_path, "groundhog.png")
transparent_img_path <- file.path(dir_path, "groundhog-transparent.png")

## Text strings -----------------------------------------
strings <- list(
  title = "Groundhog Locations in the Contiguious United States",
  sub = "Colder regions in the North and East are more likely to take part in the groundhog day tradition.",
  cap = "",
  attr = "**Tidy Tuesday:** 2024-01-30 || **Data:** groundhog-day.com || **Plot:** @zakvarty"
)

## Colour palette --------------------------------------
pal <- list(
   orange = "#F7902C",
   onyx = "#2E3532",
   light_grey = "grey95")

# ------------------------------------------------------------------------------
# Start recording --------------------------------------------------------------
# ------------------------------------------------------------------------------

gg_record(
  dir = file.path(dir_path, "recording"),
  device = "png",
  width = 7.5,
  height = 6.5,
  units = "in",
  dpi = 300
)

#-------------------------------------------------------------------------------
# Plot -------------------------------------------------------------------------
#-------------------------------------------------------------------------------

p <- ggplot() +
  geom_polygon(
    data = state_map,
    mapping = aes(x = long, y = lat, group = group),
    fill = pal$onyx,
    colour = pal$light_grey) +
  coord_fixed(1.3) +
  labs(title = strings$title, subtitle = strings$sub, caption = strings$attr) +
  zvplot::theme_zv() +
  theme(
    plot.title = element_markdown(size = 56, hjust = 0, face = "bold"),
    plot.title.position = "plot",
    plot.subtitle = element_markdown(size = 36, hjust = 0),
    plot.caption = element_markdown(size = 36, hjust = 0),
    plot.caption.position = "plot",
    axis.text = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank(),
  )

# More sensible version of plot
p1 <- p +
  geom_point(
    data = hogs,
    mapping = aes(x = longitude, y = latitude),
    colour = pal$orange,
    size = 1.7) +
  geom_image(
    mapping = aes(x = -70, y = 30),
    image = img_path,
    size = 0.3)

# more fun version of plot
p2 <- p +
  geom_image(
    data = hogs,
    mapping = aes(x = longitude, y = latitude),
    image = transparent_img_path,
    size = 0.05) +
  #ggforce::geom_circle(aes(x0 = -70, y0 = 27.5, r = 5), color = pal$onyx, fill = pal$onyx) +
  geom_image(
    mapping = aes(x = -70, y = 27.5),
    image = transparent_img_path,
    size = 0.275)

p2

#-------------------------------------------------------------------------------
# Save GIF ---------------------------------------------------------------------
#-------------------------------------------------------------------------------

out_path <- file.path(dir_path, "groundhog-day")

ggsave(
  plot = p2,
  filename = paste0(out_path, ".png"),
  device = "png",
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)

gg_playback(
  name = paste0(out_path, ".gif"),
  first_image_duration = 4,
  last_image_duration = 20,
  frame_duration = .15,
  progress = TRUE
)

