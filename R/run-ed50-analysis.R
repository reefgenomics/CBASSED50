library(drc)

# Create a new column 'GroupingProperty' by merging the specified columns
define_grouping_property <-
  function(dataset, grouping_properties, sep = "_") {
    dataset$GroupingProperty <- as.factor(do.call(paste, c(dataset[grouping_properties], sep = sep)))
    rlog::log_debug(
      glue::glue("The list of defined groups: {paste(levels(dataset$GroupingProperty), collapse = ', ')}")
    )
    return(dataset)
  }

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
    print(subset_data)
    model <- drm(formula, data = subset_data, fct = LL.3(names = c('Slope', 'Max', 'ED50')))
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
    data.frame(ED50 = intercept, row.names = model_name)
  })

  # Combine the results into a single dataframe
  df <- do.call(rbind, results)
  return(df)
}
