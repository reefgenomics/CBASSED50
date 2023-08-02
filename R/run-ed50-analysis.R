# Create a new column 'GroupingProperty' by merging the specified columns
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
    model <- drc::drm(formula, data = subset_data, fct = drc::LL.3(names = c('Slope', 'Max', 'ED50')))
    # Attach the group value to the model for reference
    model$group_value <- group_value
    model
  })

  # Create a named list of models
  models <- setNames(models, unique(dataset[[grouping_property]]))

  return(models)
}

get_ed50_by_grouping_property <- function(models) {
  # Extract the model name and intercept using lapply
  results <- lapply(names(models), function(model_name) {
    coefficients <- models[[model_name]]$coefficients
    intercept <- coefficients["ED50:(Intercept)"]
    data.frame(ED50 = intercept, GroupingProperty = model_name, row.names = model_name)
  })

  # Combine the results into a single dataframe
  df <- do.call(rbind, results)
  return(df)
}
