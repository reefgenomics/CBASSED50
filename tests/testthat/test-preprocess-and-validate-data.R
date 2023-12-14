# Test for the `mandatory_columns()` function
test_that("mandatory_columns returns the correct vector of mandatory columns", {
  expected <- c(
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
  result <- mandatory_columns()
  expect_equal(result, expected)
})

# Tests for the `dataset_has_mandatory_columns()` function
test_that("dataset_has_mandatory_columns returns TRUE when all mandatory columns are present", {
  sample_data <- data.frame(
    Date = c("2023-07-31", "2023-08-01", "2023-08-02"),
    Country = c("Country A", "Country B", "Country C"),
    Site = c("Site X", "Site Y", "Site Z"),
    Condition = c("Condition 1", "Condition 2", "Condition 3"),
    Species = c("Species 1", "Species 2", "Species 3"),
    Genotype = c("Genotype A", "Genotype B", "Genotype C"),
    Temperature = c(30.2, 31.5, 29.8),
    Timepoint = c(420, 420, 420),
    PAM = c(0.5, 0.6, 0.8)
  )

  result <- dataset_has_mandatory_columns(sample_data)
  expect_true(result)
})

test_that("dataset_has_mandatory_columns returns FALSE when any mandatory column is missing", {
  missing_columns_data <- data.frame(
    Label = c("A", "B", "C"),
    Date = c("2023-07-31", "2023-08-01", "2023-08-02")
  )

  result <- dataset_has_mandatory_columns(missing_columns_data)
  expect_false(result)
})

# Test for the `convert_columns()` function
test_that("convert_columns converts columns to the correct types", {
  data <- data.frame(
    Site = c("A", "B", "C"),
    Condition = c("Control", "Experimental", "Control"),
    Species = c("Species1", "Species2", "Species1"),
    Genotype = c("GenotypeA", "GenotypeB", "GenotypeA"),
    Temperature = c("25", "28", "30"),
    PAM = c("0.4", "0.6", "0.7")
  )

  modified_data <- convert_columns(data)

  # Assert that the 'Site', 'Condition', 'Species', and 'Genotype' columns are factors
  expect_s3_class(modified_data$Site, "factor")
  expect_s3_class(modified_data$Condition, "factor")
  expect_s3_class(modified_data$Species, "factor")
  expect_s3_class(modified_data$Genotype, "factor")

  # Assert that the 'Temperature' and 'PAM' columns are numeric
  expect_type(modified_data$Temperature, "double")
  expect_type(modified_data$PAM, "double")
})

# Tests for the `check_enough_unique_temperature_values` function
test_that("check_enough_unique_temperature_values returns TRUE when there are enough unique values", {
  data <- data.frame(Temperature = c(25, 30, 25, 35, 28, 28))
  result <- check_enough_unique_temperature_values(data)
  expect_true(result)
})

test_that("check_enough_unique_temperature_values returns FALSE when there are not enough unique values", {
  data <- data.frame(Temperature = c(25, 25, 25, 25))
  result <- check_enough_unique_temperature_values(data)
  expect_false(result)
})

# Tests for `validate_cbass_dataset` function
test_that("validate_cbass_dataset throws an error when mandatory columns are missing", {
  missing_columns_data <- data.frame(
    Label = c("A", "B", "C"),
    Date = c("2023-07-31", "2023-08-01", "2023-08-02")
  )

  expect_error(validate_cbass_dataset(missing_columns_data))
})

test_that("validate_cbass_dataset throws an error when there are not enough unique temperature values", {
  data <- data.frame(Temperature = c(25, 25, 25, 25))

  expect_error(validate_cbass_dataset(data))
})

test_that("validate_cbass_dataset returns TRUE for a valid dataset", {
  sample_data <- data.frame(
    Date = c("2023-07-31", "2023-08-01", "2023-08-02", "2023-09-02"),
    Country = c("Country A", "Country B", "Country C", "Country A"),
    Site = c("Site X", "Site Y", "Site Z", "Site Z"),
    Condition = c("Condition 1", "Condition 2", "Condition 3", "Condition 2"),
    Species = c("Species 1", "Species 2", "Species 3", "Species 1"),
    Genotype = c("Genotype A", "Genotype B", "Genotype C", "Genotype B"),
    Temperature = c(30.2, 31.5, 29.8, 29.0),
    Timepoint = c(420, 420, 420, 420),
    PAM = c(0.5, 0.6, 0.8, 0.7)
  )

  result <- validate_cbass_dataset(sample_data)
  expect_true(result)
})
