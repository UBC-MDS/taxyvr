library(readr)
source('data-raw/munge_tax.R')

url <- "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2014&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"

tax_2014 <- munge_tax(url)

#write_csv(tax_2014, "data-raw/tax_2014.csv")
save(tax_2014, file = "data/tax_2014.rda", compress = 'bzip2')
saveRDS(tax_2014, "tests/testthat/tax_2014.rds")