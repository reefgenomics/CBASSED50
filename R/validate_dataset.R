#' Get the names of mandatory columns for the dataset.
#'
#' This function returns a character vector containing the names of columns that are
#' considered mandatory for a dataset to meet certain requirements.
#'
#' @return A character vector containing the names of mandatory columns.
#'
#' @examples
#' mandatory_cols <- mandatory_columns()
#' print(mandatory_cols)
#'
#' [1] "Date"        "Country"     "Site"        "Condition"   "Species"
#' [6] "Genotype"    "Temperature" "PAM"
#'
#' @export
mandatory_columns <- function() {
  return(
    c(
      "Date",
      "Country",
      "Site",
      "Condition",
      "Species",
      "Genotype",
      "Temperature",
      "PAM"
    )
  )
}


#' Check if the dataset has all mandatory columns
#'
#' This function checks if a given dataset contains all the mandatory columns specified in the \code{mandatory_columns} vector.
#'
#' @param dataset A data frame representing the dataset to be validated.
#'
#' @return A logical value indicating whether all the mandatory columns are present in the dataset.
#'
#' @examples
#' # Sample dataset
#' sample_data <- data.frame(Date = c("2023-07-31", "2023-08-01", "2023-08-02"),
#'                           Country = c("Country A", "Country B", "Country C"),
#'                           Site = c("Site X", "Site Y", "Site Z"),
#'                           Condition = c("Condition 1", "Condition 2", "Condition 3"),
#'                           Species = c("Species 1", "Species 2", "Species 3"),
#'                           Genotype = c("Genotype A", "Genotype B", "Genotype C"),
#'                           Temperature = c(30.2, 31.5, 29.8),
#'                           PAM = c(0.5, 0.6, 0.8))
#'
#' dataset_has_mandatory_columns(sample_data)
#' # Output: TRUE
#'
#' # Sample dataset with missing columns
#' missing_columns_data <- data.frame(Label = c("A", "B", "C"),
#'                                    Date = c("2023-07-31", "2023-08-01", "2023-08-02"))
#'
#' dataset_has_mandatory_columns(missing_columns_data)
#' # Output: FALSE
#'
dataset_has_mandatory_columns <- function(dataset) {
  result <- all(mandatory_columns() %in% colnames(dataset))
  return(result)
}

#' Check and Convert Columns in Dataset
#'
#' This function checks the data types of specific columns in the provided dataset and converts them to the desired data type if necessary.
#' The function is designed to ensure that certain columns are represented as factors or numeric values, as required for further analysis.
#'
#' @param dataset A data frame containing the dataset to be checked and modified.
#'
#' @return A modified version of the input dataset with the specified columns converted to factors or numeric types, as appropriate.
#'
#' @examples
#' # Sample dataset
#' data <- data.frame(Site = c("A", "B", "C"),
#'                    Condition = c("Control", "Experimental", "Control"),
#'                    Species = c("Species1", "Species2", "Species1"),
#'                    Genotype = c("GenotypeA", "GenotypeB", "GenotypeA"),
#'                    Temperature = c("25", "28", "30"),
#'                    PAM = c("0.4", "0.6", "0.7"))
#'
#' # Convert columns in the dataset
#' modified_data <- check_and_convert_columns(data)
#'
#' # The 'Site', 'Condition', 'Species', and 'Genotype' columns are now factors,
#' # and 'Temperature' and 'PAM' columns are now numeric in the modified_data.
check_and_convert_columns <- function(dataset) {
  # Check if the column 'Site' is not a factor, then convert to factor
  if (!is.factor(dataset$Site)) {
    dataset$Site <- as.factor(dataset$Site)
  }
  # Check if the column 'Condition' is not a factor, then convert to factor
  if (!is.factor(dataset$Condition)) {
    dataset$Condition <- as.factor(dataset$Condition)
  }
  # Check if the column 'Species' is not a factor, then convert to factor
  if (!is.factor(dataset$Species)) {
    dataset$Species <- as.factor(dataset$Species)
  }
  # Check if the column 'Genotype' is not a factor, then convert to factor
  if (!is.factor(dataset$Genotype)) {
    dataset$Genotype <- as.factor(dataset$Genotype)
  }
  # Check if the column 'Temperature' is not numeric, then convert to numeric
  if (!is.numeric(dataset$Temperature)) {
    dataset$Temperature <- as.numeric(dataset$Temperature)
  }
  # Check if the column 'PAM' is not numeric, then convert to numeric
  if (!is.numeric(dataset$PAM)) {
    dataset$PAM <- as.numeric(dataset$PAM)
  }
  return(dataset)
}

#' Process and Validate CBASS Dataset
#'
#' This function processes and validates a dataset to ensure it contains all the mandatory columns required for further processing.
#' If any mandatory columns are missing, it raises an error with the list of missing columns.
#' Additionally, the function checks and converts the columns in the dataset.
#'
#' @param dataset A data frame representing the CBASS dataset to be processed and validated.
#'
#' @return A processed and validated CBASS dataset with appropriate data types for its columns.
#'
#' @seealso \code{\link{dataset_has_mandatory_columns}}, \code{\link{check_and_convert_columns}}
#'
#' @import rlog
#'
#' @examples
#' data(cbass_dataset) # Assuming a dataset named 'cbass_dataset' is available in the environment
#' processed_dataset <- process_and_validate_cbass_dataset(cbass_dataset)
#'
#' @export
process_and_validate_cbass_dataset <- function(dataset) {
  rlog::log_info("Check if the dataset has all mandatory columns")
  if (!dataset_has_mandatory_columns(dataset)) {
    missing_columns <- setdiff(mandatory_columns(), names(dataset))
    stop(rlog::log_error(
      paste(
        "Error: Dataset is missing mandatory columns:",
        paste(missing_columns, collapse = ", ")
      )
    ))
  }
  rlog::log_info("Convert and check columns datatypes in Dataset")
  dataset <- check_and_convert_columns(dataset)
  rlog::log_info("Your dataset passes all check!")
  return(dataset)
}
