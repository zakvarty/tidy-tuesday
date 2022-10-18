# Load Packages ----
library(tidyverse)
library(showtext)


# Load Fonts ----
font_add_google(name = "Roboto Condensed", family = "roboto-condensed")
font_add_google(name = "Bungee", family = "bungee")
showtext_auto()


# Get Data ----
episodes <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-10-18/episodes.csv')
dialogue <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-10-18/stranger_things_all_dialogue.csv')

# source IMDB:
episodes$runtime <- c(47, 55, 51, 49, 52, 46, 41, 54, 48, 56,51,46, 58, 51, 45, 47, 62, 50, 50, 49, 52, 51, 59, 55, 76, 78, 77, 63, 78, 76, 75, 98, 85, 139)


## Data Wrangling ----

talking_stats <- dialogue %>%
  group_by(season, episode) %>%
  select(line) %>%
  summarise(n_lines = max(line)) %>%
  ungroup() %>%
  left_join(episodes, by = c("season", "episode")) %>%
  mutate(lpm = n_lines / runtime) %>%
  mutate(episode_index = seq_along(episode)) %>%
  mutate(season = as.factor(season)) %>%
  select(season, episode, episode_index, lpm)

season_summaries <- talking_stats %>%
  group_by(season) %>%
  summarise(
    lpm_mean = mean(lpm),
    n_episodes = max(episode),
    lpm_se = sd(lpm) / sqrt(n_episodes),
    start = min(episode_index),
    end = max(episode_index))

# Plot ----

main_font <- "bungee"
bg_colour <- "#1e0707"
st_red <-  "#e51212"


ggplot() +
  geom_point(
    data = talking_stats,
    cex = 2,
    mapping = aes(x = episode_index, y = lpm, col = season)) +
  geom_segment(
    data = season_summaries,
    lwd = 1.5,
    mapping = aes(
      x = start - 0.5,
      y = lpm_mean,
      xend = end + 0.5,
      yend = lpm_mean,
      col = as.factor(season))) +
  geom_rect(
    data = season_summaries,
    alpha = 0.2,
    mapping = aes(
      xmin = start - 0.5,
      xmax = end + 0.5,
      ymin = lpm_mean -  lpm_se,
      ymax = lpm_mean +  lpm_se,
      fill = as.factor(season))) +
  geom_rect(
    data = season_summaries,
    alpha = 0.2,
    mapping = aes(
      xmin = start - 0.5,
      xmax = end + 0.5,
      ymin = lpm_mean - 2 * lpm_se,
      ymax = lpm_mean + 2 * lpm_se,
      fill = as.factor(season))) +
  labs(
    title = "\n Stranger Things : Actions Speak Louder Than Words",
    subtitle = " Later Seasons pack in significantly more lines per minute \n\n\n",
    caption = "  Tidy Tuesday 18 Oct 2022 | Data: 8flix.com |  @zakvarty"
  ) +
  ylab("Lines per minute") +
  geom_text(aes(x = c(4.5,13,22,30), y = 11), label = paste("Season", 1:4), colour = "grey70", family = main_font, size = 5) +
  geom_text(aes(x = 16, y = 18.5), label = "{", colour = "grey70", family = "roboto-condensed", size = 50) +
  geom_text(aes(x = 8, y = 18.3), label = "Mean  ± 2 Standard Errors", colour = "grey70", family = main_font, size = 5) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x =  element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank(),
    axis.text.y =  element_text(size = 16, colour = "grey70"),
    axis.title.y = element_text(size = 16, colour = "grey70"),
    panel.grid.major.x = element_blank() ,
    panel.grid.minor.x = element_blank() ,
    panel.grid.major.y = element_line(colour = "grey30", size  = 1),
    panel.grid.minor.y = element_line(colour = "grey30", size  = 1),
    text = element_text(family = main_font, colour = "grey70"),
    plot.background = element_rect(fill = bg_colour, colour = bg_colour),
    panel.background = element_rect(fill = bg_colour, colour = bg_colour),
    plot.title.position = 'plot',
    plot.caption.position = "plot",
    plot.title = element_text(size = 22, colour = st_red),
    plot.subtitle = element_text(size = 18),
    plot.caption = element_text(hjust = 0, size = 12)
  )

# Export as 1000x1000 pixel png


