# read in multiple csv files and combine
library(tidyverse)

# get files
files <- dir(path = "data/openaq/raw",pattern = "*.csv",full.names = TRUE)

# read files and combine
all_data <- files %>%
    map(read_csv) %>%
    reduce(rbind) %>%
    unique

# save to csv
write_csv(all_data, "data/openaq/full_australia.csv")
