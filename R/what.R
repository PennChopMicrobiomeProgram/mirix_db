#' Fetch susceptibility values for a given lineage and antibiotic
#'
#' @param lineage A character vector of taxonomic assignments or lineages
#' @param antibiotic The name of the antibiotic or antibiotic class in \code{db}
#' @param db A data frame with columns named "taxon", "rank", "antibiotic",
#'   and "value"
#' @return A vector of assigned susceptibility values, which should be either
#'   "susceptible", "resistant", or \code{NA}
#' @details
#' To determine susceptibility, the database is first filtered to include only
#' rows relevant to the antibiotic of interest. Then, the filtered database is
#' split into ranks. The susceptibility values are determined for each rank by
#' matching taxa from the rank-specific database to the vector of lineages.
#' If a lineage matches to multiple taxa of different ranks, the value of the
#' taxon with the lowest rank is selected.
#'
#' The taxonomic ranks, in order from highest to lowest, are Kingdom, Phylum,
#' Class, Order, Family, Genus, and Species. The ranks in the database must be
#' capitalized, exactly as they are written here.
#' @examples
#' what_antibiotic(
#'   c("Enterococcus faecalis", "Lactobacillus", "Lactobacillus delbrueckii"),
#'   "vancomycin")
#' @export
what_antibiotic <- function (lineage,
                             antibiotic,
                             db = taxon_susceptibility) {
  is_relevant <- db$antibiotic %in% antibiotic
  db <- db[is_relevant, c("taxon", "rank", "value")]
  
  susceptibility_values <- match_annotation(lineage, db)
  susceptibility_values
}

#' Fetch the phenotype values for a given lineage and phenotype
#'
#' @param lineage A character vector of taxonomic assignments or lineages
#' @param phenotype The name of the column in \code{db} that contains the
#'   phenotype of interest
#' @param db A data frame with columns named "taxon", "rank", and the column
#'   name specified in \code{phenotype}
#' @return A vector of assigned phenotype values
#' @details
#' This function operates much like \code{antibiotic_susceptibility}, except
#' that it pulls phenotype values from the database instead of susceptibility
#' information. To subsequently determine susceptibility from phenotype, this
#' function uses the named vector provided in the \code{susceptibility}
#' argument.
#'
#' As a reminder, the taxonomic ranks, in order from highest to lowest, are
#' Kingdom, Phylum, Class, Order, Family, Genus, and Species. The ranks in the
#' database must be capitalized, exactly as they are written here.
#' @examples
#' what_phenotype(
#'   c("Bacteroidetes", "Firmicutes", "Firmicutes; Negativicutes"),
#'   "gram_stain",
#'   c("Gram-positive" = "susceptible", "Gram-negative" = "resistant"))
#' @export
what_phenotype <- function (lineage,
                            phenotype,
                            db = mirixdb::taxon_phenotypes) {
  db <- db[, c("taxon", "rank", phenotype)]
  # match_annotation() requires a column named "value"
  colnames(db)[3] <- "value"
  match_annotation(lineage, db)
}

#' Determine the annotation values for each lineage
#'
#' @param lineage A vector of taxonomic assignments or lineages
#' @param db A data frame with columns named "taxon", "rank", and "value"
#' @return A vector of assigned values
match_annotation <- function (lineage, db) {
  get_rank_specific_db <- function (r) {
    rank_is_r <- db[["rank"]] %in% r
    db[rank_is_r,]
  }
  db_ranks <- lapply(rev(taxonomic_ranks), get_rank_specific_db)
  names(db_ranks) <- rev(taxonomic_ranks)
  
  get_values_by_rank <- function (rank_specific_db) {
    taxa_idx <- match_taxa(lineage, rank_specific_db[["taxon"]])
    rank_specific_db[["value"]][taxa_idx]
  }
  values_by_rank <- vapply(
    db_ranks,
    get_values_by_rank,
    rep("a", length(lineage)))
  
  if (length(lineage) == 1) {
    assigned_values <- first_non_na_value(values_by_rank)
  } else {
    assigned_values <- apply(values_by_rank, 1, first_non_na_value)
  }
  assigned_values
}

#' Return the first index of a boolean vector that is TRUE. If all elements of
#' the vector are FALSE, return NA. Tempted to call this function minwhich.
#' 
#' @param x A logical vector
#' @return index of first true in vector or NA
#' @export
first_true_idx <- function (x) {
  if (any(x)) {
    min(which(x == TRUE))
  } else {
    NA_integer_
  }
}
