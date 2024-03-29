% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/storage.R
\name{json}
\alias{json}
\alias{save_json}
\alias{get_json}
\alias{save_rdata}
\alias{get_rdata}
\title{Save the config to a JSON file}
\usage{
save_json(env, session, query)

get_json(session, query)

save_rdata(env, session, query)

get_rdata(session, query)
}
\arguments{
\item{env}{The config environment.}

\item{session}{A shiny session.}

\item{query}{Parsed query string.}
}
\description{
Save the config to a JSON file.

Save the config to an RData file.
}
