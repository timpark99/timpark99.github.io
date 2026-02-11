df <- read.csv('/Users/timothypark/Documents/portfolios/timpark99.github.io/r/filter and arrange data in r/patients.csv')
install.packages("dplyr")
library(dplyr)

df_name <- select(df, name, age)
select(df, -satisfaction)
select(df, patient_id:service)

filter(df, age > 40)
filter(df, service == "emergency")
filter(df, age > 40 & service == "emergency")

df %>%
  select(patient_id:service) %>%
  filter(age > 40 & service == "emergency") %>%
  arrange(desc(age))

arrange(df, age)
arrange(df, desc(age))

