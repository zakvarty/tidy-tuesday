# Tidy Tuesday 2024-01-02: Bring your own data from 2023

# Path relative to project root -----------------------------------------------
dir_path <- "2024/2024-01-23-english-education/"

# ------------------------------------------------------------------------------
# Load required packages -------------------------------------------------------
# ------------------------------------------------------------------------------
library(tidytuesdayR)           # loading data
library(ggplot2)                # plotting
library(dplyr)                  # data manipulation
library(colorspace)             # transparent colours
library(ggtext)                 # element_markdown for subtitle formatting
library(camcorder)              # record process
library(forcats)                # working with factors

#-------------------------------------------------------------------------------
# Load data --------------------------------------------------------------------
#-------------------------------------------------------------------------------
tues_data <- tidytuesdayR::tt_load('2024-01-23')
edu <- tues_data$english_education

# ------------------------------------------------------------------------------
# Data Wrangling ---------------------------------------------------------------
# ------------------------------------------------------------------------------

## main plot ----------------------------------------
town_scores <- edu %>%
filter(stringr::str_detect(income_flag, "town")) %>%
mutate(region = as.factor(rgn11nm), income = as.factor(income_flag)) %>%
select(region, income, education_score) %>%
group_by(region, income) %>%
summarise(mean_score = mean(education_score)) %>%
ungroup() %>%
mutate(region = fct_relevel(region,
  "South West",
  "East of England",
  "South East",
  "East Midlands",
  "West Midlands",
  "Yorkshire and The Humber",
  "North East",
  "North West")) %>%
mutate(region = fct_recode(region,
  "Yorkshire and\n The Humber" = "Yorkshire and The Humber")) %>%
mutate(income = fct_relevel(income,
  "Higher deprivation towns",
  "Mid deprivation towns",
  "Lower deprivation towns")
)

## annotations ----------------------------------------

NW_values <- town_scores[town_scores$region == "North West", "mean_score"]
NW_values <- unname(unlist(NW_values))

label_df <- tibble(
  #horizontal = c(-2, 2, 5), # replace with data specific values later
  horizontal = NW_values,
  vertical = c(8.5, 8.5, 8.5),
  string = c("Higher income deprivation", "Lower", "Mid")
)

arrow_df <- tibble(
  horizontal = label_df$horizontal,
  upper = rep(8.75, nrow(label_df)),
  lower = rep(8.25, nrow(label_df))
)

## custom y-grid ----------------------------------------
vertical_grid_df <- tibble(
  x = seq(-4, 6, by = 2),
  ymin = rep(0, length(x)),
  ymax = rep(8.25, length(x))
)

## Text strings -----------------------------------------
strings <- list(
  title = "Towns in the North West have the highest attainment scores at
  all  \n income deprivation levels",
  sub = "\n  \n  Average educational attainment score for towns, by region
  and income  \n  deprivation level, England",
  cap = "Source: Office for National Statistics analysis using Longitudinal
  Education Outcomes (LEO)  \n from the Department for Education (DfE) and Index
  of Multiple Deprivation 2019 from the  \n Department for Levelling Up, Housing
  and Communities (DLUHC)",
  attr = "**Tidy Tuesday:** 2024-01-23 || **Data:** ONS || **Plot:** @zakvarty"
)

## Colour palette --------------------------------------
pal <- c(red = "#7c265a", grey = "#d3d3d3", blue = "#315f91", white = "#ffffff")

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

ggplot() +
  geom_point(
    data = town_scores,
    mapping = aes(
      x = mean_score,
      y = region,
      fill = income),
    shape = 21,
    size = 4) +
  geom_linerange(
    aes(x = 0, ymin = 0.25, ymax = 8.25),
    colour = "#8A8A8A",
    linewidth = 0.8) +
  geom_linerange(
    data = vertical_grid_df,
    mapping = aes(x = x, ymin = ymin, ymax = ymax),
    colour = "grey80",
    linewidth = 0.3) +
  labs(title = strings$title, subtitle = strings$sub, caption = strings$cap) +
  geom_text(
    data = label_df,
    mapping = aes(x = horizontal, y = vertical, label = string),
    color = "#222222",
    nudge_y = 0.5) +
  geom_segment(
    data = arrow_df,
    mapping = aes(x = horizontal, xend = horizontal, y = upper, yend = lower),
    arrow = arrow(length = unit(0.1, "inches"))
    ) +
  xlab(element_blank()) +
  ylab(strings$attr) +
  coord_cartesian(xlim = c(-4, 6), ylim = c(1.25,8.75)) +
  scale_fill_manual(values = unname(pal)) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_markdown(size = 15,
                                  hjust = 0,
                                  face = "bold",
                                  margin = margin(0,0,15,0)),
    plot.title.position = "plot",
    plot.subtitle = element_markdown(size = 14,
                                     hjust = 0,
                                     margin = margin(0,0,15,0)),
    plot.caption = element_markdown(size = 13, hjust = 0, color = "#8A8A8A"),
    plot.caption.position = "plot",
    axis.text = element_text(size = 14, colour = "#222222"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(linetype = 2),
    axis.title.y = element_markdown(colour = "grey85",margin = margin(0,10,0,0))
  )

#-------------------------------------------------------------------------------
# Save GIF ---------------------------------------------------------------------
#-------------------------------------------------------------------------------

out_path <- file.path("2024", "2024-01-23-english-education", "english-education")

ggsave(
  filename = paste0(out_path, ".png"),
  device = "png",
  width = 7.5,
  height = 6.5,
  units = "in",
  dpi = 300,
  bg = pal["white"]
)

gg_playback(
  name = paste0(out_path, ".gif"),
  first_image_duration = 4,
  last_image_duration = 20,
  frame_duration = .25,
  background = pal["white"],
  progress = TRUE
)
