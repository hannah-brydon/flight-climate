FROM rocker/rstudio:latest
RUN apt update && apt upgrade -y

# Install system dependencies.
RUN apt install -y libxml2-dev libcurl4-openssl-dev libssl-dev libz-dev

# Install packrat
RUN R -e 'install.packages("packrat")'

# Set timezone
RUN cp /usr/share/zoneinfo/Pacific/Auckland /etc/localtime
