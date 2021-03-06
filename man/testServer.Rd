% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test-server.R
\name{testServer}
\alias{testServer}
\title{Reactive testing for Shiny server functions and modules}
\usage{
testServer(app = NULL, expr, args = list(), session = MockShinySession$new())
}
\arguments{
\item{app}{A server function (i.e. a function with \code{input}, \code{output},
and \code{session}), or a module function (i.e. a function with first
argument \code{id} that calls \code{\link[=moduleServer]{moduleServer()}}.

You can also provide an app, a path an app, or anything that
\code{\link[=as.shiny.appobj]{as.shiny.appobj()}} can handle.}

\item{expr}{Test code containing expectations. The objects from inside the
server function environment will be made available in the environment of
the test expression (this is done using a data mask with
\code{\link[rlang:eval_tidy]{rlang::eval_tidy()}}). This includes the parameters of the server function
(e.g. \code{input}, \code{output}, and \code{session}), along with any other values
created inside of the server function.}

\item{args}{Additional arguments to pass to the module function. If \code{app} is
a module, and no \code{id} argument is provided, one will be generated and
supplied automatically.}

\item{session}{The \code{\link{MockShinySession}} object to use as the \link[=domains]{reactive domain}. The same session object is used as the domain both
during invocation of the server or module under test and during evaluation
of \code{expr}.}
}
\description{
A way to test the reactive interactions in Shiny applications. Reactive
interactions are defined in the server function of applications and in
modules.
}
\examples{
# Testing a server function  ----------------------------------------------
server <- function(input, output, session) {
  x <- reactive(input$a * input$b)
}

testServer(server, {
  session$setInputs(a = 2, b = 3)
  stopifnot(x() == 6)
})


# Testing a module --------------------------------------------------------
myModuleServer <- function(id, multiplier = 2, prefix = "I am ") {
  moduleServer(id, function(input, output, session) {
    myreactive <- reactive({
      input$x * multiplier
    })
    output$txt <- renderText({
      paste0(prefix, myreactive())
    })
  })
}

testServer(myModuleServer, args = list(multiplier = 2), {
  session$setInputs(x = 1)
  # You're also free to use third-party
  # testing packages like testthat:
  #   expect_equal(myreactive(), 2)
  stopifnot(myreactive() == 2)
  stopifnot(output$txt == "I am 2")

  session$setInputs(x = 2)
  stopifnot(myreactive() == 4)
  stopifnot(output$txt == "I am 4")
  # Any additional arguments, below, are passed along to the module.
})
}
