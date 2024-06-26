
# whatbacteria

<!-- badges: start -->
  [![R-CMD-check](https://github.com/PennChopMicrobiomeProgram/whatbacteria/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/PennChopMicrobiomeProgram/whatbacteria/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

Taxon phenotype and susceptibility databases for the mirix package.

## Installation

You can install the development version of whatbacteria from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("PennChopMicrobiomeProgram/whatbacteria")
```

## Usage

To access the databases directly:

``` r
taxon_phenotypes
taxon_susceptibility
```

To get a particular lineage's susceptibilities:

``` r
what_antibiotic(
   c("Enterococcus faecalis", "Lactobacillus", "Lactobacillus delbrueckii"),
   "vancomycin")
```

To get a particular lineage's phenotypes:

``` r
what_phenotype(
   c("Bacteroidetes", "Firmicutes", "Firmicutes; Negativicutes"),
   "gram_stain")
```