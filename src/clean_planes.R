###############################################################################
# Clean data from planes
#
# Author: Deborah Yin
# Created 2019-04-06 15:29:01
###############################################################################



# Import libs -------------------------------------------------------------


library(tidyverse)

# Cleaning ----------------------------------------------------------------


# Specify col names
col_names <- c(
    "plane_name", "iata", "icao"
)

# Read in data
d_planes <- read.csv("data/openflights/planes.dat", header = F, col.names = col_names) %>%
    tbl_df() %>%
    mutate_all(as.character)
