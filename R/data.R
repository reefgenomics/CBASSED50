#' CBASS Dataset
#'
#' A dataset containing example simulated experimental data.
#'
#' This dataset provides experimental data with various attributes for
#' demonstration and testing purposes.
#'
#' @docType data
#' @name cbass_dataset
#' @format A data frame with 240 observations and 9 variables:
#'   \describe{
#'     \item{Project}{Name to identify the project/experiment.}
#'     \item{Latitude}{Latitude of the observation collection site in decimal format.}
#'     \item{Longitude}{Longitude of the observation collection site in decimal format.}
#'     \item{Date}{Date of the observation in YYYYMMDD format.}
#'     \item{Country}{Country of the observation in 3-letter \href{https://countrycode.org}{ISO country code} format.}
#'     \item{Site}{Site of the observation, e.g., name of the reef.}
#'     \item{Condition}{Descriptor to set apart samples from the same species and site, e.g. probiotic treatment vs. control; nursery vs. wild; diseased vs. healthy; can be used to designate experimental treatments besides heat stress. If no other treatments, write 'not available'.}
#'     \item{Species}{Species of the observation. We recommend providing the name of the coral as accurate as possible, e.g. \emph{Porites lutea} or \emph{Porites} sp.}
#'     \item{Genotype}{Denotes samples/fragments/nubbins from distinct colonies in a given dataset; we recommend to use integers, i.e. 1, 2, 3, 4, 5, etc.}
#'     \item{Temperature}{CBASS treatment temperatures; must be \eqn{\ge} 4 different temperatures; must be integer; e.g. 30, 33, 36, 39. Typical CBASS temperature ranges are average summer mean MMM, MMM+3°C, MMM+6°C, MMM+9°C).}
#'     \item{Timepoint}{Timepoint of PAM measurements in minutes from start of the thermal cycling profile; typically: 420 (7 hours after start, i.e., after ramping up, heat-hold, ramping down) or 1080 (18 hours after start, i.e. at the end of the CBASS thermal cycling profile); differences in ED50s between timepoints 420 and 1080 may be indicative of resilience/recovery (if 1080 ED50 > 420 ED50) or collapse (if 1080 ED50 < 420 ED50).}
#'     \item{Pam_value}{Fv/Fm value of a given sample (format: \eqn{\ge}0 and \eqn{\le}1, e.g. 0.387); note that technically any continuous variable can be used for ED50 calculation (e.g., coral whitening; black/white pixel intensity; etc.) and be provided in this column.}
#'   }
#'
#' @examples
#' # Load the sample dataset
#' data(cbass_dataset)
#' head(cbass_dataset)
#'
#' @usage data(cbass_dataset)
"cbass_dataset"
