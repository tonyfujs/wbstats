% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wb_data.R
\name{wb_data}
\alias{wb_data}
\title{Download Data from the World Bank API}
\usage{
wb_data(
  indicator,
  country = "countries_only",
  start_date,
  end_date,
  return_wide = TRUE,
  mrv,
  mrnev,
  cache,
  freq,
  gapfill = FALSE,
  lang
)
}
\arguments{
\item{indicator}{Character vector of indicator codes. These codes correspond
to the \code{indicator_id} column from the \code{indicators} tibble of \code{\link[=wb_cache]{wb_cache()}}, \link{wb_cachelist}, or
the result of running \code{\link[=wb_indicators]{wb_indicators()}} directly}

\item{country}{Character vector of country, region, or special value codes for the
locations you want to return data for. Permissible values can be found in the countries tibble in \link{wb_cachelist}
or by running \code{\link[=wb_countries]{wb_countries()}} directly. Specifically, values listed in the following fields
\code{iso3c}, \code{iso2c}, \code{country}, \code{region}, \code{admin_region}, \code{income_level} and all of the \verb{region_*}, \verb{admin_region_*}, \verb{income_level_*},
columns. As well as the following special values
\itemize{
\item \code{"countries_only"} (Default)
\item \code{"regions_only"}
\item \code{"admin_regions_only"}
\item \code{"income_levels_only"}
\item \code{"aggregates_only"}
\item \code{"all"}
}}

\item{start_date}{Numeric or character. If numeric it must be in `\%Y`` form (i.e. four digit year).
For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
and for quarterly data, "2016Q1". This also accepts a special value of "YTD", useful for more frequently
updated subannual indicators.}

\item{end_date}{Numeric or character. If numeric it must be in `\%Y`` form (i.e. four digit year).
For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
and for quarterly data, "2016Q1".}

\item{return_wide}{Logical. If \code{TRUE} data is returned in a wide format instead of long,
with a column named for each \code{indicator_id} or if the \code{indicator} argument is a named vector,
the \code{\link[=names]{names()}} given to the indicator will be the column names. To necessitate this transformation,
the \code{indicator} column that provides the human readable description is dropped, but provided as a column label.
Default is \code{TRUE}}

\item{mrv}{Numeric. The number of Most Recent Values to return. A replacement
of \code{start_date} and \code{end_date}, this number represents the number of observations
you which to return starting from the most recent date of collection. This may include missing values.
Useful in conjuction with \code{freq}}

\item{mrnev}{Numeric. The number of Most Recent Non Empty Values to return. A replacement
of \code{start_date} and \code{end_date}, similar in behavior as \code{mrv} but excludes locations with missing values.
Useful in conjuction with \code{freq}}

\item{cache}{List of tibbles returned from \code{\link[=wb_cache]{wb_cache()}}. If omitted, \link{wb_cachelist} is used}

\item{freq}{Character String. For fetching quarterly ("Q"), monthly("M") or yearly ("Y") values.
Useful for querying high frequency data.}

\item{gapfill}{Logical. If \code{TRUE} fills in missing values by carrying forward the last
available value until the next available period (max number of periods back tracked will be limited by \code{mrv} number).
Default is \code{FALSE}}

\item{lang}{Language in which to return the results. If \code{lang} is unspecified,
english is the default. For supported languages see \code{\link[=wb_languages]{wb_languages()}}.
Possible values of \code{lang} are in the \code{iso2} column. A note of warning, not
all data returns have support for langauges other than english. If the specific
return does not support your requested language by default it will return \code{NA}.}
}
\value{
A \link[tibble:tbl_df]{tibble} of all available requested data.
}
\description{
This function downloads the requested information using the World Bank API
}
\details{
\subsection{\code{obs_status} column}{

Indicates the observation status for location, indicator and date combination.
For example \code{"F"} in the response indicates that the observation status for that data point is "forecast".
}
}
\examples{
# gdp for all countries for all available dates
\donttest{df_gdp <- wb_data("NY.GDP.MKTP.CD")}

# Brazilian gdp for all available dates
df_brazil <- wb_data("NY.GDP.MKTP.CD", country = "br")

# Brazilian gdp for 2006
df_brazil_1 <- wb_data("NY.GDP.MKTP.CD", country = "brazil", start_date = 2006)

# Brazilian gdp for 2006-2010
df_brazil_2 <- wb_data("NY.GDP.MKTP.CD", country = "BRA", start_date = 2006, end_date = 2010)


# Population, GDP, Unemployment Rate, Birth Rate (per 1000 people)
my_indicators <- c("SP.POP.TOTL", "NY.GDP.MKTP.CD", "SL.UEM.TOTL.ZS", "SP.DYN.CBRT.IN")
\donttest{df <- wb_data(my_indicators)}


# you pass multiple country ids of different types
# Albania (iso2c), Georgia (iso3c), and Mongolia
my_countries <- c("AL", "Geo", "mongolia")
df <- wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007)

# same data as above, but in long format
df_long <- wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007, return_wide = FALSE)


# regional population totals
# regions correspond to the region column in wb_cachelist$countries
df_region <- wb_data("SP.POP.TOTL", country = "regions_only", start_date = 2010, end_date = 2014)


# a specific region
df_world <- wb_data("SP.POP.TOTL", country = "world", start_date = 2010, end_date = 2014)


# if the indicator is part of a named vector the name will be the column name
names(my_indicators) <- c("population", "gdp", "unemployment_rate", "birth_rate")
df_names <- wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014)


# custom names are ignored if returning in long format
df_names_long <- wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014, return_wide = FALSE)

# same as above but in Bulgarian
# note that not all indicators have translations for all languages
df_names_long_bg <- wb_data(my_indicators, country = "world", start_date = 2010,
end_date = 2014, return_wide = FALSE, lang = "bg")


# if you do not know when the latest time an indicator is avaiable mrv can help
# unenployment rate
df_mrv <- wb_data("SL.UEM.TOTL.ZS", mrv = 1)

# note the difference in mrv and mrnev
df_mrnev <- wb_data("SL.UEM.TOTL.ZS", mrnev = 1)


# without the freq parameter the deafult temporal granularity search is yearly
# should return the 12 most recent years of data
df_annual <- wb_data("DPANUSSPF", country = c("CHN", "IND"), mrv = 12)


# if another frequency is available for that indicator it can be accessed using the freq parameter
# should return the 12 most recent months of data
df_monthly <- wb_data("DPANUSSPF", country = c("CHN", "IND"), mrv = 12, freq = "M")
}
