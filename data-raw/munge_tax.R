library(tidyverse)
library(readr)
library(ggmap)

 munge_tax<- function(url){
   
   print("Loading data--------------------------", quote=FALSE)
   raw <- read_delim(url, delim = ";" )
    
   print("Cleaning up---------------------------", quote=FALSE)
   tax <- raw %>%
     mutate(FOLIO = as.numeric(FOLIO),
            LAND_COORDINATE = as.numeric(LAND_COORDINATE)) %>%
     rename_all(tolower)
   
   # read in addresses
   print("Read vancouver addresses--------------", quote=FALSE)
   addresses <- get(load(file = "data-raw/addresses.rda"))
   
   # convert PCOORD to correct type
   coords <- addresses %>%
     mutate(PCOORD = as.numeric(PCOORD))
   
   # join with tax dataframe
   print("Joining dataframes--------------------", quote=FALSE)
   combo <- tax %>%
     left_join(coords, by = c("land_coordinate" = "PCOORD"))
   
   #remove duplicates of folio that are created when joined with coord df
   print("Removing duplicates-------------------", quote=FALSE)
   ll_df <- combo %>%
     group_by(folio) %>%
     slice(1) %>%
     ungroup()
   
   # obtain the latitude and longitude of the column
   print("Creating lat/long columns-------------", quote=FALSE)
   ll_df <- ll_df %>%
     mutate(Geom = str_replace_all(Geom, ".*\\[| |\\].*", "")) %>%
     separate(Geom, c("longitude", "latitude"), sep = ",") %>%
     mutate(longitude = as.numeric(longitude)) %>%
     mutate(latitude = as.numeric(latitude))
   
   # make a column for the full address to use geocoding on
   print("Creating full address column----------", quote=FALSE)
   ll_df$full_address <- paste(
     ll_df$to_civic_number,
     " ",
     ll_df$street_name,
     ", Vancouver, BC, ",
     ll_df$property_postal_code,
     sep = "")
   
   # find the values that are missing coordinates
   print("Finding missing coordinates-----------", quote=FALSE)
   missing <- ll_df %>%
     filter(is.na(latitude))
   
   # make sure to register you API KEY first
   # register_google(key = API_KEY)
   
   # use google API to get missing coordinates
   print("Requesting missing lat/long values----", quote=FALSE)
   new_coords <- geocode(missing$full_address,
                         output = "latlona",
                         source = "google")
   
   # since the function changes the address we add back the orginal full address for joining
   new_coords_xtra_a <- new_coords %>%
     cbind(full_address = missing$full_address)
   
   # join the 2 dataframes
   print("Adding missing values--------------", quote=FALSE)
   second_ll <- ll_df %>%
     left_join(new_coords_xtra_a, by = "full_address")
   
   # replace the na latitude and longitude values and remove unneeded columns
   print("Cleaning and replacing-------------", quote=FALSE)
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
   print("Removing duplicates--------------", quote=FALSE)
   tax <- second_ll %>% 
     unique()
   
}