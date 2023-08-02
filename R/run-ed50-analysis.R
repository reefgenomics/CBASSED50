library(drc)

# Create a new column 'GroupingProperty' by merging the specified columns
define_grouping_property <-
  function(dataset, grouping_properties, sep = "_") {
    dataset$GroupingProperty <- as.factor(do.call(paste, c(dataset[grouping_properties], sep = sep)))
    return(dataset)
  }

fit_drms <- function(dataset, grouping_properties, drm_formula) {
  # Input validation
  if (!is.data.frame(dataset)) {
    stop("Input dataset must be a data frame.")
  }

  if (!all(grouping_properties %in% names(dataset))) {
    stop("Invalid grouping properties. Please provide valid column names.")
  }

  # add Grouping Property column
  dataset <- define_grouping_property(dataset, grouping_properties)

  grouping_property <- "GroupingProperty"

  formula <- as.formula(paste(drm_formula))

  models <- lapply(unique(dataset[[grouping_property]]), function(group_value) {
    subset_data <- dataset[dataset[[grouping_property]] == group_value, ]
    model <- drm(formula, data = subset_data, fct = LL.3(names = c('Slope', 'Max', 'ED50')))
    # Attach the group value to the model for reference
    model$group_value <- group_value
    model
  })

  # Create a named list of models
  models <- setNames(models, unique(dataset[[grouping_property]]))

  return(models)
}

