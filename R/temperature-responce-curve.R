#' Define Temperature Ranges
#'
#' This function takes a vector of temperatures and generates
#' a sequence of temperature values that span the range of input temperatures.
#'
#' @param temperatures A numeric vector containing temperature values.
#' @param n An integer specifying the length of the output sequence.
#' Default is 100.
#'
#' @return A numeric vector containing a sequence of temperature values
#' ranging from the minimum temperature to the maximum temperature
#' plus 1, evenly spaced based on the specified length.
#'
#' @export
#'
#' @examples
#' temperatures <- c(10, 15, 20, 25, 30)
#' define_temperature_ranges(temperatures)
define_temperature_ranges <- function(temperatures, n = 100) {
  return(
    seq(min(temperatures), max(temperatures) + 1, length = n)
  )
}

#' Predict the temperature values
#'
#' This function takes a list of models and generates
#' a sequence of temperature values that span the range of input temperatures.
#'
#' @param models A list of models where each element represents a model object containing coefficients.
#' @param temp_range the temperature range to be used for predictions from the function define_temperature_ranges
#'
#' @return A data frame containing the predicted PAM values for each temperature along with their corresponding grouping property. 
#' Each row represents a model's predicted PAM value and its associated grouping property and confidence interval.
#'
#' @examples
#' data(cbass_dataset)
#' preprocessed_data <- preprocess_dataset(cbass_dataset)
#'
#' models <- fit_drms(preprocessed_data,
#'                  c("Site", "Condition", "Species", "Timepoint"),
#'                    "Pam_value ~ Temperature", is_curveid = TRUE)
#' temp_ranges <- define_temperature_ranges(cbass_dataset$Temperature, n = 100)
#' predict_temperature_values(models, temp_ranges)
#' 
# ' # PredictedPAM    Lower      Upper      GroupingProperty  Temperature
# ' # PredictedPAM_1  Min_PAM_1  Max_PAM_1  Group1            temp_1
# ' # PredictedPAM_2  Min_PAM_2  Max_PAM_2  Group1            temp_2
# ' # PredictedPAM_3  Min_PAM_3  Max_PAM_3  Group1            temp_3
# ' # PredictedPAM_4  Min_PAM_4  Max_PAM_4  Group2            temp_1
# ' # PredictedPAM_5  Min_PAM_5  Max_PAM_5  Group2            temp_2
# ' # PredictedPAM_6  Min_PAM_6  Max_PAM_6  Group2            temp_3
#' @export
predict_temperature_values <- function(models, temp_range) {
  predictions <- lapply(
    models, function(model) {
      predictions <- predict(model,
                             data.frame(Temperature = temp_range),
                             interval="confidence",
                             level = 0.95)
      predictions
    }
  )
  return(predictions)
}

#' Transform Predictions to a Long-Format DataFrame
#'
#' This function takes a list of predictions and converts them into a long-format
#' data frame. Each prediction corresponds to a different temperature range.
#'
#' @param predictions A list of data frames where each data frame represents predictions for a specific temperature range. The data frames should have a common grouping property.
#' @param temp_range the temperature range to be used for predictions from the function define_temperature_ranges
#'
#' @return A long-format data frame containing the transformed predictions with columns for "GroupingProperty," "Temperature," and "PredictedPAM."
#'
#' @importFrom dplyr mutate rename arrange %>%
transform_predictions_to_long_dataframe <- function(predictions, temp_range) {
  grouping_property <- "GroupingProperty"
  data.frame(do.call(rbind, Map(cbind, predictions, GroupingProperty = names(predictions)))) %>%
    mutate(
      Temperature = rep(round(temp_range, 2), length(predictions)),
      Prediction = as.numeric(Prediction),
      Upper = as.numeric(Upper),
      Lower = as.numeric(Lower)
      ) %>%
    rename(PredictedPAM = Prediction)
}

#' Get Predicted PAM Values
#'
#' This function takes a list of models and a temperature range, and generates predicted PAM (Pulse Amplitude Modulation) values based on the provided models and temperature range.
#'
#' @param models A list of model objects representing PAM prediction models.
#' @param temp_range A numeric vector containing a sequence of temperature values for which PAM predictions will be generated.
#'
#' @return A data frame containing the predicted PAM values along with corresponding temperature values from the given temperature range.
#'
#'
#' @examples
#' # Load models and temperature range
#' # To load internal dataset that is provided with the R package
#' data("cbass_dataset")
#' cbass_dataset <- preprocess_dataset(cbass_dataset)
#' grouping_properties <- c("Site", "Condition", "Species", "Timepoint")
#' drm_formula <- "Pam_value ~ Temperature"
#'
#' # Make list of model
#' models <- fit_drms(cbass_dataset, grouping_properties, drm_formula, is_curveid = FALSE)
#' temp_ranges <- define_temperature_ranges(cbass_dataset$Temperature, n = 100)
#'
#' # Get predicted Pam_value values
#' predicted_pam <- get_predicted_pam_values(models, temp_ranges)
#'
#' @importFrom stats predict
#'
#' @seealso \code{\link{predict_temperature_values}}, \code{\link{transform_predictions_to_long_dataframe}}, \code{\link{define_temperature_ranges}}
#' \link{predict_temperature_values}
#' \link{transform_predictions_to_long_dataframe}
#' \link{define_temperature_ranges}
#' @keywords predicted PAM values temperature range model
#' @export
get_predicted_pam_values <- function(models, temp_range) {
  predictions <- predict_temperature_values(models, temp_range)  # Assuming the function predict_temperature_values() is defined elsewhere
  result <- transform_predictions_to_long_dataframe(predictions, temp_range)  # Assuming the function transform_predictions_to_long_dataframe() is defined elsewhere
  return(result)
}
