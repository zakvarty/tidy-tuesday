# Stylised plot of brat UK Chart rankings over Summer 2024
# data source: https://www.officialcharts.com/charts/albums-chart/20240628/7502/

# Comments to my future self:
# I wanted to show daily streams of brat album songs but this is not covered by
# the spotify API. The closest I could find was this:
#
# https://www.mystreamcount.com/track/19RybK6XDbAVpcdxSbZL1o
#
# which is not very amenable to web scraping. I've got access to their API but
# can't find the documentation and so only have the previous 30 days of data.
# I'm working on a follow-up analysis for that.

# Load required packages -------------------------------------------------------
library(lubridate)
library(dplyr)
library(magrittr)
library(ggplot2)
library(ggtext)       # for text annotations
library(ggfx)         # for Gaussian blur
library(extrafont)    # for Arial font


# Define plotting parameters ---------------------------------------------------

# dates
date_min <- date("2024-06-01")
date_max <- date("2024-08-31")
month_starts <-  date(c("2024-06-01", "2024-07-01", "2024-08-01"))
month_ends <- date(c("2024-06-30", "2024-07-31", "2024-08-30"))
mid_dates <- date(c("2024-07-16", "2024-06-15", "2024-07-16", "2024-08-15"))


# cosmetics
pal_brat <- list(green = "#8ace00", black = "#000000")
blur_sigma <- 6
y_scaling <- 0.6
loadfonts(quiet = TRUE)
brat_font <- "Arial Unicode MS"

# Data preparation -------------------------------------------------------------

# simulate daily stream count (hidden in final plot)
date <- seq(date_min, date_max, 1)
streams <- runif(92)
brat <- data.frame(date, streams)

# weekly chart position
brat_chart <- tibble(
  position = c(2,3,4,4,4,6,6,3,2,3,5,9),
  week_start = date("2024-06-14") + days(7 * 0:11),
  week_end = week_start + days(7)
)

# restrict to Jun-Aug and rescale y-values to avoid "brat" text
brat_chart[nrow(brat_chart),"week_end"] <- date_max
brat_chart <- mutate(brat_chart, position = ((10 - position) / 10) * y_scaling)

# horizontal lines marking chart positions
staves <- tibble(
  start = rep(date_min, 9),
  end = rep(date_max, 9),
  position = (1:9) / 10 * y_scaling
)

stave_labels <- tibble(
  x = rep(date_min, 3),
  y = c(staves$position[c(9, 5)], 0),
  label = c("#1", "5", "10")
)

# makeshift time-axis
month_lines <- data.frame(
  start_y = rep(-0, 3),
  end_y = rep(-0, 3),
  start_x = month_starts,
  end_x = month_ends)

annotations <- data.frame(
  label = c("brat", "june", "july", "august"),
  x = c(mid_dates),
  y = c(1.5, rep(-0.1, 3)),
  size = c(56, 8, 8, 8)
)


# Plotting ---------------------------------------------------------------------

p <- ggplot(data = brat, aes(x = date, y = streams)) +
  geom_bar(stat = "identity", width = 0, colour = NA) +
  geom_segment(
    data = brat_chart,
    mapping = aes(x = week_start, xend = week_end, y = position, yend = position),
    linewidth = 1) %>%
    with_blur(sigma = blur_sigma / 2) +
  geom_segment(
    data = staves,
    mapping = aes(x = start, xend = end, y = position, yend = position),
    linewidth = 0.3) %>%
    with_blur(sigma = blur_sigma / 2) +
  geom_richtext(
    data = annotations[1, ],
    mapping = aes(label = label, x = x, y = y),
    size = annotations$size[1],
    family = brat_font,
    fill = NA,
    colour = pal_brat$black,
    label.colour = NA) %>%
    with_blur(sigma = blur_sigma) +
  geom_richtext(
    data = stave_labels,
    mapping = aes(label = label, x = x, y = y),
    size = annotations$size[2] / 2,
    family = brat_font,
    fill = NA,
    colour = pal_brat$black,
    label.colour = NA,
    hjust = 1) %>%
    with_blur(sigma = blur_sigma / 2) +
  geom_richtext(
    data = annotations[-1,],
    mapping = aes(label = label, x = x, y = y),
    size = annotations$size[2],
    family = brat_font,
    fill = NA,
    colour = pal_brat$black,
    label.colour = NA) %>%
    with_blur(sigma = blur_sigma / 2) +
  geom_segment(
    data = month_lines,
    mapping = aes(x = start_x, xend = end_x, y = start_y, yend = end_y),
    linewidth = 0.6) %>%
    with_blur(sigma = blur_sigma / 2) +
  theme_void() +
  ylim(c(-0.2,3)) +
  xlim(c(date_min - days(2), date_max + days(2))) +
  theme(plot.background = element_rect(fill = pal_brat$green))

ggsave(p, filename = "brat_summer.png", width = 7, height = 7)



