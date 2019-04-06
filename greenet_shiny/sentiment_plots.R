##########################
# Author: Hannah Brydon
# Created: 6/04/2019
# Plots for analysis of sentiment
##########################

library(tidyverse)
library(highcharter)

# Retrieve sentiment data -------------------------------------------------

topics <- list.files("data/twitter")

filenames <- paste0("data/twitter/", grep(".csv", topics, value = TRUE))

sentiment_data <- map(
    filenames,
    read_csv
)

# Combine emissions related chat

emissions_related <- rbind(
    sentiment_data[[1]],
    sentiment_data[[3]],
    sentiment_data[[4]],
    sentiment_data[[5]],
    sentiment_data[[9]],
    sentiment_data[[10]]
    )

sentiment_data <- list(
    sentiment_data[[2]],
    sentiment_data[[6]],
    sentiment_data[[7]],
    sentiment_data[[8]],
    emissions_related
)

topics <- c(str_remove(topics, ".csv")[c(2, 6, 7, 8)], "emissions")

# Plotting sentiment score over time ----------------------------------------------------

map(
    1:length(sentiment_data),
    function(x) {
        hchart(
            sentiment_data[[x]],
            "scatter",
            hcaes(x = created_date, y = sentiment_score, group = sentiment_label),
            tooltip = list(pointFormat = "{point.text}")
        ) %>%
            hc_title(text = topics[x]) %>%
            hc_add_series(
                data = sentiment_data[[x]] %>% group_by(created_date) %>% summarise(mean_score = round(mean(sentiment_score), digits = 3)),
                hcaes(x = created_date, y = mean_score),
                type = "line",
                name = "Mean"
            ) %>%
            hc_legend(align = "center") %>%
            hc_colors(hex_to_rgba(c("salmon", "khaki", "palegreen", "lightgray"), alpha = c(0.7, 0.7, 0.7, 1))) %>%
            hc_xAxis(title = list(text = "Date")) %>%
            hc_yAxis(title = list(text = "Tweet sentiment"))

    }
)





hchart(
    sentiment_data[[x]],
    "scatter",
    hcaes(x = created_date, y = sentiment_score, group = sentiment_label),
    tooltip = list(pointFormat = "{point.text}")
) %>%
    hc_title(text = topics[x]) %>%
    hc_add_series(
        data = sentiment_data[[x]] %>% group_by(created_date) %>% summarise(mean_score = round(mean(sentiment_score), digits = 3)),
        hcaes(x = created_date, y = mean_score),
        type = "line",
        name = "Mean"
    ) %>%
    hc_legend(align = "center") %>%
    hc_colors(hex_to_rgba(c("salmon", "khaki", "palegreen", "lightgray"), alpha = c(0.7, 0.7, 0.7, 1))) %>%
    hc_xAxis(title = list(text = "Date")) %>%
    hc_yAxis(title = list(text = "Tweet sentiment"))





