# CBASSED50

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8370645.svg)](https://doi.org/10.5281/zenodo.8370645)

## Overview

The CBASSED50 R package to process CBASS-derived PAM data. Minimal requirements are PAM data (or data from any other continuous variable that decreases with temperature, e.g. relative bleaching scores) from 4 fragments subjected to 4 temperature profiles of at least 2 colonies from 1 coral species from 1 site. Please refer to the [CBASS method paper](https://aslopubs.onlinelibrary.wiley.com/doi/10.1002/lom3.10555) for in-depth information regarding CBASS acute thermal stress assays, ED50 thermal thresholds, etc.

Evensen, N. R., Parker, K. E., Oliver, T. A., Palumbi, S. R., Logan, C. A., Ryan, J. S., Klepac, C. N., Perna, G., Warner, M. E., Voolstra, C. R., & Barshis, D. J. (2023). The Coral Bleaching Automated Stress System (CBASS): A low‐cost, portable system for standardized empirical assessments of coral thermal limits. Limnology and Oceanography, Methods / ASLO, 21(7), 421--434. <https://doi.org/10.1002/lom3.10555>

## Get Started

### Demo File

To get started download [CBASSED50_demo.qmd](https://github.com/greenjune-ship-it/CBASSED50/blob/main/CBASSED50_demo.qmd). GitHub allows you to do this directly from the web interface:

<p align="center">

<img src="https://github.com/greenjune-ship-it/CBASSED50/assets/83506881/b6c9f376-f4b6-46f8-87c2-dce0ccb50ad3"/>

</p>

This is a document with a notebook interface that contains explanatory text together with the code. Open the document in [RStudio](https://quarto.org/docs/get-started/hello/rstudio.html) and explore it.

RStudio will offer to install missing packages required for running the Demo, please do this:

<p align="center">

<img src="https://github.com/greenjune-ship-it/CBASSED50/assets/83506881/c90752eb-a487-4560-825d-ac5854f5920f"/>

</p>

### Install CBASSED50

You can install the latest version of CBASSED50 from GitHub:

``` r
if(!require(devtools)){
   install.packages("devtools")
}

devtools::install_github("greenjune-ship-it/CBASSED50")
```

## Contributing

If you want to contribute to a project and make it better, your help is very welcome.

You can always report an [issue](https://github.com/greenjune-ship-it/CBASSED50/issues) or fork this repository, implement/fix your feature, and create a pull request.

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

You can always report the GitHub [issue](https://github.com/greenjune-ship-it/CBASSED50/issues) or email the current maintainer: [yulia.iakovleva\@uni-konstanz.de](mailto:yulia.iakovleva@uni-konstanz.de).

## Cite Us

If you use this software, please cite it as below:

``` commandline
Yulia Iakovleva & Christian R Voolstra. (2023).
CBASSED50: R package to process CBASS-derived PAM data.
Zenodo. https://doi.org/10.5281/ZENODO.8370644.
```
