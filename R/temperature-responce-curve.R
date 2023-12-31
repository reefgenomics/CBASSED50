#' Define Temperature Ranges
#'
#' This function takes a vector of temperatures and generates a sequence of temperature values that span the range of input temperatures.
#'
#' @param temperatures A numeric vector containing temperature values.
#' @param n An integer specifying the length of the output sequence. Default is 100.
#'
#' @return A numeric vector containing a sequence of temperature values ranging from the minimum temperature
#' to the maximum temperature plus 1, evenly spaced based on the specified length.
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
#' @param predictions A list of data frames where each data frame represents
#'   predictions for a specific temperature range. The data frames should have
#'   a common grouping property.
#'
#' @return A long-format data frame containing the transformed predictions with
#'   columns for "GroupingProperty," "Temperature," and "PredictedPAM."
#'
#' @importFrom dplyr mutate rename arrange
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
#' @export
#'
#' @examples
#' # Load models and temperature range
#' models <- list(model1, model2, model3)  # Replace with actual model objects
#' temp_range <- define_temperature_ranges(temperatures)  # Replace with temperature range
#'
#' # Get predicted PAM values
#' predicted_pam <- get_predicted_pam_values(models, temp_range)
#'
#' @importFrom stats predict
#'
#' @seealso \code{\link{predict_temperature_values}}, \code{\link{transform_predictions_to_long_dataframe}}, \code{\link{define_temperature_ranges}}
#' @keywords predicted PAM values, temperature range, model
get_predicted_pam_values <- function(models, temp_range) {
  predictions <- predict_temperature_values(models, temp_range)  # Assuming the function predict_temperature_values() is defined elsewhere
  result <- transform_predictions_to_long_dataframe(predictions, temp_range)  # Assuming the function transform_predictions_to_long_dataframe() is defined elsewhere
  return(result)
}

