library(tidyverse)

lemurs<- read_csv("~/Downloads/DataRecord_3_DLC_Weight_File_05Feb2019.csv")

lemurs <- mutate(lemurs, DOB = lubridate::dmy(lemurs$DOB))
lemurs <- mutate(lemurs, Weight_Date = lubridate::dmy(lemurs$Weight_Date))
lemurs <- mutate(lemurs, Sex = as.factor(Sex))

lemur_data <- lemurs %>%
  group_by(Name) %>%
  filter(Sex != "ND") %>%
  summarise(Sex, final_weight = last(Weight_g,order_by = Weight_Date)) %>%
  group_by(Sex)

lemur_theme <- theme(
  title = element_text(size = 16),
  plot.subtitle = element_text(size = 12),
  legend.title.align = 0,
  plot.title.position = "plot",
  text = element_text(family = "mono"),
  axis.text = element_text(size = 12),
  panel.grid.major.x = element_blank()
)

p <- lemur_data %>%
  ggplot() +
  geom_boxplot(mapping = aes( y = final_weight, x = Sex),
               fill = rgb(0,0,0,0.05)) +
  ggtitle( "Lemur Weights by Sex", "Last recorded weight in grammes") +
  ylab("") +
  theme_minimal() +
  lemur_theme

ggsave(
  plot = p,
  filename = "lemur_boxplot.png",
  device = "png",
  width = 5,
  height = 4,
  dpi = 300,bg = "#FFFFFA")

