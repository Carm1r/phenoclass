
<!-- README.md is generated from README.Rmd. Please edit that file -->

## [phenoclass](https://github.com/Carm1r/phenoclass): Tools for setting objective quantitative levels of expression in characterizations in [R](https://www.r-project.org).

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This mini-package allows to define levels of expression for quantitative
traits following the methodology described in the book “Harmonized
methodology for the pomological characterization of apple (Malus x
domestica Borkh.)” by Royo et al (2017). This method is based on the
UPOV test guidelines, but it redefines rigorously every characteristic
and level in order to minimize subjectivity, therefore allowing to
compare easily descriptions made by different teams. The amount of
levels for any characteristic depends on the variability in the values
that can be found within the same accession and within accessions. For
that reason, for that reason, the width of the intervals of the scale
(called in the methodology as Discrimination Unit or DU) is greater than
the difference that, on average, can be found between the largest and
smallest measurable values within the same accession. As a consequence,
the number of classes is not defined a priori, but depends on the value
of the DU and the mean value of the characteristic in the accessions
with extreme values in the collection to be classified.

<div id="menu" />

-----

## Resources

  - [Installation](#Instal)
  - [1. Required package](#P1)
  - [2. Example: Estimate the phenology of a peach cultivar](#P2)

<div id="Instal" />

-----

## Installation

You can install phenoclass from [GitHub](https://github.com/) with:

``` r
install.packages("devtools")
library(devtools)
devtools::install_github("Carm1r/phenoclass")
```

[Menu](#menu)

<div id="P1" />

-----

## Using phenoclass

### 1\. Required package

>   - **[tidyverse](https://CRAN.R-project.org/package=tidyverse)**

``` r

install.packages("tidyverse")

library(phenoclass)
library(tidyverse)

```

[Menu](#menu)

<div id="P2" />

-----

### 2\. Example. Definition of the classes for a character in pear flowers

This example shows how to use the functions *clean\_outliers* and
*calc\_du* to define the number of phenotypic classes that can be
observed without ambiguity using dummy characterization data. The
example uses the dataset U35\_Pe, included in the package, which
contains data for the length of claw of petal in pear flowers,
corresponding to descriptor U35 in TG/15/3 (UPOV, 2000). The dataset
contains lengths for 52 accessions, ten observations per accession and
year, evaluated for up to three years.

``` r
library(phenoclass)
library(tidyverse)
# Remove outliers using a thr_y=1.5 and thr_g =1.8
data(U35_PE)
Claw.clean <- clean_outliers(U35_PE, 1.5, 1.8)
# Define the central class and DU for the accessions
Claw.class <- calc_du(Claw.clean)
```

[Menu](#menu)

## Licenses

The R/phenoclass package as a whole is distributed under [GPL-3 (GNU
General Public License
version 3)](https://www.gnu.org/licenses/gpl-3.0).

## Author

[Carlos Miranda](https://github.com/Carm1r)
