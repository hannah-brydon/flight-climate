###############################################################################
# Create Flight Data
#
# Author: Vivek Katial
# Created 2019-04-06 16:11:14
###############################################################################



# Setup -------------------------------------------------------------------


library(tidyverse)
set.seed(1)

# Source in clean scripts

invisible(map(file.path("src", list.files(path = "src/", pattern = "clean.*")), source))


# Clean -------------------------------------------------------------------


# We need to impute some random dates into the column for d_routes from planes
d_planes_subset <- d_planes %>%
    filter(str_detect(tolower(plane_name),  "airbus|boeing"))

# We only care about these flights
airlines <- c("jetstar", "virgin", "qantas", "singapore", "emirates", "new zealand")

# Randomly add plane

d_enriched <- d_routes %>%
    left_join(
        d_airports %>% rename_all(funs(paste0("start_",.))),
        by = "start_airport_id"
        ) %>%
    left_join(
        d_airports %>% rename_all(funs(paste0("dest_",.))),
        by = "dest_airport_id"
    ) %>%
    left_join(
        d_airlines,
        by = "airline_id"
    ) %>%
    filter(str_detect(tolower(airline_name), airlines)) %>%
    na.omit() %>%
    mutate(plane = map_chr(airline, function(x){ sample_n(d_planes_subset, size = 1) %>% pull(plane_name)})) %>%
    mutate(airline_name = ifelse(str_detect(airline_name, "Virgin"), "Virgin", airline_name)) %>%
    mutate(airline_name = ifelse(str_detect(airline_name, "Jetstar"), "Jetstar", airline_name))



# Probability of Airline Simulation --------------------------------------------------

d_enriched %>%
    count(airline_name) %>%
    mutate(prob = n/sum(n))


date_range <- seq(Sys.Date() - 365*2, Sys.Date(), by = 1)

d_final <- map_df(date_range, function(date){
    # Generate data
    sample_n(d_enriched, size = 3500, replace = T) %>%
        mutate(date = date)
}) %>%
    write_csv("greenet_shiny/data/d_final.csv")


