#### Preamble ####
# Purpose: Clean and organise the datasets from Open Data Toronto, attach data to wards for map plots
# Author: Roy Chan
# Data: 6 Feb 2022
# Contact: rk.chan@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to download data sets from opendatatoronto and saved it to inputs/data
# - Don't forget to gitignore it


#### Workspace setup ####
library(tidyverse)
library(here)

# read in speed summary dataset
speed_data <- read_csv(here::here("inputs/data/speed_data.csv"))

# truncate removal date to year, for grouping
speed_data$removal_date <- str_sub(speed_data$removal_date, end = 4)
# drop column schedule as all displays operate on same schedule
locations <- speed_data %>% select(c('_id':removal_date, min_speed))
speed_counts <- left_join(locations, select(speed_data, c('_id', starts_with('spd_'), -spd_00)))

# convert speed_counts to long format, grouping into wards by year 
speed_counts <- speed_counts %>% gather("speed", "count", starts_with('spd_')) %>% 
  mutate(speed = str_remove_all(speed, "spd_")) %>%
  mutate(speed = str_remove_all(speed, "_.*")) %>%
  transform(speed = as.numeric(speed)) %>%
  group_by(ward_no, speed, removal_date) %>% 
  summarise(count = sum(count)) %>%
  ungroup()

# summarise speeds by ward and year
ward_average_speeds <- speed_counts %>% 
  group_by(ward_no,removal_date) %>% 
  summarise(speed = (sum(speed * count) / sum(count)))

# summarise all wards into average speed for the city in a year
yearly_speeds <- speed_counts %>% 
  group_by(removal_date, speed) %>% 
  summarise(count = sum(count)) %>% 
  summarise(speed, density = count / sum(count))

# save yearly speeds as Rds for plotting in markdown file
saveRDS(yearly_speeds, "inputs/data/yearly_speeds.Rds")

# read ward data object
wards <- readRDS(here::here("inputs/data/wards.Rds"))

# convert AREA_SHORT_CODE to numeric type, so we can join the map data with our speed data later
wards <- wards %>% transform(AREA_SHORT_CODE = as.numeric(AREA_SHORT_CODE))

# get the percentage of recorded speeds in each wards that were over 40km/h
total_counts <- speed_counts %>%
  group_by(ward_no, removal_date) %>%
  summarise(total_count = sum(count))

# count number of vehicle speeds exceeding the speed limit of 40
# accounting for lower speed limit of 30 in wards 10 to 14
count_speeding <- speed_counts %>%
  filter((speed > 40 & !ward_no %in% c(10, 11, 12, 13, 14)) | 
           (speed > 30 & ward_no %in% c(10, 11, 12, 13, 14))) %>%
  group_by(ward_no, removal_date) %>%
  summarise(count = sum(count))

# compute percentage of speeding over total number of observations
percentage_speeding <- total_counts %>% 
  left_join(count_speeding) %>%
  summarise(removal_date, percentage = (count / total_count) * 100)

# join avg speed and percentage speeding to ward dataframe for map plots
wards <- wards %>% 
  left_join(left_join(ward_average_speeds, percentage_speeding, 
                      by = c('ward_no', 'removal_date')), 
            by = c('AREA_SHORT_CODE' = 'ward_no'))

# save wards object with attached columns
saveRDS(wards, "inputs/data/wards_speeds.Rds")
         