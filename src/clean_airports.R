###############################################################################
# Clean data from airports
#
# Author: Vivek Katial
# Created 2019-04-06 15:16:47
###############################################################################



# Import libs -------------------------------------------------------------


library(tidyverse)

# Cleaning ----------------------------------------------------------------


# Specify col names
col_names <- c(
    "airport_id", "airport_name", "city", "country", "iata", "icao",
    "lat", "lng", "alt", "tz", "dst", "tzloc", "type", "source"
    )

# Read in data
d_airports <- read.csv("data/openflights/airports.dat", header = F, col.names = col_names) %>%
    tbl_df() %>%
    select(
        airport_id,
        airport_name,
        city,
        country,
        lat,
        lng,
        alt
    ) %>%
    mutate_all(as.character)
