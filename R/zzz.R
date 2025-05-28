.onLoad <- function(libname, pkgname) {
  utils::globalVariables(c(
    "Genotype", "GroupingProperty", "Prediction", "Upper", "Lower", "Condition", "Species", "Temperature",
    "ED5", "ED50", "ED95", "Mean_ED5", "Mean_ED50", "Mean_ED95",
    "SD_ED5", "SD_ED50", "SD_ED95", "SE_ED5", "SE_ED50", "SE_ED95",
    "Conf_Int_5", "Conf_Int_50", "Conf_Int_95",
    "Pam_value", "PredictedPAM", "y"
  ))
}
