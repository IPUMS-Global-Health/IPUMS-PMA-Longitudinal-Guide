# try tidyverse ----
if(!suppressWarnings(suppressMessages(require(tidyverse)))){
  rlang::abort(c(
    "tidyverse is not installed",
    "i" = "Install tidyverse with `install.packages('tidyverse')`"
  ))
}

# try ipumsr ----
if(!suppressWarnings(suppressMessages(require(ipumsr)))){
  rlang::abort(c(
    "ipumsr is not installed",
    "i" = "Install ipumsr with `install.packages('ipumsr')`"
  ))
}

# try srvyr ----
if(!suppressWarnings(suppressMessages(require(srvyr)))){
  rlang::abort(c(
    "srvyr is not installed",
    "i" = "Install ipumsr with `install.packages('srvyr')`"
  ))
}

# try htmltools ----
if(!suppressWarnings(suppressMessages(require(htmltools)))){
  rlang::abort(c(
    "htmltools is not installed",
    "i" = "Install htmltools with `install.packages('htmltools')`"
  ))
}

# try RCurl ----
# If RCurl is not installed, warn user that URLs cannot be validated 
if(!suppressWarnings(suppressMessages(require(RCurl)))){
  rlang::warn(c(
    "RCurl is not installed, so URLs built with `pmavar` will not be tested",
    "i" = "Before next time, install RCurl with `install.packages('RCurl')`"
  ))
}

# try here ----
if(!suppressWarnings(suppressMessages(require(here)))){
  rlang::warn(c(
    "here is not installed",
    "i" = "Install here with `install.packages('here')`"
  ))
}

# try sysfonts ----
if(!suppressWarnings(suppressMessages(require(sysfonts)))){
  rlang::abort(c(
    "sysfonts is not installed",
    "i" = "Install sysfonts with `install.packages('sysfonts')`"
  ))
} else {
  sysfonts::font_add(
    family = "cabrito",
    regular = here::here("fonts/cabritosansnormregular-webfont.ttf")
  )
}

# try showtext ----
if(!suppressWarnings(suppressMessages(require(showtext)))){
  rlang::warn(c(
    "showtext is not installed",
    "i" = "Install showtext with `install.packages('showtext')`"
  ))
} else {
  showtext::showtext_auto()
}

# varlink ----
# Build hyperlink to a variable page on pma.ipums.org 
# Optionally, select a metadata tab 
r_link <- function(varname, tab = codes){
  varlink <- substitute(varname) %>% 
    str_remove("_1") %>% 
    str_remove("_2") 
  tab_section <- paste0(varlink, "#", substitute(tab), "_section")
  url <- file.path("https://pma.ipums.org/pma-action/variables", tab_section)
  # if(exists("url.exists")){
  #   if(!url.exists(url)){
  #     rlang::abort(c("x" = paste(url, "does not exist")))
  #   }
  # }
  paste0("[", substitute(varname), "]", "(", url, ")")
}

# slink ----
# Build hyperlink to a variable seen in Stata (e.g. lowercase)
# Strips any numeric suffix for Phase 
# Optionally, select a metadata tab 
stata_link <- function(varname, tab = codes){
  slink <- substitute(varname) %>% 
    str_remove("_1") %>% 
    str_remove("_2") 
  tab_section <- paste0(slink, "#", substitute(tab), "_section")
  url <- file.path("https://pma.ipums.org/pma-action/variables", tab_section)
  # if(exists("url.exists")){
  #   if(!url.exists(url)){
  #     rlang::abort(c("x" = paste(url, "does not exist")))
  #   }
  # }
  paste0("[`", substitute(varname) %>% tolower, "`]", "(", url, ")")
}


funlink <- function(fun, alt_text = NULL) {
  
  fun <- deparse(substitute(fun))

  stopifnot(length(fun) == 1)
  
  is_fun <- stringr::str_detect(fun, "::")
  
  # If not provided as pkg::fun, assume we are linking to a package
  if (!is_fun) {
    display_name <- fun
    fun <- paste0("library(", fun, ")")
  } else {
    display_name <- stringr::str_split(fun, "::")[[1]][2]
  }

  url <- downlit::autolink_url(fun)
  
  if (is.na(url)) {
    rlang::abort(
      c("x" = paste0("Unable to find link for function `", fun, "`"))
    )
  } else if (!is_fun && stringr::str_detect(url, "library.html$")) {
    # `autolink_url` returns a generic link for `library` docs when 
    # package is not found. Throw error instead:
    rlang::abort(
      c("x" = paste0("Unable to find link for package `", display_name, "`"))
    )
  }
  
  if (!is.null(alt_text)) {
    display_name <- alt_text
  }
  
  paste0("[", display_name, "](", url, ")")
  
}

# hex ---- 
# Get the hex sticker for a package (e.g. for images within aside tags)
# Must be included in `images/hex` and recorded in `images/hex/inventory.csv`
hex <- function(pkg){
  inventory <- here::here("images/hex/inventory.csv") %>% 
    read.csv() %>% 
    tibble()
  if(pkg %in% inventory$package){
    inventory <- inventory %>% filter(package == pkg)
    htmltools::div(
      htmltools::a(
        style = "text-decoration: none;",
        href = inventory$url,
        htmltools::img(
          src = here::here("images/hex", paste0(pkg, ".png"))
        )
      ),
      htmltools::br(),
      paste("©", inventory$owner),
      htmltools::br(), 
      paste0("(", inventory$license, ")")
    )
  } else {
    rlang::abort(c(
      paste0("The `", pkg, "` package has no available hex logo"),
      "i" = "Consider downloading one to `images/hex`",
      "i" = "If you do, please add it to `images/hex/inventory.csv`" 
    ))
  }
}


