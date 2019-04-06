###############################################################################
# Clean routes
#
# Author: Vivek Katial
# Created 2019-04-06 15:28:29
###############################################################################

library(tidyverse)

col_names <- c(
    "airline", "airline_id", "start_airport_name", "start_airport_id",
    "dest_airport_name", "dest_airport_id", "codeshare",
    "stops", "equipment")


d_routes <- read.csv("data/openflights/routes.dat", header = F, col.names = col_names) %>%
    tbl_df() %>%
    filter(stops == 0) %>%
    select(-codeshare, -equipment, -stops) %>%
    mutate_all(as.character)

