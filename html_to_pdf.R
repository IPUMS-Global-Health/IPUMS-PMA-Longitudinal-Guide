source(here::here("r/utilities.r"))

pdf_dir <- here("data_local/pdfs/posts")

pagedown::chrome_print(here(pdf_dir, "test/test.Rmd"))

pagedown::chrome_print(here(pdf_dir, "pagedown/pagedown.Rmd"))
