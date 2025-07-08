#' Custom `@examplesWebR` tag.
#'
#' When roxygen2 processes your documentation, the `@examplesWebR` tag generates
#' both an example section and webR integration. Specifically, the
#' example code is split into a regular `@examples` section and a WebR section.
#' The webR section contains a clickable link or embedding an interactive iframe
#' that interacts with the webR REPL by automatically encoding the code
#' for sharing.
#'
#' @section Implementation:
#'
#' When the `@examplesWebR` tag is processed, it creates:
#' 
#' 1. Regular `@examples` section with the code
#' 2. A `"WebR"` section containing format-appropriate webR integration link
#'
#' The webR URL format is: `https://webr.r-wasm.org/{version}/#code={encoded_code}&ju`
#' where the code is JSON-encoded and uncompressed.
#'
#' @section Generated Structure:
#'
#' The generated RD file will have the structure:
#' 
#' ```
#' \section{WebR}{
#'  \ifelse{html}{
#'    \out{
#'      <a href="webR_URL">\U0001F310 View in webR REPL</a>
#'    }
#'  }{
#'    \ifelse{latex}{
#'      \url{webR_URL}
#'    }{
#'      Interactive webR content not available for this output format.
#'    }
#'  }
#' }
#' \examples{
#' # Your R code here
#' plot(1:5, 1:5)
#' }
#' ```
#' 
#' where `webR_URL` is the link to the webR REPL with the encoded code.
#'
#' @section Output Format Support:
#'
#' The webR integration adapts to different documentation formats:
#' 
#' - **HTML**: Interactive buttons/iframes with full webR functionality
#' - **LaTeX/PDF**: Plain URL link to webR session
#' - **Other formats**: Informational message about limited support
#'
#' @section Parameters:
#'
#' The tag supports optional parameters:
#' 
#' - `@examplesWebR`: Default behavior (link in WebR section)
#' - `@examplesWebR embed`: Embed iframe instead of link
#' - `@examplesWebR version=v0.5.4`: Specify webR version greater than or equal to 0.5.4 (default: `latest`)
#' - `@examplesWebR height=400`: Set iframe height in pixels (default: `300`)
#' 
#' @section Package Configuration:
#'
#' To use the `@examplesWebR` tag in your package, add the required dependencies:
#'
#' In your `DESCRIPTION` file:
#' 
#' ```
#' Suggests:
#'     rocleteer
#' Remotes: coatless-rpkg/rocleteer
#' 
#' Roxygen: list(..., packages = c("rocleteer"))
#' ```
#'
#' @name tag-examplesWebR
#'
#' @usage
#' #' @examplesWebR
#' #' # Your example code that will be available in webR
#' #'
#' #' @examplesWebR embed
#' #' # Your example code with embedded webR iframe
#' 
#' #' @examplesWebR embed version=v0.5.4 height=400
#' #' # Your example code with embedded webR iframe with height 400 set to version 0.5.4
#'
#' @examples
#' # A function with webR integration
#' # 
#' #' @title Plot Simple Data
#' #' @description 
#' #' This function creates a simple plot
#' #' 
#' #' @param x Numeric vector for x-axis
#' #' @param y Numeric vector for y-axis
#' #'
#' #' @return 
#' #' A plot object
#' #' 
#' #' @examplesWebR
#' #' # Create some data
#' #' x <- 1:10
#' #' y <- x^2
#' #' 
#' #' # Create a plot
#' #' plot(x, y, type = "b", main = "Simple Quadratic")
#' #' 
#' #' # Add a line
#' #' lines(x, x^1.5, col = "red")
NULL

# Internal functions to handle the `@examplesWebR` tag ----

#' Encode R code for webR REPL sharing
#'
#' This function encodes R code in the format expected by webR REPL
#' for URL sharing. It matches the exact encoding used by webR:
#' JSON format + no compression + base64 + proper flags
#'
#' @param code Character string containing R code
#' @param filename Optional filename (default: "example.R")
#' 
#' @return 
#' Base64 encoded string suitable for webR URLs with proper flags
#' 
#' @noRd
encode_webr_code <- function(code, filename = "example.R") {
  # Check for required packages
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required for @examplesWebR tag")
  }
  if (!requireNamespace("base64enc", quietly = TRUE)) {
    stop("Package 'base64enc' is required for @examplesWebR tag")
  }
  
  # Create the share item structure exactly as webR expects
  share_item <- list(
    list(
      name = filename,
      path = paste0("/", filename),
      text = code
    )
  )
  
  # Convert to JSON to avoid a dependency on RcppMsgPack
  # Note: webR supports JSON with the 'j' flag
  json_str <- jsonlite::toJSON(share_item, auto_unbox = TRUE, pretty = FALSE)
  
  # webR expects UTF-8 bytes
  json_bytes <- charToRaw(json_str)
  
  # TODO: Use uncompressed for better compatibility with the webR URL
  
  # Base64 encode (matching webR's base64 encoding)
  base64_str <- base64enc::base64encode(json_bytes)
  
  # URL encode for safe inclusion in URLs
  encoded <- utils::URLencode(base64_str, reserved = TRUE)
  
  # Escape percent signs...
  escape_comment <- function(x) {
    gsub("%", "\\%", x, fixed = TRUE)
  }
  # ...to avoid issues with webR REPL parsing
  encoded <- escape_comment(encoded)
  
  # Add flags to encoding: 'ju' = JSON format + uncompressed
  encoded_with_flags <- paste0(encoded, "&ju")
  
  return(encoded_with_flags)
}

#' Validate webR version
#'
#' Check if the provided webR version is valid (latest or v0.5.4+)
#'
#' @param version_str Version string to validate
#' 
#' @return 
#' TRUE if valid, FALSE otherwise
#' 
#' @section Interal Examples:
#' 
#' ```r
#' # Valid versions:
#' validate_webr_version("latest")    # TRUE
#' validate_webr_version("v0.5.4")    # TRUE  
#' validate_webr_version("v0.6.0")    # TRUE
#' validate_webr_version("v1.0.0")    # TRUE
#'  
#' # Invalid versions:
#' validate_webr_version("v0.5.3")    # FALSE (too old)
#' validate_webr_version("v0.3.0")    # FALSE (too old)
#' validate_webr_version("0.6.0")     # FALSE (missing 'v')
#' validate_webr_version("invalid")   # FALSE (not a version)
#' ```
#' 
#' @noRd
validate_webr_version <- function(version_str) {
  # "latest" is always valid
  if (version_str == "latest") {
    return(TRUE)
  }
  
  # Check if version starts with 'v' and has a valid format
  if (!grepl("^v\\d+\\.\\d+\\.\\d+", version_str)) {
    return(FALSE)
  }
  
  # Extract numeric version (remove 'v' prefix)
  numeric_part <- sub("^v", "", version_str)
  
  # Try to parse as version and compare with minimum
  tryCatch({
    provided_version <- numeric_version(numeric_part)
    min_version <- numeric_version("0.5.4")
    
    return(provided_version >= min_version)
  }, error = function(e) {
    # If version parsing fails, it's invalid
    return(FALSE)
  })
}

#' Parse webR tag parameters
#'
#' Extract parameters from the webR tag line
#'
#' @param tag_line First line of the tag
#' 
#' @return 
#' List of parameters
#' 
#' @noRd
parse_webr_params <- function(tag_line) {
  # Default parameters
  params <- list(
    embed = FALSE,
    version = "latest",
    height = 300
  )
  
  # Parse parameters from tag line
  if (grepl("embed", tag_line, ignore.case = TRUE)) {
    params$embed <- TRUE
  }
  
  # Extract version if specified
  version_match <- regmatches(tag_line, regexpr("version=\\S+", tag_line))
  if (length(version_match) > 0) {
    version_str <- sub("version=", "", version_match)
    
    # Validate version
    if (!validate_webr_version(version_str)) {
      stop("Invalid webR version '", version_str, "'. Must be 'latest' or v0.5.4 or higher (e.g., v0.5.4, v0.6.0)")
    }
    
    # Set the version
    params$version <- version_str
  }
  
  # Extract height if specified
  height_match <- regmatches(tag_line, regexpr("height=\\d+", tag_line))
  if (length(height_match) > 0) {
    params$height <- as.numeric(sub("height=", "", height_match))
  }
  
  return(params)
}

#' Generate webR REPL link
#' 
#' Create a webR REPL link for the given encoded code
#' 
#' @param encoded_code Base64 encoded R code
#' @param version webR version (default: "latest")
#' 
#' @return
#' A URL string for the webR REPL
#' 
#' @keywords internal
webr_repl_href <- function(encoded_code, version = "latest") {
  paste0("https://webr.r-wasm.org/", version, "/#code=", encoded_code)
}

#' Generate webR link HTML
#'
#' Create HTML for webR REPL link
#'
#' @param encoded_code Base64 encoded code
#' @param version webR version
#' 
#' @return 
#' HTML string for link
#' 
#' @noRd
webr_repl_link <- function(encoded_code, version = "latest") {
  url <- webr_repl_href(encoded_code, version)
  html <- paste0(
    '<p><a href="', url, '" target="_blank" ',
    'style="background-color: #007bff; color: white; padding: 8px 16px; ',
    'text-decoration: none; border-radius: 4px; font-size: 14px;">',
    '\U0001F310 View in webR REPL</a></p>'
  )
  return(html)
}

#' Generate webR iframe HTML
#'
#' Create HTML for embedded webR iframe
#'
#' @param encoded_code Base64 encoded code
#' @param version webR version
#' @param height iframe height in pixels
#' 
#' @return 
#' HTML string for iframe
#' 
#' @noRd
webr_repl_iframe <- function(encoded_code, version = "latest", height = 300) {
  url <- webr_repl_href(encoded_code, version)
  html <- paste0(
    '<iframe src="', url, '" ',
    'width="100\\%" height="', height, 'px" ',
    'style="border: 1px solid #ddd; border-radius: 4px; margin-top: 10px;" ',
    'title="webR REPL">',
    '</iframe>'
  )
  return(html)
}

#' Parse the `@examplesWebR` tag
#'
#' This function handles the new `@examplesWebR` tag, which automatically 
#' creates both regular examples and webR REPL integration.
#'
#' @param x A roxygen2 tag
#' 
#' @return 
#' A parsed roxygen2 tag that contains examples plus webR content
#' 
#' @noRd
#' @exportS3Method roxygen2::roxy_tag_parse roxy_tag_examplesWebR
roxy_tag_parse.roxy_tag_examplesWebR <- function(x) {
  # Split the raw text into lines
  lines <- strsplit(x$raw, "\r?\n")[[1]]
  
  # Parse parameters from first line
  params <- parse_webr_params(lines[1])
  
  # Extract the actual code (skip first line if it contains only the tag)
  code_lines <- if (grepl("^\\s*$", lines[2])) lines[-c(1, 2)] else lines[-1]
  code <- paste(code_lines, collapse = "\n")
  
  # Process as examples tag first
  x$raw <- paste(code_lines, collapse = "\n")
  x$tag <- "examples"
  results <- roxygen2::tag_examples(x)
  
  # Store webR data for use in roxy_tag_rd
  if (nzchar(trimws(code))) {
    tryCatch({
      # Encode the code for webR
      encoded_code <- encode_webr_code(code)
      
      # Store webR integration data
      results$webr_data <- list(
        encoded_code = encoded_code,
        embed = params$embed,
        version = params$version,
        height = params$height
      )
      
    }, error = function(e) {
      # If encoding fails, log warning but continue
      warning("Failed to encode webR code: ", e$message)
    })
  }
  
  return(results)
}

#' @noRd
#' @exportS3Method roxygen2::roxy_tag_rd roxy_tag_examplesWebR
roxy_tag_rd.roxy_tag_examplesWebR <- function(x, base_path, env) {
  # If no webR data, just return examples
  if (is.null(x$webr_data)) {
    return(roxygen2::rd_section("examples", x$val))
  }
  
  # Generate the webR URL for all formats
  webr_url <- webr_repl_href(x$webr_data$encoded_code, x$webr_data$version)
  
  # Generate webR integration HTML for HTML format
  webr_html <- if (x$webr_data$embed) {
    webr_repl_iframe(x$webr_data$encoded_code, x$webr_data$version, x$webr_data$height)
  } else {
    webr_repl_link(x$webr_data$encoded_code, x$webr_data$version)
  }
  
  # Create content that adapts to different output formats
  webr_content <- paste0(
    "\\ifelse{html}{\\out{\n",
    webr_html,
    "\n}}{\\ifelse{latex}{\\url{", webr_url, "}}{Interactive webR content not available for this output format.}}"
  )
  
  # Create custom WebR section
  webr_section <- roxygen2::rd_section("section", list(title = "WebR", content = webr_content))
  
  # Return both examples and WebR sections
  list(
    roxygen2::rd_section("examples", x$val),
    webr_section
  )
}