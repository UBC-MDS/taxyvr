library(readr)
source('data-raw/munge_tax.R')

url <- "https://opendata.vancouver.ca/explore/dataset/property-tax-report/download/?format=csv&refine.report_year=2019&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"

tax_2019 <- munge_tax(url)

#write_csv(tax_2019, "data-raw/tax_2019.csv")
save(tax_2019, file = "data/tax_2019.rda", compress = 'bzip2')
saveRDS(tax_2019, "tests/testthat/tax_2019.rds")
