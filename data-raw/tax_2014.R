library(dplyr)
library(readr)
library(ggmap)

raw <-
  read_csv2(
    "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2014&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"
  )

tax_2014 <- raw %>%
  mutate(FOLIO = as.numeric(FOLIO),
         LAND_COORDINATE = as.numeric(LAND_COORDINATE),) %>%
  rename_all(tolower)

# read in addresses
addresses <- get(load(file = "data-raw/addresses.rda"))

# convert PCOORD to correct type
coords <- addresses %>% 
  mutate(PCOORD = as.numeric(PCOORD))

# join with tax dataframe
combo <- tax_2014 %>%
  left_join(coords, by = c("land_coordinate" = "PCOORD"))

#remove duplicates of folio that are created when joined with coord df
ll_df <- combo %>%
  group_by(folio) %>%
  slice(1) %>%
  ungroup()

# obtain the latitude and longitude of the column
ll_df <- ll_df %>%
  mutate(Geom = str_replace_all(Geom, ".*\\[| |\\].*", "")) %>%
  separate(Geom, c("longitude", "latitude"), sep = ",") %>%
  mutate(longitude = as.numeric(longitude)) %>%
  mutate(latitude = as.numeric(latitude))

# make a column for the full address to use geocoding on
ll_df$full_address <- paste(
  ll_df$to_civic_number,
  " ",
  ll_df$street_name,
  ", Vancouver, BC, ",
  ll_df$property_postal_code,
  sep = "")

# find the values that are missing coordinates
missing <- ll_df %>%
  filter(is.na(latitude))

# make sure to register you API KEY first
# register_google(key = API_KEY)

# use google API to get missing coordinates
new_coords <- geocode(missing$full_address,
                      output = "latlona",
                      source = "google")

# since the function changes the address we add back the orginal full address for joining
new_coords_xtra_a <- new_coords %>%
  cbind(full_address = missing$full_address)

# join the 2 dataframes
second_ll <- ll_df %>%
  left_join(new_coords_xtra_a, by = "full_address")

# replace the na latitude and longitude values and remove unneeded columns
second_ll <- second_ll %>%
  mutate(
    latitude = ifelse(is.na(latitude),
                      lat,
                      latitude),
    longitude = ifelse(is.na(longitude),
                       lon,
                       longitude)) %>%
  select(-lat,-lon,-full_address,
         -CIVIC_NUMBER,-P_PARCEL_ID,
         -SITE_ID,-address,-STD_STREET) %>%
  rename(geo_local_area = `Geo Local Area`)

second_ll %>% filter(is.na(longitude))

# remove duplicates and rows should match # available on the website report
tax_2014 <- second_ll %>% unique()

#write_csv(tax_2014, "data-raw/tax_2014.csv")
save(tax_2014, file = "data/tax_2014.rda", compress = 'bzip2')
saveRDS(tax_2014, "tests/testthat/tax_2014.rds")