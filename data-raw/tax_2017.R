library(dplyr)
library(readr)


raw <-
  read_csv2(
    "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2017&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"
  )

raw %>% head()

tax_2017 <- raw %>%
  mutate(
    FOLIO = as.numeric(FOLIO),
    LAND_COORDINATE = as.numeric(LAND_COORDINATE),
  ) %>%
  rename_all(tolower)


#write_csv(tax_2017, "data-raw/tax_2017.csv")
save(tax_2017, file = "data/tax_2017.rda", compress='bzip2')
saveRDS(tax_2017, "tests/testthat/tax_2017.rds")