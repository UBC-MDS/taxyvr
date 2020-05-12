library(readr)
source('data-raw/munge_tax.R')

url <- "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2016&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"

tax_2016 <- munge_tax(url)

#write_csv(tax_2016, "data-raw/tax_2016.csv")
save(tax_2016, file = "data/tax_2016.rda", compress = 'bzip2')
saveRDS(tax_2016, "tests/testthat/tax_2016.rds")
