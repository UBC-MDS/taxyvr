library(dplyr)
library(readr)


raw <-
  read_csv2(
    "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2019&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"
  )

raw %>% head()

tax_2019 <- raw %>%
  mutate(
    LEGAL_TYPE = as.factor(LEGAL_TYPE),
    FOLIO = as.numeric(FOLIO),
    LAND_COORDINATE = as.numeric(LAND_COORDINATE),
    ZONE_NAME = as.factor(ZONE_NAME),
    ZONE_CATEGORY = as.factor(ZONE_CATEGORY),
    PROPERTY_POSTAL_CODE = as.factor(PROPERTY_POSTAL_CODE),
    NEIGHBOURHOOD_CODE = as.factor(NEIGHBOURHOOD_CODE)
  ) %>%
  rename_all(tolower)



write_csv(tax_2019, "data-raw/tax_2019.csv")
save(tax_2019, file = "data/tax_2019.rda", compress='bzip2')
