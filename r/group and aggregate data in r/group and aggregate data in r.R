library(dplyr)
df <- read.csv('/Users/timothypark/Documents/portfolios/timpark99.github.io/r/group and aggregate data in r/patients.csv')
df %>%
  group_by(service) %>%
  summarize(Count = n())

df %>%
  group_by(service) %>%
  summarize(AVG_satisfaction = mean(satisfaction),
            Count = n(),
            max(satisfaction),
            min(satisfaction),
            median(satisfaction))
