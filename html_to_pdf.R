source(here::here("r/utilities.r"))

pagedown::chrome_print(
  here("r_users.Rmd"),
  here("r_users.pdf"),
  timeout = 600
)

pagedown::chrome_print(
  here("test.Rmd"), 
  here("test.pdf")
)

