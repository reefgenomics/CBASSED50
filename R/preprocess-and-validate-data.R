#' Read Data Function
#'
#' Reads data from a file based on its format (Excel or CSV).
#'
#' @param file_path Character string specifying the path to the input file.
#' @return A data frame containing the read data.
#' @details This function determines the file format based on the file extension
#' and uses appropriate methods to read data from either Excel (xls, xlsx) or
#' CSV (csv, txt) files.
#' @examples
#' # Read data from an Excel file
#' read_data("path/to/excel_file.xlsx")
#'
#' # Read data from a CSV file
#' read_data("path/to/csv_file.csv")
#'
#' @export
read_data <- function(file_path) {
  ext <- tools::file_ext(file_path)

  if (ext %in% c("xls", "xlsx")) {
    return(read_excel(file_path))
  } else if (ext %in% c("csv", "txt")) {
    return(read.csv(file_path))
  } else {
    stop("Unsupported file format. Please provide an Excel (xls, xlsx) or CSV (csv, txt) file.")
  }
}

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
#' [6] "Genotype"    "Temperature" "Timepoint"   "PAM"
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
      "Timepoint",
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
  result <- all(mandatory_columns() %in% names(dataset))
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
#' modified_data <- convert_columns(data)
#'
#' # The 'Site', 'Condition', 'Species', and 'Genotype' columns are now factors,
#' # and 'Temperature' and 'PAM' columns are now numeric in the modified_data.
convert_columns <- function(dataset) {
  # Check if the column 'Site' is not a factor, then convert to factor
  if (!is.factor(dataset$Site)) {
    rlog::log_info("`Site` column was converted to factor.")
    dataset$Site <- as.factor(dataset$Site)
  }
  # Check if the column 'Condition' is not a factor, then convert to factor
  if (!is.factor(dataset$Condition)) {
    rlog::log_info("`Condition` column was converted to factor.")
    dataset$Condition <- as.factor(dataset$Condition)
  }
  # Check if the column 'Species' is not a factor, then convert to factor
  if (!is.factor(dataset$Species)) {
    rlog::log_info("`Species` column was converted to factor.")
    dataset$Species <- as.factor(dataset$Species)
  }
  # Check if the column 'Genotype' is not a factor, then convert to factor
  if (!is.factor(dataset$Genotype)) {
    rlog::log_info("`Genotype` column was converted to factor.")
    dataset$Genotype <- as.factor(dataset$Genotype)
  }
  # Check if the column 'Temperature' is not numeric, then convert to numeric
  if (!is.numeric(dataset$Temperature)) {
    rlog::log_info("`Temperature` column was converted to numeric.")
    dataset$Temperature <- as.numeric(dataset$Temperature)
  }
  # Check if the column 'PAM' is not numeric, then convert to numeric
  if (!is.numeric(dataset$PAM)) {
    rlog::log_info("`PAM` column was converted to numeric.")
    dataset$PAM <- as.numeric(dataset$PAM)
  }
  return(dataset)
}


#' Check if the dataset contains enough unique temperature values
#'
#' @param dataset The input dataset containing the 'Temperature' column to be analyzed.
#'        The 'Temperature' column should be numeric representing
#'        temperature values.
#'
#' @return Logical value (TRUE or FALSE) indicating whether there are enough unique
#'         temperature values (at least 4) in the dataset.
#'
#' @examples
#' data <- data.frame(Temperature = c(25, 30, 25, 35, 28, 28))
#' check_enough_unique_temperatures_values(data)
#' # Output: TRUE
check_enough_unique_temperature_values <- function(dataset) {
  if (length(unique(dataset$Temperature)) < 4) {
    return(FALSE)
  }
  return(TRUE)
}

#' Preprocesses the data by converting and checking column data types.
#'
#' This function preprocesses the input data by performing checks on column data types
#' and converting them if necessary. It ensures that the dataset meets certain requirements
#' before further analysis or modeling.
#'
#' @param dataset A data frame containing the dataset to be preprocessed.
#'
#' @return A preprocessed data frame with converted and validated column data types.
#'
#' @export
#'
#' @examples
#' # Load a sample dataset
#' data("cbass_dataset")
#' # Preprocess the dataset
#' preprocessed_data <- preprocess_data(cbass_dataset)
preprocess_dataset <- function(dataset) {
  dataset <- convert_columns(dataset)
  rlog::log_info("Removing rows with missing data...")
  dataset <- dataset[complete.cases(dataset), ]
  return(dataset)
}

#' Validate CBASS Dataset
#'
#' This function validates a dataset to ensure it contains all the mandatory columns required for further processing.
#' If any mandatory columns are missing, it raises an error with the list of missing columns.
#'
#' @param dataset A data frame representing the CBASS dataset to be processed and validated.
#'
#' @return A processed and validated CBASS dataset with appropriate data types for its columns.
#'
#' @seealso \code{\link{dataset_has_mandatory_columns}}, \code{\link{convert_columns}}, \code{\link{check_enough_unique_temperature_values}}
#'
#' @importFrom rlog log_info log_error
#' @importFrom glue glue
#'
#' @examples
#' # Assuming a dataset named 'cbass_dataset' is available in the environment
#' data(cbass_dataset)
#' processed_dataset <- process_and_validate_cbass_dataset(cbass_dataset)
#'
#' @export
validate_cbass_dataset <- function(dataset) {
  rlog::log_info("Checking if the dataset has all mandatory columns...")
  if (!dataset_has_mandatory_columns(dataset)) {
    missing_columns <- setdiff(mandatory_columns(), names(dataset))
    stop(rlog::log_error(
      paste(
        "Dataset is missing mandatory columns:",
        paste(missing_columns, collapse = ", ")
      )
    ))
  }
  rlog::log_info("Checking if the dataset has enough temperature values...")
  if (!check_enough_unique_temperature_values(dataset)) {
    stop(rlog::log_error(
      glue::glue(
        "Dataset does not have enough unique temperature values: ",
        "{length(unique(dataset$Temperature))}. ",
        "There should be at least 4 unique values!"
      )
    ))
  }
  rlog::log_info("Your dataset passes all checks!")
  rlog::log_info(
    glue::glue(
      "The dataset contains:\n",
      " * {length(unique(dataset$Site))} unique Sites\n",
      " * {length(unique(dataset$Condition))} unique Conditions\n",
      " * {length(unique(dataset$Species))} unique Species\n",
      " * {length(unique(dataset$Genotype))} unique Genotypes",
    )
  )
  return(TRUE)
}
