# Load libraries
library(tidyverse)
library(showtext)
library(ggtext)

# Load Data
bakers <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-10-25/bakers.csv')

# Load Fonts
font_add_google(name = "Raleway", family = "raleway")
showtext_auto()

# Set hyper-paramters
N_SIMS <- 10000
N_EVAL_PTS <- 512

# Helper function
kde_left_reflect <- function(x, min, max, n_eval_pts, bw){
  eval_pts <- seq(min, max, length.out = n_eval_pts)
  x_aug <- c(x, 2 * min - x)

  distance_mat <- outer(eval_pts, x_aug, "-")
  contributions <- dnorm(distance_mat, mean = 0, sd = bw)
  values <- rowSums(contributions)

  return(values)
}

# Data Preparation

bakers_ages <- bakers$age
winners_ages <- bakers$age[bakers$series_winner == 1]
bandwidth <- density(winners_ages, from = 16, to = 80)$bw

obs_intensity <- kde_left_reflect(
  x = winners_ages,
  min = 16,
  max = 80,
  n_eval_pts = N_EVAL_PTS,
  bw = bandwidth)

sim_intensity_mat <- matrix(NA_real_, nrow = N_SIMS, ncol = N_EVAL_PTS)

for (i in 1:N_SIMS) {
  random_winner_ages <- sample(bakers_ages, 10, replace = TRUE)
  temp_intensity <- kde_left_reflect(
    x = random_winner_ages,
    min = 16,
    max = 80,
    n_eval_pts = 512,
    bw = bandwidth
  )
  sim_intensity_mat[i,] <- temp_intensity
}

# Rough version of plot in base R
plot(y = bakers$series_winner, x = bakers$age, xlim = c(16,80))
lines(x = seq(16,80, length.out = 512), y = obs_intensity)
intervals <- apply(sim_intensity_mat, 2, quantile, probs = c(0.025,0.975))
lines(x = seq(16, 80, length.out = 512), y = intervals[2,])
lines(x = seq(16, 80, length.out = 512), y = intervals[1,])

contestants <- tibble(
  age = bakers_ages,
  is_winner = bakers$series_winner
)

intensities <- tibble(
  age = seq(16,80, length.out = N_EVAL_PTS),
  observed = obs_intensity,
  lcb = intervals[1,],
  ucb = intervals[2,]
)

## Creating ggplot ----

# custom colours
bg_colour <- "#F5F5F5"
custom_pink <- "#FF69B4"
custom_pink_light <- rgb(1,0.4,0.7,0.7)
custom_grey <- "#323232"

# strings
title_text <- "Older Bakers Are No Less Likely to Win GBBO"
subtitle_text <- "The age distribution of <span style='color:#FF69B4 font-weight:bold'><b>winning bakers</b></span> is consistent with that of <span style='color:#323232' font-weight:bold>other contestants</span>."
explainer_text <- "Grey region bounds the age profile of winners \n if all contestants have an equal chance \n of victory, regardless of age."
credit_text <- "__Tidy Tuesday__ 25 Oct 2022  __|__ __Data:__ {bakeoff} package __|__ __Plot:__  @zakvarty"

# Plot theme
theme_bakeoff <- theme(
  text = element_text(family = 'raleway', face = "bold"),
  panel.grid.major.y = element_blank(),
  panel.grid.minor.y = element_blank(),
  axis.text.x = element_text(size = 12),
  axis.text.y = element_blank(),
  axis.title.y = element_markdown(face = "plain", size = 7),
  plot.title.position = 'plot',
  plot.caption.position = "plot",
  plot.title = element_text(hjust = 0, size = 18),
  plot.subtitle = element_markdown(size = 10, face = "italic"),
  plot.background = element_rect(fill = bg_colour, colour = bg_colour),
  panel.background = element_rect(fill = bg_colour, colour = bg_colour)
)


p <- ggplot(mapping = aes(x = age)) +
  geom_ribbon(data = intensities, mapping = aes(ymin = lcb, ymax = ucb)) +
  geom_line(data = intensities,
            mapping = aes(
              y = observed),
              col = custom_pink,
              lwd = 1) +
  geom_point(data = contestants,
             mapping = aes(
               x = age,
               y = 1.03 * is_winner - 0.03),
             col = rgb(0,0,0,0.8),
             pch = "|",
             cex = 3) +
  geom_label(
    aes(label = "Winners", x = 78, y = 0.99),
    size = 3,
    fill = custom_pink_light,
    family = "raleway") +
  geom_label(
    aes(label = "Others", x = 78, y = -0.04),
    size = 3,
    fill = custom_grey,
    colour = bg_colour,
    family = "raleway") +
  geom_text(
    aes(label = explainer_text, x = 58, y = 0.6),
    size = 3,
    family = "raleway") +
  labs(
    title = title_text,
    subtitle = subtitle_text,
    x = "Baker Age",
    y = credit_text) +
  theme_minimal() +
  theme_bakeoff

# Save plot
ggsave(
  filename = "2022-10-25-bake-off.png",
  plot = p,
  device = png,
  width = 6,
  height = 5,
  units = "in",
  dpi = 300)
