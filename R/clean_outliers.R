#' Detection and removal of outliers within accessions
#'
#' The function removes phenotypic observations that could be considered
#' as outliers from a characterization dataset based on the methodology
#' described in Royo et al (2017). Briefly, the characterization data for
#' each accession is analyzed in order to remove the observations that
#' deviate markedly from the others. This is a two-step process in which
#' first the outliers within each year of observations are eliminated,
#' and then at the global level (all years of observation pooled). By
#' default, observations differing 1.5 standard deviations from the
#' yearly or pooled mean are considered outliers, but the thresholds
#' can be adjusted by the user.
#'
#'
#' @param fendata a dataframe with phenotypic quantitative data. It
#' must contain the columns Collection, Accession, Year, Obs, Value.
#' @param thr_y threshold for outliers within yearly observations. By
#' default = 1.5
#' @param thr_g threshold for globla outliers within accessions. By
#' default = 1.5
#' @return dataframe in which the observations considered as outliers have
#' been removed, leaving a NA instead. It contains the columns Collection,
#' Acession, Year, Obs, Value, colvaryear, colvar
#' @author Carlos Miranda, \email{carlos.miranda@@unavarra.es}
#' @references
#'
#' Royo B (Coord), 2017. Harmonized methodology for the pomological characterization
#' of apple (Malus x domestica Borkh.). Bilingual edition Spanish/English.
#' Instituto Nacional de Investigacion y Tecnologia Agraria y Alimentaria (INIA).
#' Madrid, Spain. 122 pp. ISBN 978-84-7498-577-1
#'
#' @examples
#'
#' # Remove outliers using a thr_y=1.5 and thr_g =1.8
#' library(tidyverse)
#' Claw.clean <- clean_outliers(U35_PE, 1.5, 1.8)
#' @export clean_outliers
#' @import tidyverse
#'
clean_outliers <- function(fendata, thr_y = 1.5, thr_g = 1.5 ){
  fendata$Collection <- factor(fendata$Collection)
  fendata$Year <- factor(fendata$Year)
  fendata$Accession <- factor(fendata$Accession)
  fendata <- within(fendata, colvaryear <- factor(Collection:Accession:Year))
  fendata <- within(fendata, colvar <- factor(Collection:Accession))

  within_cn <- c("Collection","Accession","Year","Obs","Value","colvaryear","colvar")
  within.df <-data.frame(matrix(ncol=7, nrow=0, byrow=FALSE))
  colnames(within.df) <- within_cn

  for (i in levels(fendata$colvaryear)) {
    leap <- subset(fendata, colvaryear==i)
    meanx <-mean(leap$Value,na.rm=TRUE)
    sdx<-sd(leap$Value,na.rm=TRUE)
    if (sum(!is.na(leap$Value)) > 3) {
      leap <- leap %>% mutate(Value = "is.na<-"(Value, Value < meanx-thr_y*sdx | Value >meanx+thr_y*sdx))
    }
    within.df <-rbind(within.df,leap)

  }

  between_cn <- c("Collection","Accession","Year","Obs","Value","colvaryear","colvar")
  between.df <-data.frame(matrix(ncol=7, nrow=0, byrow=FALSE))
  colnames(between.df) <- between_cn
  for (i in levels(within.df$colvar)) {
    leap2 <- subset(within.df, colvar==i)
    meanx <-mean(leap2$Value,na.rm=TRUE)
    sdx<-sd(leap2$Value,na.rm=TRUE)
    if (sum(!is.na(leap2$Value))>3) {
      leap3 <- leap2 %>% mutate(Value = "is.na<-"(Value, Value < meanx-thr_g*sdx | Value >meanx+thr_g*sdx))
    }
    if (length(unique(leap2$Year))>1){
      between.df <-rbind(between.df,leap3)
    }else{
      between.df <-rbind(between.df,leap2)
    }
  }
  return(between.df)
}
