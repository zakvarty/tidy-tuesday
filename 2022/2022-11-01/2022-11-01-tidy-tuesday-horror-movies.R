library(tidyverse)
library(showtext)
library(ggtext)

# Load data
horror_movies <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-01/horror_movies.csv')

# Load Fonts
font_add_google(name = "Raleway", family = "raleway")
showtext_auto()

# Wrangling

income_statistics <- horror_movies %>%
  select(revenue, budget) %>%
  filter(budget > 0) %>%
  mutate(makes_money = revenue > 0) %>%
  mutate(makes_profit = revenue > budget) %>%
  summarise_if(is.logical, mean)

films <- horror_movies %>%
  select(title, revenue, budget) %>%
  filter(!is.na(revenue)) %>%
  filter(!is.na(budget)) %>%
  filter(budget > 0) %>%
  filter(revenue > 0) %>%
  mutate(ROI = (revenue - budget) / budget)

films[order(films$ROI,decreasing = TRUE)[1:5],]
films[order(films$budget,decreasing = TRUE)[1:5],]
films[order(films$ROI,decreasing = FALSE)[1:5],]

# Create Plot


## Text strings for clean plotting code
title_text <- "Horror Films as Investments"
subtitle_text <- "Only **21.1%**of funded horror films <span style='color:#FF5A00 font-weight:bold'><b>make any money</b></span> and only **14.1%** generate a profit."
#comment_1 <- "Larger investments see more consistent returns"
#comment_2 <- "Investing in small budget films is risky can be a bloody good investment"
#comment_3 <- "These films were stinkers ~$5M invested and ~$8K revenue"

## Axis customisation
x_breaks <- c(0, 50, 100, 150, 200)
x_labels <- c(0, "$50M", "$100M", "150M", "200M")
y_breaks <- 10^((-4):4)
y_labels <- c("x 1/10,000","x 1/1000", "x 1/100", "x 1/10", "x 1", "x 10", "x 100", "x 1000", "x 10,000")

## Plot colour pallette
bg_colour <- "#28282B"
text_colour <- "#F5F5F5"
custom_orange <- "#FF5A00"

## Construct plot
p <- ggplot(data = films, aes(x = budget / 10^6, y = ROI)) +
  geom_point(colour = rgb(1,0.3,0,0.7), size = 2) +
  geom_hline(yintercept = 1, col = rgb(0,0.7,0,0.7), lwd = 1.2) +
  scale_y_log10(limits = c(0.0001,7500), breaks = y_breaks, labels = y_labels) +
  scale_x_continuous(breaks = x_breaks, labels = x_labels) +
  ggtitle(title_text, subtitle_text) +
  xlab("Budget") +
  ylab("Return on Investment") +
  geom_text(
    mapping = aes(label = "Break Even", x = 185, y = 0.6),
    size = 4,
    colour = text_colour) +
  geom_text(
    mapping = aes(label = "Bloody good decision", x = 175, y = 60),
    size = 4,
    colour = text_colour) +
  geom_text(
    mapping = aes(label = "Horrific choice", x = 182, y = 1 / 60),
    size = 4,
    colour = text_colour) +
  geom_segment(
    mapping = aes(x = 190, y = 2, xend = 190, yend = 20),
    arrow = arrow(length = unit(0.03, "npc")),
    colour = text_colour) +
  geom_segment(
    mapping = aes(x = 190, y = 1/4, xend = 190, yend = 1/40),
    arrow = arrow(length = unit(0.03, "npc")),
    colour = text_colour) +
  theme_minimal() +
  theme(
    text = element_text(family = "raleway", face = "bold", colour = text_colour),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(hjust = 0, size = 18),
    plot.subtitle = element_markdown(size = 10, face = "italic"),
    axis.text = element_text(colour = text_colour),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(colour = "grey30"),
    plot.background = element_rect(fill = bg_colour, colour = bg_colour),
    panel.background = element_rect(fill = bg_colour, colour = bg_colour))

# Save Plot
ggsave(
  filename = "2022-11-01_horror-films.png",
  plot = p,
  device = png,
  width = 6,
  height = 6,
  units = "in",
  dpi = 300)
