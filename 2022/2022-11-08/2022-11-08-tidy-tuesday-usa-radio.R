# Load Packages ----------------------------------------------------------------
library(tidyverse)
library(showtext)
library(ggtext)
library(usmap)

# Load data --------------------------------------------------------------------

radio <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-08/state_stations.csv')

# Load Fonts -------------------------------------------------------------------

font_add_google(name = "Cinzel", family = "cinzel")
font_add_google(name = "Raleway", family = "raleway")
showtext_auto()

main_font <- "cinzel"
credit_font <- "raleway"

# Wrangling --------------------------------------------------------------------

usa_map <- usmap::us_map() %>%
  mutate(state = tolower(gsub("_", " ", full)))

state_licensee_counts <- radio %>%
  mutate(state = tolower(gsub("_", " ", state))) %>%
  group_by(state) %>%
  summarise(licensee_count = n_distinct(licensee))

licensee_data <- usa_map %>%
  mutate(state = tolower(gsub("_", " ", full))) %>%
  select(x, y, group, state) %>%
  group_by(state) %>%
  inner_join(state_licensee_counts, by = "state")

# Create Plot ------------------------------------------------------------------

# custom colours
bg_white <- "#FBF5F3"
low_grey <- "#D0CCD0"
high_blue <- "#274156"
text_blue <- "#000022"

# convenience strings
title_string <- "California and Texas Dominate the Airwaves"
subtitle_string <- "**Tidy Tuesday:** 2022-11-09 || **Data:** Wikipedia Radio Stations || **Plot:** @zakvarty"

# plotting code
p <- ggplot(licensee_data, mapping = aes(x = x, y = y, group = group)) +
  geom_polygon(aes(fill = licensee_count), col = bg_white) +
  scale_fill_gradient(
    low = low_grey,
    high = high_blue,
    name = "Licensee count:",
    guide = guide_colourbar(title.hjust = 0.9, title.vjust = 0.85)
    ) +
  ggtitle(title_string, subtitle_string) +
  theme_void() +
  theme(
    text = element_text(family = main_font, colour = text_blue),
    plot.title = element_text(hjust = 0.1, size = 22),
    plot.subtitle = element_markdown(
      hjust = 0.04,
      size = 10,
      family = credit_font),
    legend.position = c(0.8, 0.07),
    legend.direction = "horizontal",
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.background = element_rect(fill = bg_white),
  )

# save plot
ggsave(
  filename = "2022-11-09_usa-radio.png",
  plot = p,
  device = png,
  width = 8,
  height = 6,
  units = "in",
  dpi = 300)
