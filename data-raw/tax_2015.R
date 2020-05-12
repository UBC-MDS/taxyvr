library(readr)
source('data-raw/munge_tax.R')

url <- "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2015&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"

tax_2015 <- munge_tax(url)

#write_csv(tax_2015, "data-raw/tax_2015.csv")
save(tax_2015, file = "data/tax_2015.rda", compress = 'bzip2')
saveRDS(tax_2015, "tests/testthat/tax_2015.rds")