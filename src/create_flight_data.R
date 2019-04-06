###############################################################################
# Create Flight Data
#
# Author: Vivek Katial
# Created 2019-04-06 16:11:14
###############################################################################

# Source in clean scripts

map(file.path("src", list.files(path = "src/", pattern = "clean.*")), source)
