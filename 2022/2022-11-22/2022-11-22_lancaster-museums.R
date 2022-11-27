# Tidy Tuesday 2022-11-15

# Load packages ----
library(tidyverse)
library(showtext)
library(ggtext)
library(osmdata)
library(sf)

# Load data ----
museums <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-22/museums.csv')

# Load fonts ----
font_add_google(name = "Raleway", family = "raleway")
showtext_auto()
main_font <- "raleway"


# Data Wrangling ---------------------------------------------------------------

#boundary_box <- osmdata::getbb("Lancaster, UK")
lancaster_box <- matrix(
  data = c(-2.82, -2.78, 54.043, 54.065),
  nrow = 2,
  byrow = TRUE
)
rownames(lancaster_box) <- c("x","y")
colnames(lancaster_box) <- c("min", "max")

lancaster_museums <- museums %>%
  filter(between(Latitude,lancaster_box[2,1], lancaster_box[2,2])) %>%
  filter(between(Longitude, lancaster_box[1,1], lancaster_box[1,2]))

roads <- lancaster_box %>%
  opq() %>%
  add_osm_feature(key = "highway") %>%
  osmdata_sf()

lancaster_water <- lancaster_box %>%
  opq() %>%
  add_osm_feature(key = 'natural', value = 'water') %>%
  osmdata_sf()

# bounding circle for road elements -- from @nrennie Manchester plot
centre = c(long = mean(lancaster_box[1,]), lat = mean(lancaster_box[2,]))
centre_proj <-
  tibble(lat = centre["lat"], long = centre["long"]) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326)

circle <- tibble(lat = centre["lat"], long = centre["long"]) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>%
  st_transform(crs = 4277) %>%
  st_buffer(dist = 9000, nQuadSegs = 200) %>%
  st_transform(crs = 4326)

lancaster_roads <- st_intersection(circle, roads$osm_lines) %>%
  filter(!is.na(name))

# Create plot ------------------------------------------------------------------

# Colour palette
oban <- list(
  blue = "#548BA2",
  gray = "#2A4247",
  red = "#84374A",
  orange = "#C09378",
  yellow = "#917B21",
  white = "#E5EBED"
)

bg_colour <- "#282828"
point_colour <- "#FFA200"
road_colour <- "gray60"

# Helper strings
title_string <- "\n Museums of Lancaster"
subtitle_string <- "<br> **Tidy Tuesday:** 2022-11-22 || **Data:** Mapping Museums Project || **Plot:** @zakvarty"

p <- ggplot() +
  geom_sf(data = lancaster_water$osm_polygons, color = oban$blue, fill = oban$blue) +
  geom_sf(data = lancaster_roads, colour = road_colour) +
  geom_point(
    data = lancaster_museums,
    mapping = aes(
      x = Longitude,
      y = Latitude),
      colour = point_colour,
      size = 2) +
  ggtitle(
    title_string,
    subtitle_string) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = bg_colour),
    panel.background = element_rect(fill = bg_colour, colour = bg_colour),
    text = element_text(colour = oban$white, family = main_font),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(
      hjust = 0.5,
      vjust = 0.1,
      size = 24,
      face = "bold",
      colour = "#FAA613"),
    plot.subtitle = element_markdown(hjust = 0.5, vjust = -0.5,  size = 9)
  )

# Save plot ----
ggsave(
  filename = "./2022/2022-11-22/2022-11-22_lancaster-museums.png",
  plot = p,
  device = png,
  width = 6,
  height = 6,
  units = "in",
  dpi = 300)

