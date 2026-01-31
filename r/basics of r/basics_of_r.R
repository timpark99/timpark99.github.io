num_var <- 54
print(num_var)
class(num_var)
str_var <- "I am a chicago bears fan"
vec_var <- c(10, 20, 50, 100, 1000)
list_var <- list(name = "Tim", age = 33, numbers = c(90, 50, 24))
list_var
list_var$name
list_var[1]
list_var[["name"]]
df <- data.frame(
  name = c("Brian", "Lance", "Charles"),
  age = c(31, 28, 32),
  tackles = c(8, 9, 4)
)
