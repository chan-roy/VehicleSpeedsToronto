# data download code from https://open.toronto.ca/dataset/mobile-watch-your-speed-program-speed-summary/

# Download datasets from OpenData Toronto - speed summary and wards
library(opendatatoronto)
library(dplyr)
# add library readr to write data to csv
library(readr)

# get package
package <- show_package("058236d2-d26e-4622-9665-941b9e7a5229")
package

# get all resources for this package
resources <- list_package_resources("058236d2-d26e-4622-9665-941b9e7a5229")

# identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# load the first datastore resource as a sample
speed_data <- filter(datastore_resources, row_number()==1) %>% get_resource()

# write to csv
write_csv(speed_data, "inputs/data/speed_data.csv")

# use same methods to get Toronto municipal word data, includes geometry so we can plot maps later
# issue with converting between R data object and csv for geometry, so save directly as Rds
resources_2 <- list_package_resources("5e7a8234-f805-43ac-820f-03d7c360b588")
datastore_resources_2 <- filter(resources_2, tolower(format) %in% c('csv', 'geojson'))
wards <- filter(datastore_resources_2, row_number()==1) %>% get_resource()
saveRDS(wards, "inputs/data/wards.Rds")
