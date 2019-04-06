###############################################################################
#  Flight Map
#
# Author: Vivek Katial
# Created 2019-04-07 09:15:58
###############################################################################

library(leaflet)
library(geosphere)
library(maps)

d_test
gcIntermediate(
    d_test %>% select(start_lng, start_lat) %>% as.matrix(),
    d_test %>% select(dest_lng, dest_lat) %>% as.matrix(),
    n = 100,
    addStartEnd = T,
    sp = TRUE,
    breakAtDateLine = TRUE
) %>%
    leaflet() %>%
    addTiles() %>%
    addPolylines(
        weight = 1
    )

paths <- gcIntermediate(
    d_test %>% select(start_lng, start_lat) %>% as.matrix(),
    d_test %>% select(dest_lng, dest_lat) %>% as.matrix(),
    n = 100,
    addStartEnd = T,
    sp = TRUE,
    breakAtDateLine = TRUE
)

pal <- colorRampPalette(c("#f2f2f2", "black"))
colors <- pal(100)


paths %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
    addPolylines(
        color = d_test %>%  pull(color),
        weight = 1
        )

lapply( paths , function(x) `@`(x , "lines") )
