# CBASSED50

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14295140.svg)](https://doi.org/10.5281/zenodo.14295140)

## Overview

R package to process CBASS-derived PAM data. Minimal requirements are PAM data (or data from any other continuous variable that changes with temperature, e.g. relative bleaching scores) from 4 samples (e.g., nubbins) subjected to 4 temperature profiles of at least 2 colonies from 1 coral species from 1 site. Please refer to the following papers for in-depth information regarding CBASS acute thermal stress assays, ED50 thermal thresholds, etc.

Voolstra, C. R., Buitrago-López, C., Perna, G., Cárdenas, A., Hume, B. C. C., Rädecker, N., & Barshis, D. J. (2020). Standardized Short-Term Acute Heat Stress Assays Resolve Historical Differences in Coral Thermotolerance across Microhabitat Reef Sites. Global Change Biology 26 (8). Wiley: 4328–43. <https://doi.org/10.1111/gcb.15148> 

Evensen, N. R., Parker, K. E., Oliver, T. A., Palumbi, S. R., Logan, C. A., Ryan, J. S., Klepac, C. N., Perna, G., Warner, M. E., Voolstra, C. R., & Barshis, D. J. (2023). The Coral Bleaching Automated Stress System (CBASS): A low‐cost, portable system for standardized empirical assessments of coral thermal limits. Limnology and Oceanography, Methods / ASLO, 21(7), 421--434. <https://doi.org/10.1002/lom3.10555>

Voolstra, C. R., Alderdice, R., Colin, L., Staab, S., Apprill, A., and Raina, J.-R. (2025). Standardized Methods to Assess the Impacts of Thermal Stress on Coral Reef Marine Life. Annual Review of Marine Science 17 (1). Annual Reviews: 193–226. <https://doi.org/10.1146/annurev-marine-032223-024511> 

## Get Started

### Install CBASSED50

Install the current version of CBASSED50 from CRAN:

``` r
install.packages("CBASSED50")
```

### Demo File

Download [CBASSED50_tutorial.qmd](CBASSED50_tutorial.qmd). GitHub allows you to do this directly from the web interface:

<p align="center">

<img src="https://github.com/reefgenomics/CBASSED50/assets/83506881/b6c9f376-f4b6-46f8-87c2-dce0ccb50ad3"/>

</p>

This is a document with a notebook interface that contains explanatory text together with the code. Open the document in [RStudio](https://quarto.org/docs/get-started/hello/rstudio.html) and explore it.

RStudio will offer to install missing packages required for running the [CBASSED50_tutorial.qmd](CBASSED50_tutorial.qmd), please do this:

<p align="center">

<img src="https://github.com/reefgenomics/CBASSED50/assets/83506881/c90752eb-a487-4560-825d-ac5854f5920f"/>

</p>

### Input file format

An example [input file](https://github.com/reefgenomics/CBASSED50/blob/main/examples/cbass_dataset.csv) can be downloaded from this repository.

The R package contains an internal dataset. Alternativley, you can run demo using your own inputfile for processing (CSV or XLSX format).

The following columns are mandatory:

- `Project` free text field; we recommend to use a unique identifier for 
  your project, e.g. `202211_DEU_Zugspitze-Feldberg` (YYYYMMDD_Country_Site).
- `Date` format YYYYMMDD.
- `Country` format 3-letter [ISO country code](https://countrycode.org).
- `Latitude` and `Longitude` in decimal degrees (e.g., 47.42123, 10.98632).
- `Site` free text field (e.g., name of the reef).
- `Condition` Descriptor to set apart samples from the same species and 
  site, e.g. probiotic treatment vs. control; nursery vs. wild; diseased vs.
  healthy; can be used to designate experimental treatments besides heat 
  stress. If no other treatments, write 'not available'.
- `Species` free text field; we recommend providing the name of the coral 
  as accurate as possible, e.g. _Porites lutea_ or _Porites_ sp.
- `Genotype` free text field; denotes samples/fragments/nubbins from 
  distinct colonies in a given dataset; we recommend to use integers, i.e. 1, 2, 3, 4, 5, etc.
- `Temperature` CBASS treatment temperatures; must be ≥ 4 different 
  temperatures; must be integer; e.g. 30, 33, 36, 39. Typical CBASS 
  temperature ranges are average summer mean MMM, MMM+3°C, MMM+6°C, MMM+9°C).
- `Timepoint` timepoint of PAM measurements in minutes from start of the 
  thermal cycling profile; typically: 420 (7 hours after start, i.e., after 
  ramping up, heat-hold, ramping down) or 1080 (18 hours after start, i.e. 
  at the end of the CBASS thermal cycling profile); differences in ED50s 
  between timepoints 420 and 1080 may be indicative of resilience/recovery 
  (if 1080 ED50 > 420 ED50) or collapse (if 1080 ED50 < 420 ED50).
- `Pam_value` Fv/Fm value of a given sample (format: ≥0 and ≤1, e.g. 0.387); note 
  that technically any continuous variable can be used for ED50 calculation 
  (e.g., coral whitening; black/white pixel intensity; etc.) and be 
  provided in this column.

This is how your input file should look like:

| Project                       | Date     | Country | Latitude | Longitude | Site      | Condition | Species           | Genotype | Temperature | Timepoint | Pam_value |
|-------------------------------|----------|---------|----------|-----------|-----------|-----------|-------------------|----------|-------------|-----------|-----------|
| 202211_DEU_Zugspitze-Feldberg | 20221114 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 1        | 29          | 420       | 0.636     |
| 202211_DEU_Zugspitze-Feldberg | 20221114 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 2        | 29          | 420       | 0.615     |
| 202211_DEU_Zugspitze-Feldberg | 20221114 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 3        | 29          | 420       | 0.64      |
| 202211_DEU_Zugspitze-Feldberg | 20221114 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 4        | 29          | 420       | 0.669     |
| 202211_DEU_Zugspitze-Feldberg | 20221114 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 5        | 29          | 420       | 0.64      |
| 202211_DEU_Zugspitze-Feldberg | 20221115 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 6        | 29          | 420       | 0.664     |
| 202211_DEU_Zugspitze-Feldberg | 20221115 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 7        | 29          | 420       | 0.638     |
| 202211_DEU_Zugspitze-Feldberg | 20221115 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 8        | 29          | 420       | 0.685     |
| 202211_DEU_Zugspitze-Feldberg | 20221115 | DEU     | 47.42123 | 10.98632  | Zugspitze | Nursery   | Acropora germania | 9        | 29          | 420       | 0.658     |

## Contributing

If you want to contribute to a project and make it better, your help is very welcome.

You can always report an [issue](https://github.com/reefgenomics/CBASSED50/issues) or fork this repository, implement/fix your feature, and create a pull request.

## FAQ

In Ubuntu, you may face the issue with R package dependencies installation. To fix this, you should install missing system libraries first.

### Error installing 'devtools'

``` commandline
sudo apt-get install \
  libssl-dev \
  libfontconfig1-dev \
  libxml2-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libcurl4-openssl-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev
```

### Error installing 'mvtnorm'

``` commandline
sudo apt-get install gfortran liblapack-dev libblas-dev
```

### Error installing 'nloptr'

``` commandline
sudo apt-get install cmake
```

## Getting Help

You can always report the GitHub [issue](https://github.com/reefgenomics/CBASSED50/issues) or email the current maintainer: [Luigi Colin](mailto:reefgenomics@gmail.com).

## Cite Us

If you use this software, please cite it as below:

``` commandline
Iakovleva, Y., Colin, L., & Voolstra, C. R. (2025).
CBASSED50: R package to process CBASS-derived PAM data.
Zenodo. https://doi.org/10.5281/zenodo.8370644.
```
