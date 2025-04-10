
# This line declares global variables to avoid R CMD check warnings about undefined global variables.
# The specified variable names ("Genotype", "GroupingProperty", "Prediction", "Upper", "Lower") are 
# used in the script but may not be explicitly defined in the local environment. By using 
utils::globalVariables(c("Genotype", "GroupingProperty", "Prediction", "Upper", "Lower"))


#' Define Grouping Property Column
#'
#' This function creates a new column 'GroupingProperty' in the provided dataset
#' by merging specified columns using a specified separator.
#' The new column is created as a factor variable.
#'
#' @param dataset A data frame where the new 'GroupingProperty' column will be added.
#' @param grouping_properties A character vector containing the names of the columns to be merged.
#' @param sep A character string used as a separator when merging columns (default is "_").
#'
#' @return A data frame with the added 'GroupingProperty' column.
#'
#' @export
#'
#' @examples
#' # Create a sample data frame
#' data <- data.frame(Category = c("A", "B", "C"),
#'                    Subcategory = c("X", "Y", "Z"),
#'                    Value = c(10, 20, 30))
#'
#' # Define grouping property using 'Category' and 'Subcategory'
#' new_data <- define_grouping_property(data, c("Category", "Subcategory"), sep = "-")
#'
#' # Resulting data frame:
#' #   Category Subcategory Value GroupingProperty
#' # 1        A           X    10              A-X
#' # 2        B           Y    20              B-Y
#' # 3        C           Z    30              C-Z
define_grouping_property <-
  function(dataset, grouping_properties, sep = "_") {
    dataset$GroupingProperty <- as.factor(do.call(paste, c(dataset[grouping_properties], sep = sep)))
    rlog::log_debug(
      glue::glue("The list of defined groups: {paste(levels(dataset$GroupingProperty), collapse = ', ')}")
    )
    return(dataset)
  }

#' Fit Dynamic Regression Models (DRMs)
#'
#' This function fits dynamic regression models (DRMs) to a given dataset
#' using the specified grouping properties and DRM formula.
#'
#' @param dataset A data frame containing the dataset on which to fit the DRMs.
#' @param grouping_properties A character vector specifying the names of columns
#' in the dataset that will be used as grouping properties
#' for fitting separate DRMs.
#' @param drm_formula A formula specifying the dynamic regression model
#' to be fitted. This formula should follow the standard R formula syntax
#' (e.g., y ~ x1 + x2).
#' @param is_curveid A boolean value indicating
#' if you want to use this parameter to fit the model
#' @param LL.4 Logical. If TRUE, the LL.4 model is used instead of LL.3.
#' LL.3 is preferred, as PAM data is expected to never be lower than zero.
#' In cases with overly correlated data and steep slopes, LL.4 allows the
#' lower limit to vary, which can help to better fit the model.
#'
#' @importFrom drc drm
#' @importFrom dplyr mutate
#' @importFrom stats as.formula setNames
#' @return A list of fitted DRM models,
#' with each element corresponding to a unique combination of grouping property values.
#' @export
#'
#' @examples
#' data(cbass_dataset)
#' preprocessed_data <- preprocess_dataset(cbass_dataset)
#' fit_drms(preprocessed_data,
#'        c("Site", "Condition", "Species", "Genotype"),
#'         "PAM ~ Temperature")
#'
#' @keywords modeling
fit_drms <- function(dataset, grouping_properties, drm_formula, is_curveid = FALSE, LL.4 = FALSE) {
  # Input validation
  if (!is.data.frame(dataset)) {
    stop("Input dataset must be a data frame.")
  }

  if (!all(grouping_properties %in% names(dataset))) {
    invalid_properties <- grouping_properties[!grouping_properties %in% names(dataset)]
    stop(
      glue::glue(
        "Invalid grouping properties:\n",
        "{paste(invalid_properties, collapse = ', ')}.\n",
        "Please provide valid column names."
      )
    )
  }

  # add Grouping Property column
  dataset <- define_grouping_property(dataset, grouping_properties)

  grouping_property <- "GroupingProperty"

  formula <- as.formula(paste(drm_formula))

  models <- lapply(unique(dataset[[grouping_property]]), function(group_value) {
    subset_data <- dataset[dataset[[grouping_property]] == group_value, ]

    # Conditionaly switch to LL.4 
    if (LL.4) {
      fct <- drc::LL.4(names = c('Hill', 'Min', 'Max', 'ED50'))
    } else {
      fct <- drc::LL.3(names = c('Hill', 'Max', 'ED50'))
    }

    # Conditionally include curveid argument
    if (is_curveid) {
      model <- drc::drm(
        formula, data = subset_data,
        curveid = Genotype,
        fct = fct)
    } else {
      model <- drc::drm(
        formula, data = subset_data,
        fct = fct)
    }
  })

  # Create a named list of models
  models <- setNames(models, unique(dataset[[grouping_property]]))

  return(models)
}

#' Get ED50 by Grouping Property
#'
#' This function takes a list of models and extracts the ED50 value for each model based on a specified grouping property.
#' The ED50 value is extracted from the model's coefficients and is associated with the intercept term.
#'
#' @param models A list of models where each element represents a model object containing coefficients.
#'
#' @return A data frame containing the ED50 values along with their corresponding grouping property.
#'         Each row represents a model's ED50 value and its associated grouping property.
#'
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
#' #' ed50_data <- get_ed50_by_grouping_property(model_list)
#'
#' # Resulting data frame structure:
#' #   ED50     GroupingProperty
#' # 1 ED50_value_1 Group1
#' # 2 ED50_value_2 Group2
get_ed50_by_grouping_property <- function(models) {
  # Extract the model name and intercept using lapply
  results <- lapply(names(models), function(model_name) {
    coefficients <- models[[model_name]]$coefficients
    ed50_indexes <- grep("^ED50", names(coefficients))
    ed50_raw_values <- coefficients[ed50_indexes]
    ed50_values <- unname(ed50_raw_values)
    genotype_names <- sub("^ED50:", "", names(ed50_raw_values))
    data.frame(
      ED50 = round(ed50_values, digits = 2),
      GroupingProperty = paste(model_name, genotype_names, sep = "_")) %>%
      mutate(GroupingProperty = gsub("_\\(Intercept\\)", "", GroupingProperty))
  })

  # Combine the results into a single dataframe
  df <- do.call(rbind, results)
  rownames(df) <- NULL
  return(df)
}

#' Get ED05s, ED50s and ED95s by Grouping Property
#'
#' This function takes a list of models and extracts the ED05s,
#' ED50s and ED95s values for each model based on a specified grouping
#' property. The ED05s, ED50s and ED95s values is extracted from
#' the model's coefficients and is associated with the intercept term.
#'
#' @param models A list of models where each element represents a model object containing coefficients.
#'
#' @return A data frame containing the ED50 values along with their corresponding grouping property.
#'         Each row represents a model's ED50 value and its associated grouping property.
#'
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
#' #' eds_data <- get_all_ed_by_grouping_property(model_list)
#'
#' # Resulting data frame structure:
#' #   ED5         ED50         ED95         GroupingProperty
#' # 1 ED5_value_1 ED50_value_1 ED95_value_1 Group1
#' # 2 ED5_value_2 ED50_value_2 ED95_value_2 Group2
get_all_ed_by_grouping_property <- function(models) {
  # Extract the model name and intercept using lapply
  results <- lapply(names(models), function(model_name) {
    coefficients <- models[[model_name]]$coefficients
    ed50_indexes <- grep("^ED50", names(coefficients))
    ed50_raw_values <- coefficients[ed50_indexes]
    ed50_values <- unname(ed50_raw_values)
    genotype_names <- sub("^ED50:", "", names(ed50_raw_values))
    # Run ED() and store the result
    ed95_df <- as.data.frame(drc::ED(models[[model_name]], c(95), display = F))
    ed5_df <- as.data.frame(drc::ED(models[[model_name]], c(5), display = F))

    # Extract genotype names from row names
    ed95_df$Genotype <- gsub(":95", "", rownames(ed95_df))
    ed5_df$Genotype <- gsub(":05", "", rownames(ed95_df))
    # Select only the Genotype and Estimate columns
    rownames(ed95_df) <- ed95_df$Genotype
    rownames(ed5_df) <- ed5_df$Genotype

    # Extract genotype names from row names
    ed95_df$Genotype <- gsub("e:", "", ed95_df$Genotype)
    ed5_df$Genotype <- gsub("e:", "", ed95_df$Genotype)
    data.frame(
      ED5 = round(ed5_df$Estimate, digits = 2),
      ED50 = round(ed50_values, digits = 2),
      ED95 = round(ed95_df$Estimate, digits = 2),
      GroupingProperty = paste(model_name, genotype_names, sep = "_")) %>%
      mutate(GroupingProperty = gsub("_\\(Intercept\\)", "", GroupingProperty))
  })

  # Combine the results into a single dataframe
  df <- do.call(rbind, results)
  rownames(df) <- NULL
  return(df)
}