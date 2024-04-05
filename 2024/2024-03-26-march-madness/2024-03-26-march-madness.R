# Tidy Tuesday 2024-01-30: Groundhog day

# Path relative to project root -----------------------------------------------
dir_path <- file.path(".", "2024", "2024-03-26-march-madness")

# ------------------------------------------------------------------------------
# Load required packages -------------------------------------------------------
# ------------------------------------------------------------------------------
library(tidytuesdayR)           # loading data
library(ggplot2)                # plotting
library(dplyr)                  # data manipulation
library(ggtext)                 # element_markdown for subtitle formatting
library(camcorder)              # record process

#-------------------------------------------------------------------------------
# Load data --------------------------------------------------------------------
#-------------------------------------------------------------------------------
tues_data <- tidytuesdayR::tt_load('2024-03-26')

team_results <- tues_data$`team-results`
public_picks <- tues_data$`public-picks`
rm(tues_data)

# ------------------------------------------------------------------------------
# Data Wrangling ---------------------------------------------------------------
# ------------------------------------------------------------------------------

## main plot ----------------------------------------

plot(team_results$GAMES, team_results$W + team_results$L)
hist(team_results$GAMES)
plot(sort(team_results$WINPERCENT))

## annotations ----------------------------------------

labels <- tribble(
  ~x,  ~y, ~text,
  0.00, 0.01, "0 wins",
  0.50, 0.01, "1 of 2", # (or 2 of 4)
  0.34, 0.01, "1 of 3",
  0.67, 0.01, "2 of 3",
  0.25, 0.01, "1 of 4",
  0.75, 0.01, "3 of 4",
  0.20, 0.01, "1 of 5",
  0.40, 0.01, "2 of 5",
  0.60, 0.01, "3 of 5",
  0.80, 0.01, "4 of 5"
)

comments <- data.frame(
  x = c(0.02,  0.85),
  y = c(0.225, 0.75),
  text = c(
    stringr::str_wrap("43% of teams won none of thier games", 12),
    stringr::str_wrap("No team won more than 80% of their games", 12))
)

## Text strings -----------------------------------------

strings <- list(
  title = "March Madness - Team Performance",
  subtitle = "Large jumps are explained by many teams playing (and winning) the same number of games.",
  cap = "",
  attr = "**Tidy Tuesday:** 2024-03-26 || **Data:** Nishaan Amin || **Plot:** @zakvarty",
  xlab = "Proportion of Games Won",
  ylab = "Empirical CDF"
)

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

#ggplot(data = team_results) +
#  geom_histogram(mapping = aes(x=GAMES),binwidth = 1) +
#  xlim(c(0,55)) +
#  xlab("Games Played") +
#  ylab("Number of Teams") +
#  zvplot::theme_zv() +
#  theme(
#    plot.title = element_markdown(size = 56, hjust = 0, face = "bold"),
#    plot.title.position = "plot",
#    plot.subtitle = element_markdown(size = 36, hjust = 0),
#    plot.caption = element_markdown(size = 36, hjust = 0),
#    plot.caption.position = "plot",
#    axis.text = element_text(size = 46),
#    axis.title = element_text(size = 56)
#  )

p <- ggplot(data = team_results) +
  geom_vline(
    xintercept = c(0, 1/2, (1:2)/3, (1:3)/4, (1:4)/5),
    colour = zvplot::zv_orange,
    linewidth = 1.2) +
  stat_ecdf(mapping = aes(x = W / GAMES), linewidth = 1.2) +
  xlim(c(0,1)) +
  labs(title = strings$title, subtitle = strings$subtitle) +
  ylab(strings$ylab) +
  xlab(strings$xlab) +
  geom_text(
    data = labels,
    mapping = aes(x = x, y = y, label = text),
    nudge_x = 0.02,
    angle = 270,
    size = 12,
    hjust = 1,
    colour = zvplot::zv_orange) +
  geom_text(
    data = comments,
    mapping = aes(x =  x, y = y, label = text),
    size = 12,
    hjust = 0,
    vjust = 0,
    lineheight = 0.5) +
  geom_richtext(
    mapping = aes(x = 1, y = 0.35, label = strings$attr),
    angle = 270,
    size = 9) +
  zvplot::theme_zv() +
  theme(
    plot.title = element_markdown(size = 56, hjust = 0, face = "bold"),
    plot.title.position = "plot",
    plot.subtitle = element_markdown(size = 38, hjust = 0),
    plot.caption = element_markdown(size = 38, hjust = 0),
    plot.caption.position = "plot",
    axis.text = element_text(size = 46),
    axis.title = element_text(size = 56)
  )

#-------------------------------------------------------------------------------
# Save GIF ---------------------------------------------------------------------
#-------------------------------------------------------------------------------

out_path <- file.path(dir_path, "march-madness")

ggsave(
  plot = p,
  filename = paste0(out_path, ".png"),
  device = "png",
  width = 7.5,
  height = 6.5,
  units = "in",
  dpi = 300
)

gg_playback(
  name = paste0(out_path, ".gif"),
  first_image_duration = 4,
  last_image_duration = 15,
  frame_duration = .1,
  progress = TRUE
)

