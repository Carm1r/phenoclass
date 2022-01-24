#' Definition of the discrimination unit (DU) for setting levels
#'
#' The function calculates the minimum value that allows distinction of
#' levels within a phenotypic characteristic using the methodology
#' described in Royo et al (2017). The function provides the following
#' outcomes in the console:
#' - Nacc : The number of accessions with characterization data
#' - Nacc_ref : The number of accessions used to calculate the discriminant
#' unit (UD). Accessions with highly variable observations are not considered.
#' - vm_g: lowest mean accesion value observed in the accessions in Nacc.
#' - VM_g: highest mean accession value observed in the accesions in Nacc.
#' - DU: Discriminant Unit, i.e. the difference between levels for the
#' phenotypic characteristic.
#' - P50: value of the 50 percentile of the mean accession values in Nacc.
#' - Central class: the limits of the central class defined by P50+-DU/2.
#'
#' Additionally, the function provides a dataframe with the mean accession
#' values, and the observed ranges of values for them. For each accesion the
#' dataframe provides:
#' - Mean: mean of the observed values
#' - Rg: the difference between the maximum and minimum observed value
#' - Rg_fil: the difference between the maximum and minimum observed value
#' for all the accessions used to calculate the DU. The accessions with high
#' internal variability have a N/A instead.
#'
#' NOTE: the current version of the function groups accessions using colvar
#' identifier. That is, accessions with data from two or more collecctions
#' are considered different. In order to compute a single accession value in
#' those situations, accessions should be encoded as belonging to the same
#' collection. Future versions of the function will allow to modify the
#' accession clustering method (by accession, by accession and collection).
#'
#' @param fendata a dataframe with phenotypic quantitative data. It
#' must contain the columns Collection, Accession, Year, Obs, Value,
#' colvaryear, colvar.
#' @return dataframe with the mean accession values and the range of values.
#' It contains the columns colvar, Collection, Accession, Mean, Rg, Rg_fil.
#' @author Carlos Miranda, \email{carlos.miranda@@unavarra.es}
#' @references
#'
#' Royo B (Coord), 2017. Harmonized methodology for the pomological characterization
#' of apple (Malus x domestica Borkh.). Bilingual edition Spanish/English.
#' Instituto Nacional de Investigacion y Tecnologia Agraria y Alimentaria (INIA).
#' Madrid, Spain. 122 pp. ISBN 978-84-7498-577-1
#'
#' @examples
#' # Remove outliers using a thr_y=1.5 and thr_g =1.8
#' library(tidyverse)
#' Claw.clean <- clean_outliers(U35_PE, 1.5, 1.8)
#' # Define the central class and DU for the accessions
#' Claw.class <- calc_du(Claw.clean)
#' @export calc_du
#' @import tidyverse
#'
calc_du <- function(fendata){
  rangos_cn <- c("Collection","Accession","Year","Obs","Value","colvaryear","colvar","Mean","Rg")
  rangos.df <-data.frame(matrix(ncol=9, nrow=0, byrow=FALSE))
  colnames(rangos.df) <- rangos_cn
  for (i in levels(fendata$colvar)){
    leap <- subset(fendata, colvar==i)
    Rgv <- max(leap$Value, na.rm = TRUE)-min(leap$Value, na.rm = TRUE)
    leap <- leap %>% mutate(Rg=Rgv,Mean=mean(leap$Value, na.rm = TRUE))
    rangos.df <-rbind(rangos.df,leap)

  }
  rangos.df <- transform(rangos.df, Rg = ifelse(Rg == "-Inf", NA, Rg))
  rangos_cv <- rangos.df %>%
    group_by(colvar) %>%
    summarise_all(first) %>%
    select(colvar,Collection, Accession, Mean, Rg) %>%
    drop_na()
  Rg_max <- mean(rangos_cv$Rg, na.rm = TRUE) + sd(rangos_cv$Rg, na.rm = TRUE)
  rangos_cv  <- rangos_cv  %>%
    mutate(Rg_fil = "is.na<-"(Rg, Rg > Rg_max))
  DU <- mean(rangos_cv$Rg_fil, na.rm = TRUE) + sd(rangos_cv$Rg_fil, na.rm = TRUE)
  nacc_ref <- sum(!is.na(rangos_cv$Rg_fil))
  VM_g <- max(rangos_cv$Mean)
  vm_g <- min(rangos_cv$Mean)
  P50 <- median(rangos_cv$Mean)
  central <- paste(round(P50-DU/2,2),"-",round(P50+DU/2,2),collapse = "")
  namval <- c("Nacc","Nacc_ref","vm_g","VM_g","DU","P50", "Central class")
  valores <- c(length(rangos_cv$Rg),nacc_ref,round(vm_g,3),round(VM_g,3),round(DU,3),round(P50,3),central)
  Results <- cbind(namval,valores)
  write.table(Results, row.names=F, col.names=F,quote = F, sep="\t")
  return(rangos_cv)
}
