% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_cis}
\alias{read_cis}
\title{Import a CIS study}
\usage{
read_cis(study_code, verbose = FALSE)
}
\arguments{
\item{study_code}{A string with the study code.}

\item{verbose}{boolean. Controls the messages printed on the console.}
}
\value{
A list of length 2 with the following values: 1) data: a data.frame with the individual-level data points for the timeseries. 2) metadata: a data.frame with the series code and their corresponding name
}
\description{
Download and import the data of a CIS study.
}
\examples{
\dontshow{httr::set_config(httr::config(ssl_verifypeer = 0L))}
# If you know the study code you can just read it into R
df <- read_cis("3328")
print(df)

# If you dont know the study code, you can search for a study using search_studies() function:
studies <- search_studies(search_terms = "gastronomia")
print(studies)

df <- read_cis(studies$codigo[1])
print(df)
}
