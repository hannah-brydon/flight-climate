###############################################################################
# Clean data from airlines
#
# Author: Deborah Yin
# Created 2019-04-06 15:29:01
###############################################################################



# Import libs -------------------------------------------------------------


library(tidyverse)

# Cleaning ----------------------------------------------------------------


# Specify col names
col_names <- c(
    "airline_id", "airline_name", "airline_alias", "iata", "icao",
    "airline_callsign", "airline_country", "airline_status"
)

# Read in data
d_airlines <- read.csv("data/openflights/airlines.dat", header = F, col.names = col_names) %>%
    tbl_df()


d_airlines %>%

    # Filter for active airlines
    filter(airline_status == "Y") %>%
    select(-airline_status) %>%

    # Select relevant columns
    select(
        airline_id,
        airline_name,
        airline_country
    )


