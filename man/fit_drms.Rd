% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run-ed50-analysis.R
\name{fit_drms}
\alias{fit_drms}
\title{Fit Dynamic Regression Models (DRMs)}
\usage{
fit_drms(
  dataset,
  grouping_properties,
  drm_formula,
  is_curveid = FALSE,
  LL.4 = FALSE
)
}
\arguments{
\item{dataset}{A data frame containing the dataset on which to fit the DRMs.}

\item{grouping_properties}{A character vector specifying the names of columns in the dataset that will be used as grouping properties for fitting separate DRMs.}

\item{drm_formula}{A formula specifying the dynamic regression model to be fitted.
This formula should follow the standard R formula syntax (e.g., y ~ x1 + x2).}

\item{is_curveid}{A boolean value indicating if you want to use this parameter to fit the model}

\item{LL.4}{Logical. If TRUE, the LL.4 model is used instead of LL.3.
LL.3 is preferred, as PAM data is expected to never be lower than zero.
In cases with overly correlated data and steep slopes, LL.4 allows the
lower limit to vary, which can help to better fit the model.}
}
\value{
A list of fitted DRM models,
with each element corresponding to a unique combination of grouping property values.
}
\description{
This function fits dynamic regression models (DRMs) to a given dataset
using the specified grouping properties and DRM formula.
}
\examples{
data(cbass_dataset)
preprocessed_data <- preprocess_dataset(cbass_dataset)
fit_drms(preprocessed_data,
       c("Site", "Condition", "Species", "Genotype"),
        "Pam_value ~ Temperature")

}
\keyword{modeling}
