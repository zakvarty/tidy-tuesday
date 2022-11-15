# Tidy Tuesday 2022-11-15

# Load packages ----
library(tidyverse)
library(lubridate)
library(showtext)
library(ggtext)

# Load data ----

image_alt <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-15/image_alt.csv')
color_contrast <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-15/color_contrast.csv')
ally_scores <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-15/ally_scores.csv')


#image_alt <- read_csv('https://raw.githubusercontent.com/r/tidytuesday/page-metrics-data-fix/data/2022/2022-11-15/image_alt.csv')
#color_contrast <- read_csv('https://raw.githubusercontent.com/zakvarty/tidytuesday/page-metrics-data-fix/data/2022/2022-11-15/color_contrast.csv')
#ally_scores <- read_csv('https://raw.githubusercontent.com/zakvarty/tidytuesday/page-metrics-data-fix/data/2022/2022-11-15/ally_scores.csv')

# Load fonts ----
font_add_google(name = "Raleway", family = "raleway")
showtext_auto()
main_font <- "raleway"

# Data Wrangling ----

mobile_ally <- ally_scores %>%
  filter(client == "mobile") %>%
  select(date, p10, p25, p50, p75, p90) %>%
  rename(
    ally_10 = p10,
    ally_25 = p25,
    ally_50 = p50,
    ally_75 = p75,
    ally_90 = p90)

mobile_contrast <- color_contrast %>% filter(client == "mobile") %>%
  select(date, percent) %>%
  rename(contrast_percent = percent)

mobile_alt <- image_alt %>% filter(client == "mobile") %>%
  select(date, percent) %>%
  rename(alt_percent = percent)

accessibility <- mobile_ally %>%
  left_join(mobile_contrast, by = "date") %>%
  left_join(mobile_alt, by = "date") %>%
  mutate(date = as_date(date))

# Colour palette based on Oban photo ----

oban <- list(
  blue = "#548BA2",
  gray = "#2A4247",
  red = "#84374A",
  orange = "#C09378",
  yellow = "#917B21",
  white = "#E5EBED"
)

# Strings for plot ----

title_string <- "Internet Accessibility on Mobile Devices"
subtitle_string <- "Lighthouse metrics: sites are improving slowly but can still do much better."
attribution_string <- "**Tidy Tuesday:** 2022-11-15 || **Data:** httparchive.org || **Plot:** @zakvarty"

# Create Plot ----

p <- ggplot(data = accessibility, mapping = aes(x = date)) +
  geom_ribbon(aes(ymin = ally_10 , ymax = ally_90), fill = alpha(oban$blue, 0.2)) +
  geom_ribbon(aes(ymin = ally_25 , ymax = ally_75), fill = alpha(oban$blue, 0.2)) +
  geom_line(aes(y = ally_50), colour = oban$blue, lwd = 1.05) +
  geom_line(aes(y = alt_percent), colour = oban$red, lwd = 1.05) +
  geom_line(aes(y = contrast_percent), colour = oban$yellow, lwd = 1.05) +
  ylim(c(0,100)) +
  xlim(as_date(c("2017-06-01", "2022-10-01"))) +
  ggtitle(title_string, subtitle_string) +
  geom_label(
    aes(label = "Contrast", x = as_date("2022-06-01"), y = 15),
    size = 5,
    family = main_font,
    fill = oban$yellow, colour = oban$white) +
  geom_label(
    aes(label = "Alt Text", x = as_date("2022-06-01"), y = 45),
    size = 5,
    family = main_font,
    fill = oban$red,
    colour = oban$white) +
  geom_label(
    aes(label = "Accessibility Score", x = as_date("2022-01-01"), y = 71),
    size = 5,
    family = main_font,
    fill = oban$blue,
    colour = oban$white) +
  ylab(attribution_string) +
  theme_minimal() +
  theme(
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(hjust = 0.01, size = 22),
    plot.subtitle = element_text(hjust = 0.02, size = 11),
    plot.background = element_rect(fill = oban$white),
    panel.grid = element_line(colour = alpha(oban$gray, 0.2)),
    text = element_text(
      colour = oban$gray,
      family = main_font,
      face = "bold"),
    axis.title.x = element_blank(),
    axis.title.y = element_markdown(face = "plain", size = 8, vjust = 0, hjust = 0),
    axis.text = element_text(size = 11)
  )

# Save plot ----
ggsave(
  filename = "2022-11-15_mobile-web-accessibility.png",
  plot = p,
  device = png,
  width = 9,
  height = 6,
  units = "in",
  dpi = 250)

