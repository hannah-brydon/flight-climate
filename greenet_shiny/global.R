###############################################################################
# Entrypoint for the shiny app
#
# Author: Vivek Katial
# Created 2019-01-30 19:34:54
###############################################################################


# Dependencies ------------------------------------------------------------
library(shiny)
library(tidyverse)
library(janitor)
library(highcharter)
library(lubridate)
library(leaflet)
library(shinycssloaders)
library(sp)
library(shinymaterial)

source("utils/setup.R")
