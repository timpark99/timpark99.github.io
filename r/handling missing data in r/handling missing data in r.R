# install.packages("tidyverse")
library(dplyr)
library(tidyr)
df <- read.csv('/Users/timothypark/Documents/portfolios/timpark99.github.io/r/handling missing data in r/workout_data.csv', na.strings = c("", "NA"))

colSums(is.na(df))

df_cleaned <- df %>% drop_na("workout_type")

df_cleaned$workout_duration_minutes[is.na(df_cleaned$workout_duration_minutes)] <- 0

df_cleaned$workout_duration_minutes[is.na(df_cleaned$workout_duration_minutes)] <- mean(df_cleaned$workout_duration_minutes, na.rm = TRUE)

df_cleaned$gender[is.na(df_cleaned$gender)] <- "Unknown"
