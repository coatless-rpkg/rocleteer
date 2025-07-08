
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rocleteer

<!-- badges: start -->

[![R-CMD-check](https://github.com/coatless-rpkg/rocleteer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/coatless-rpkg/rocleteer/actions/workflows/R-CMD-check.yaml)![Active](https://img.shields.io/badge/Status-Active-green)![Experimental](https://img.shields.io/badge/Status-Experimental-blue)
<!-- badges: end -->

A roxygen2 extension collection package.

## Installation

You can install the development version of `{rocleteer}` from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("coatless-rpkg/rocleteer")
```

## Usage

In your package’s `DESCRIPTION` file, add `{rocleteer}` to your
Suggests, `coatless-rpkg/rocleteer` to your Remotes, and include
`rocletter` in your Roxygen `list` of packages.

    Suggests:
        rocleteer

    Remotes:
      coatless-rpkg/rocleteer

    Roxygen: list(..., packages = c("rocleteer"))

where `...` could be `roclets = c("collate", "namespace", "rd")`.

### `@examplesTempdir`

When writing examples for R package functions, you often need to create
temporary files or directories. To avoid cluttering the user’s
workspace, it’s good practice to use a temporary directory for these
examples.

Traditionally, you would need to manually set up and switch out of the
temporary directory like this:

``` r
#' @examples
#' \dontshow{.old_wd <- setwd(tempdir())}
#'
#' # Your code here
#'
#' \dontshow{setwd(.old_wd)}
```

With `{rocleteer}`, you can simply use the `@examplesTempdir` tag
instead:

``` r
#' @examplesTempdir
#' # Your code here
```

The `@examplesTempdir` tag handles this automatically. So, if you have a
function like this:

``` r
#' Example function
#'
#' @examplesTempdir
#' # This code will run in a temporary directory
#' write.csv(mtcars, "mtcars.csv")
#' read.csv("mtcars.csv")
#' file.remove("mtcars.csv")
#'
#' @export
example_function <- function() {
  # Function implementation
}
```

The documentation will be processed by roxygen2 as:

``` r
#' Example function
#'
#' @examples
#' \dontshow{
#' .old_wd <- setwd(tempdir()) # examplesTempdir
#' }
#' # This code will run in a temporary directory
#' write.csv(mtcars, "mtcars.csv")
#' read.csv("mtcars.csv")
#' file.remove("mtcars.csv")
#'
#' \dontshow{
#' setwd(.old_wd) # examplesTempdir
#' }
#'
#' @export
example_function <- function() {
  # Function implementation
}
```

> \[!NOTE\]
>
> This roclet is inspired by [an old post of
> mine](https://blog.thecoatlessprofessor.com/programming/r/hiding-tempdir-and-tempfile-statements-in-r-documentation/)
> that I initially shared in 2018 covering this pattern.

### `@examplesWebR`

The `@examplesWebR` tag creates interactive examples that can be run
directly in the browser using
[webR](https://docs.r-wasm.org/webr/latest/). This makes your package
documentation more engaging and allows users to experiment with examples
without installing R locally.

For this to work with developmental versions of your package, you will
need to use the following `pkgdown` + `rwasm` build action:

<https://github.com/r-wasm/actions/blob/main/examples/rwasm-binary-and-pkgdown-site.yml>

For a fast setup, please use:

``` r
usethis::use_github_action("https://github.com/r-wasm/actions/blob/main/examples/rwasm-binary-and-pkgdown-site.yml")
```

> \[!IMPORTANT\]
>
> Please make sure to delete your old `pkgdown.yml` file.

#### Generated Structure

When you use `@examplesWebR`, it generates:

1.  **Examples Section**: Contains your R code as normal examples
2.  **WebR Section**: Contains the webR integration (link or iframe)

That is, from:

``` r
#' @examplesWebR
#' # Create some data
#' x <- 1:10
#' y <- x^2
#' 
#' # Create a plot
#' plot(x, y, type = "b", main = "Interactive Example")
```

it generates:

``` rd
\section{WebR}{
 \ifelse{html}{
   \out{
     <a href="webR_URL">\U0001F310 View in webR REPL</a>
   }
 }{
   \ifelse{latex}{
     \url{webR_URL}
   }{
     Interactive webR content not available for this output format.
   }
 }
}
\examples{
# Create some data
x <- 1:10
y <- x^2

# Create a plot
plot(x, y, type = "b", main = "Interactive Example")
}
```

This creates:

- Regular examples with your R code
- A “WebR” section with a “View in webR REPL” button in HTML
  documentation or a URL in LaTeX documentation.
- The button opens the code in an interactive webR session

> \[!NOTE\]
>
> The `@examplesWebR` tag uses a simplified encoding scheme compatible
> with webR.

#### Embedded Mode

For a more integrated experience, embed the webR REPL directly into the
Rd file with:

``` r
#' @examplesWebR embed
#' # This code will be available in an embedded webR session
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt)) + 
#'   geom_point() + 
#'   theme_minimal()
```

#### Additional Options

You can customize the `@examplesWebR` tag with additional options:

- `embed`: Embed an iframe instead of showing a link
- `height=N`: Set iframe height in pixels (default: `300`)
- `version=X`: Specify webR version (default: `"latest"`)

For example, to embed with a specific height and version:

``` r
#' @examplesWebR embed height=500 version=v0.3.3
#' # Custom height iframe with specific webR version
#' summary(cars)
#' plot(cars)
```

> \[!NOTE\]
>
> I’ve been on a quest to make R package documentation more interactive
> and engaging, and this tag is a step towards that goal. It first
> started as a way to [build and serve a webR R binary alongside pkgdown
> sites](https://github.com/r-wasm/actions/issues/15) and, then, moved
> to [`altdocs` with the `quarto-webr` Quarto
> Extension](https://github.com/coatless-r-n-d/quarto-webr-in-altdoc)…
> And now, we finally have a way to do this with roxygen2 and pkgdown!

## License

AGPL (\>=3)
