source("utilities.r")

pagedown::chrome_print(
  here("stata_users.Rmd"),
  here("stata_users.pdf"),
  timeout = 600
)

pagedown::chrome_print(
  here("r_users.Rmd"),
  here("r_users.pdf"),
  timeout = 600
)

