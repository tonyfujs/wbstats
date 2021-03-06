#' Return a vector of the urls that would be call in the wb function
#'
#' This is a utility function to be used for quickly accessing the urls that are
#' called when using the wb function. The inputs are exactly the same as wb.
#'
#' @param country Character vector of country or region codes. Default value is special code of \code{all}.
#'  Other permissible values are codes in the following fields from the \code{\link{wb_cachelist}} \code{country}
#'  data frame. \code{iso3c}, \code{iso2c}, \code{regionID}, \code{adminID}, and \code{incomeID}.
#'  Additional special values include \code{aggregates}, which returns only aggregates, and \code{countries_only},
#'  which returns all countries without aggregates.
#' @param indicator Character vector of indicator codes. These codes correspond to the \code{indicatorID} column
#'  from the \code{indicator} data frame of \code{\link{wbcache}} or \code{\link{wb_cachelist}}, or
#'  the result of \code{\link{wbindicators}}
#' @param startdate Numeric or character. If numeric it must be in \%Y form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1". This also accepts a special value of "YTD", useful for more frequently
#'  updated subannual indicators.
#' @param enddate Numeric or character. If numeric it must be in \%Y form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1".
#' @param mrv Numeric. The number of Most Recent Values to return. A replacement of \code{startdate} and \code{enddate},
#'  this number represents the number of observations you which to return starting from the most recent date of collection.
#'  Useful in conjuction with \code{freq}
#' @param return_wide Logical. If \code{TRUE} data is returned in a wide format instead of long, with a column named for each
#' \code{indicatorID}. To necessitate this transformation, the \code{indicator} column, that provides the human readable description
#' is dropped. This field is available through from the \code{indicator} data frame of \code{\link{wbcache}} or \code{\link{wb_cachelist}},
#' or the result of \code{\link{wbindicators}}. Default is \code{FALSE}
#' @param gapfill Logical. Works with \code{mrv}. If \code{TRUE} fills values, if not available, by back tracking to the
#'  next available period (max number of periods back tracked will be limited by \code{mrv} number)
#' @param freq Character String. For fetching quarterly ("Q"), monthly("M") or yearly ("Y") values.
#'  Currently works along with \code{mrv}. Useful for querying high frequency data.
#' @param cache List of data frames returned from \code{\link{wbcache}}. If omitted,
#'  \code{\link{wb_cachelist}} is used
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#'  english is the default.
#' @param removeNA if \code{TRUE}, remove any blank or \code{NA} observations that are returned.
#'  if \code{FALSE}, no blank or \code{NA} values are removed from the return.
#' @param POSIXct if \code{TRUE}, additonal columns \code{date_ct} and \code{granularity} are added.
#'  \code{date_ct} converts the default date into a \code{\link[base]{POSIXct}}. \code{granularity}
#'  denotes the time resolution that the date represents.  Useful for subannual data and mixing subannual
#'  with annual data. If \code{FALSE}, these fields are not added.
#' @param include_dec if \code{TRUE}, the column \code{decimal} is not removed from the return. if \code{FALSE},
#'  this column is removed
#' @param include_unit if \code{TRUE}, the column \code{unit} is not removed from the return. if \code{FALSE},
#'  this column is removed
#' @param include_obsStatus if \code{TRUE}, the column \code{obsStatus} is not removed from the return. if \code{FALSE},
#'  this column is removed
#' @param include_lastUpdated if \code{TRUE}, the column \code{lastUpdated} is not removed from the return. if \code{FALSE},
#'  this column is removed. If \code{TRUE} and \code{POSIXct = TRUE} then column will be of class \code{\link[base]{Date}}
#' @return Data frame with all available requested data.
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#'  does not support your requested language by default it will return \code{NA}. For an enumeration of
#'  supported languages by data source please see \code{\link{wbdatacatalog}}.
#'  The options for \code{lang} are:
#'  \itemize{
#'  \item \code{en}: English
#'  \item \code{es}: Spanish
#'  \item \code{fr}: French
#'  \item \code{ar}: Arabic
#'  \item \code{zh}: Mandarin
#'  }
#'  The \code{POSIXct} parameter requries the use of \code{\link[lubridate]{lubridate}} (>= 1.5.0). All dates
#'  are rounded down to the floor. For example a value for the year 2016 would have a \code{POSIXct} date of
#'  \code{2016-01-01}. If this package is not available and the \code{POSIXct} parameter is set to \code{TRUE},
#'  the parameter is ignored and a \code{warning} is produced.
#'
#'  The \code{include_dec}, \code{include_unit}, and \code{include_obsStatus} are defaulted to \code{FALSE}
#'  because as of writing, all returns have a value of \code{0}, \code{NA}, and \code{NA}, respectively.
#'  These columns might be used in the future by the API, therefore the option to include the column is available.
#'
#'  The \code{include_lastUpdated} is defaulted to \code{FALSE} as well to limit the
#'
#'  If there is no data available that matches the request parameters, an empty data frame is returned along with a
#'  \code{warning}. This design is for easy aggregation of multiple calls.
#'
#'
.wb_url <- function(country = "all", indicator, startdate, enddate, mrv, return_wide = FALSE, gapfill,
               freq, cache, lang = c("en", "es", "fr", "ar", "zh"), removeNA = TRUE, POSIXct = FALSE,
               include_dec = FALSE, include_unit = FALSE, include_obsStatus = FALSE, include_lastUpdated = FALSE) {

  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  if (missing(cache)) cache <- wbstats::wb_cachelist

  # check country ----------
  if ("all" %in% country) {

    country_url <- "all"

  } else if ("aggregates" %in% country) {

    cache_cn <- cache$countries[cache$countries$region == "Aggregates" , "iso3c" ]
    country_url <- paste0(cache_cn, collapse = ";")

  } else if ("countries_only" %in% country) {

    cache_cn <- cache$countries[cache$countries$region != "Aggregates" , "iso3c" ]
    country_url <- paste0(cache_cn, collapse = ";")

  } else {

    cache_cn <- cache$countries
    cn_check <- cache_cn[ , c("iso3c", "iso2c", "regionID", "adminID", "incomeID")]
    cn_check <- unique(unlist(cn_check, use.names = FALSE))
    cn_check <- cn_check[!is.na(cn_check)]

    good_cn_index <- country %in% cn_check
    good_cn <- country[good_cn_index]

    if (length(good_cn) == 0) stop("country parameter has no valid values. Please check documentation for valid inputs")

    bad_cn <- country[!good_cn_index]

    if (length(bad_cn) > 0) warning(paste0("The following country values are not valid and are being excluded from the request: ",
                                           paste(bad_cn, collapse = ",")))

    country_url <- paste0(good_cn, collapse = ";")

  }

  # check indicator ----------
  cache_ind <- cache$indicators
  ind_check <- cache_ind[, "indicatorID"]
  ind_check <- ind_check[!is.na(ind_check)] # should never be needed but make sure

  good_ind_index <- indicator %in% ind_check
  good_ind <- indicator[good_ind_index]

  if (length(good_ind) == 0) stop("indicator parameter has no valid values. Please check documentation for valid inputs")

  bad_ind <- indicator[!good_ind_index]

  if (length(bad_ind) > 0) warning(paste0("The following indicator values are not valid and are being excluded from the request: ",
                                          paste(bad_ind, collapse = ",")))


  ## check date and other parameters. add to list if not missing ----------
  param_url_list <- list()


  # check dates ----------
  if (missing(startdate) !=  missing(enddate)) stop("Using either startdate or enddate requries supplying both. Please provide both if a date range is wanted")

  if (!(missing(startdate) & missing(enddate))) {

    #
    # something here to check the inputs but i'll come back to this
    #

    date_url <- paste0("date=", startdate, ":", enddate)

    param_url_list[length(param_url_list) + 1] <- date_url

  }

  # check mrv ----------
  if (!missing(mrv)) {

    if (!is.numeric(mrv)) stop("If supplied, mrv must be numeric")

    mrv_url <- paste0("MRV=", round(mrv, digits = 0)) # just to make sure its a whole number

    param_url_list[length(param_url_list) + 1] <- mrv_url

  }

  # check gapfill ----------
  if (!missing(gapfill)) {

    if (!is.logical(gapfill)) stop("If supplied, values for gapfill must be TRUE or FALSE")
    if (missing(mrv)) stop("mrv must be supplied for gapfill to be used")

    gapfill_url <- paste0("Gapfill=", ifelse(gapfill, "Y", "N"))

    param_url_list[length(param_url_list) + 1] <- gapfill_url

  }

  # check freq ----------
  if (!missing(freq)) {

    if (!freq %in% c("Y", "Q", "M")) stop("If supplied, values for freq must be one of the following 'Y' (yearly), 'Q' (Quarterly), or 'M' (Monthly)")

    freq_url <- paste0("frequency=", freq)

    param_url_list[length(param_url_list) + 1] <- freq_url

  }

  # combine the url parameters ----------
  param_url_list[length(param_url_list) + 1] <- utils_url
  param_url <- paste0(param_url_list, collapse = "&")


  # make API calls ----------
  url_vec <- sapply(indicator, FUN = function(i) {

    full_url <- paste0(base_url, lang, "/countries/", country_url, "/indicators/", i, "?", param_url)

  }
  )

  url_vec
}
