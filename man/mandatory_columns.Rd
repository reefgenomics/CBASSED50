% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocess-and-validate-data.R
\name{mandatory_columns}
\alias{mandatory_columns}
\title{Get the names of mandatory columns for the dataset.}
\usage{
mandatory_columns()
}
\value{
A character vector containing the names of mandatory columns.
}
\description{
This function returns a character vector containing the names of columns that are
considered mandatory for a dataset to meet certain requirements.
}
\examples{
mandatory_cols <- mandatory_columns()
print(mandatory_cols)

# [1] "Project"     "Date"        "Site"        "Genotype"   
# [5] "Species"     "Country"     "Latitude"    "Longitude"  
# [9] "Condition"   "Temperature" "Timepoint"   "Pam_value"  

}
