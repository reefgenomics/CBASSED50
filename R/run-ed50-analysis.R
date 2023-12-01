#' Define Grouping Property Column
#'
#' This function creates a new column 'GroupingProperty' in the provided dataset by merging specified columns using a specified separator.
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
#' This function fits dynamic regression models (DRMs) to a given dataset using the specified grouping properties and DRM formula.
#'
#' @param dataset A data frame containing the dataset on which to fit the DRMs.
#' @param grouping_properties A character vector specifying the names of columns in the dataset that will be used as grouping properties for fitting separate DRMs.
#' @param drm_formula A formula specifying the dynamic regression model to be fitted. This formula should follow the standard R formula syntax (e.g., y ~ x1 + x2).
#'
#' @return A list of fitted DRM models, with each element corresponding to a unique combination of grouping property values.
#' @export
#'
#' @examples
#' fit_drms(data, c("Site", "Condition", "Species", "Genotype"), "PAM ~ Temperature")
#'
#' @keywords modeling
fit_drms <- function(dataset, grouping_properties, drm_formula) {
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
    model <- drc::drm(formula, data = subset_data,
                      curveid = Genotype,
                      fct = drc::LL.3(names = c('Hill', 'Max', 'ED50')))
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
    intercept <- coefficients["ED50:(Intercept)"]
    data.frame(ED50 = round(intercept, digits = 2), GroupingProperty = model_name)
  })

  # Combine the results into a single dataframe
  df <- do.call(rbind, results)
  rownames(df) <- NULL
  return(df)
}
