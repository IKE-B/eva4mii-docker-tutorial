# Base R Image, we are building on this
FROM rocker/r-base:4.6.0

# Create working directory within the container
WORKDIR /analysis

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'MASS'))"

# Copy the script into the container working directory
COPY Docker_Tutorial.R /analysis/

# Set script as entry point; defines what is done when container is started
ENTRYPOINT ["Rscript", "Docker_Tutorial.R"]
