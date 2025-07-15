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
#' The webR URL format is: 
#' 
#' ```
#' https://webr.r-wasm.org/{version}/?mode={mode}&channel={channel}#code={encoded_code}&ju{a}
#' ```
#' 
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
#'      <div class="rocleteer-webr-container">...</div>
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
#' @section Styling and Theming:
#'
#' The webR Section HTML output uses Bootstrap-compatible CSS classes and custom
#' properties to link themeing to pkgdown's existing CSS themes. The styles 
#' follow the CSS custom properties pattern:
#' 
#' - Private variables (`--_*`): Used internally
#' - Public variables (`--rocleteer-webr-*`): For user customization  
#' - Bootstrap variables (`--bs-*`): Used as fallbacks
#' 
#' Main CSS classes are:
#' 
#' - `.rocleteer-webr-container`: Main container
#' - `.rocleteer-webr-warning`: Experimental feature warning
#' - `.rocleteer-webr-btn`, `.rocleteer-webr-btn-primary`, etc.: Button styling
#' 
#' To customize appearance in pkgdown sites, override CSS custom properties by
#' including into a file:
#' 
#' ```css
#' .rocleteer-webr-container {
#'   --rocleteer-webr-container-bg: #f0f8ff;
#'   --rocleteer-webr-btn-primary-bg: #1976d2;
#' }
#' ```
#'
#' @section Parameters:
#'
#' The tag supports optional parameters (these override global `DESCRIPTION` config):
#' 
#' - `@examplesWebR`: Default behavior (link in WebR section)
#' - `@examplesWebR embed`: Embed iframe instead of link
#'    - `@examplesWebR embed=false` - Explicitly disable embedding (override global config)
#' - `@examplesWebR version=v0.5.4`: Specify webR version greater than or equal to 0.5.4 (default: `latest`)
#' - `@examplesWebR height=500`: Set iframe height in pixels (default: `400`)
#' - `@examplesWebR autorun` - Enable autorun on webR session open
#'    - `@examplesWebR autorun=false` - Explicitly disable autorun (override global config)
#' - `@examplesWebR mode=editor-plot` - Configure embedded webR interface (editor, plot, terminal, files) (default: `"editor-plot-terminal"`)
#' - `@examplesWebR channel=Automatic` - Set webR communication channel (default: `"Automatic`)
#'
#' **Version Requirements**: The version parameter must be either `"latest"` or a 
#' version string `v0.5.4` or higher. Earlier versions are not supported 
#' as the embedding feature is new.
#'
#' **Mode Options**: Valid mode components are `editor`, `plot`, `terminal`, and `files`.
#' Combine multiple components with hyphens (e.g., `editor-plot-terminal`).
#' 
#' @section Global Configuration:
#'
#' You can set global defaults for tags in your package's `DESCRIPTION` file:
#' 
#' ```
#' Config/rocleteer/webr-embed: false
#' Config/rocleteer/webr-height: 500  
#' Config/rocleteer/webr-version: v0.5.4
#' Config/rocleteer/webr-autorun: true
#' Config/rocleteer/webr-mode: editor-plot
#' Config/rocleteer/webr-channel: Automatic
#' ```
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
#' You will also need to specify a location where we can obtain the webR
#' compiled package in `DESCRIPTION`. This will usually be a GitHub Pages URL
#' or an R-universe URL. The recommended way is to use the 
#' `Config/rocleteer/webr-repo` field in your `DESCRIPTION` file:
#'
#' ```
#' Config/rocleteer/webr-repo: https://user.github.io/pkgname/
#' ```
#'
#' Alternatively, you can use the `URL` field in your `DESCRIPTION` file to
#' specify the repository URL. The tag will attempt to auto-detect the
#' repository URL from the `URL` field if the `Config/rocleteer/webr-repo` field
#' is not set. The tag will look for:
#' 
#' ```
#' URL: https://user.github.io/pkgname/, https://github.com/user/pkgname
#' ```
#' 
#' or
#' 
#' ```
#' URL: https://username.r-universe.dev
#' ```
#' 
#' If we cannot find a suitable repository URL, the tag will throw an error
#' during processing.
#' 
#' The generated webR examples will use this URL to install the package
#' and load it in the webR REPL. The installation code will look like this:
#' 
#' ```r
#' # Install and load webR Package
#' install.packages("pkgname", repos = "https://user.github.io/pkgname/")
#' library("pkgname")
#' 
#' # Example code:
#' your_function()
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
#' #'
#' #' @examplesWebR embed version=v0.5.4 height=400
#' #' # Your example code with embedded webR iframe with height 400 set to version 0.5.4
#' #'
#' #' @examplesWebR embed=false autorun mode=editor-plot
#' #' # Your example code with custom configuration overriding global settings
#' #'
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

#' Read webR configuration from DESCRIPTION file
#'
#' Extract webR-related configuration from the package DESCRIPTION file
#'
#' @param base_path Base path to find DESCRIPTION file
#' 
#' @return 
#' List of configuration options
#' 
#' @noRd
read_webr_config <- function(base_path) {
  # Check for required packages
  if (!requireNamespace("desc", quietly = TRUE)) {
    stop("Package 'desc' is required for @examplesWebR tag DESCRIPTION integration")
  }
  
  # Find DESCRIPTION file
  desc_path <- file.path(base_path, "DESCRIPTION")
  if (!file.exists(desc_path)) {
    warning("DESCRIPTION file not found, using default webR configuration")
    return(list())
  }
  
  # Read DESCRIPTION
  d <- desc::desc(desc_path)
  
  # Extract webR configuration
  config <- list()
  
  # Global webR options
  config$embed <- d$get_field("Config/rocleteer/webr-embed", default = "false")
  config$embed <- tolower(config$embed) %in% c("true", "yes", "1")
  
  config$height <- as.numeric(d$get_field("Config/rocleteer/webr-height", default = "300"))
  config$version <- d$get_field("Config/rocleteer/webr-version", default = "latest")
  config$autorun <- d$get_field("Config/rocleteer/webr-autorun", default = "false")
  config$autorun <- tolower(config$autorun) %in% c("true", "yes", "1")
  
  # Package info for installation
  config$package_name <- d$get_field("Package", default = "")
  
  # Repository detection
  config$webr_repo <- detect_webr_repo(d)
  
  return(config)
}

#' Detect webR repository from DESCRIPTION
#'
#' Find the appropriate repository URL for webR package installation
#'
#' @param desc_obj A desc object from the desc package
#' 
#' @return 
#' Repository URL string, or stops with error if not found
#' 
#' @noRd
detect_webr_repo <- function(desc_obj) {
  # Check for dedicated webR repo field first
  webr_repo <- desc_obj$get_field("Config/rocleteer/webr-repo", default = NA)
  if (!is.na(webr_repo) && nzchar(webr_repo)) {
    return(webr_repo)
  }
  
  # Try to detect from URL field
  url <- desc_obj$get_field("URL", default = NA)
  if (!is.na(url) && nzchar(url)) {
    # Handle multiple URLs (comma or whitespace separated)
    urls <- strsplit(url, "[,\\s]+")[[1]]
    urls <- trimws(urls)
    
    for (u in urls) {
      # Check for GitHub Pages pattern: https://user.github.io/pkgname/
      if (grepl("https://[^/]+\\.github\\.io/[^/]+/?$", u)) {
        return(u)
      }
      # Check for R-universe pattern: https://username.r-universe.dev
      if (grepl("https://[^/]+\\.r-universe\\.dev/?$", u)) {
        return(u)
      }
    }
  }
  
  # If no suitable repo found, throw an error
  stop(
    "No suitable webR repository found. Please add one of:\n",
    "1. Config/Needs/WebRRepo: https://user.github.io/pkgname/\n",
    "2. URL field with GitHub Pages (https://user.github.io/pkgname/) or R-universe (https://user.r-universe.dev) pattern"
  )
}


#' Generate package installation code for webR
#'
#' Create R code to install and load the package in webR
#'
#' @param package_name Name of the package
#' @param repo_url Repository URL
#' 
#' @return 
#' R code string for package installation
#' 
#' @noRd
generate_package_install_code <- function(package_name, repo_url) {
  if (!nzchar(package_name) || is.na(repo_url)) {
    return("")
  }
  
  install_code <- paste0(
    "# Install and load webR Package\n",
    'webr::install(\n  "', package_name, '",\n  repos = "', repo_url, '",\n  mount = FALSE)\n',
    'library("', package_name, '")\n',
    '\n',
    "# Example code:\n"
  )
  
  return(install_code)
}

#' Encode R code for webR REPL sharing
#'
#' This function encodes R code in the format expected by webR REPL
#' for URL sharing. It matches the exact encoding used by webR:
#' JSON format + no compression + base64 + proper flags
#'
#' @param code Character string containing R code
#' @param filename Optional filename (default: "example.R")
#' @param autorun Whether to enable autorun (adds 'a' flag)
#' 
#' @return 
#' Base64 encoded string suitable for webR URLs with proper flags
#' 
#' @noRd
encode_webr_code <- function(code, filename = "example.R", autorun = FALSE) {
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
  
  # Add flags to encoding: 'jua' = JSON format + uncompressed + autorun
  flags <- if (autorun) "jua" else "ju"
  encoded_with_flags <- paste0(encoded, "&", flags)
  
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


#' Validate webR mode
#'
#' Check if the provided webR mode contains only valid options
#'
#' @param mode_str Mode string to validate (e.g., "editor-plot-terminal")
#' 
#' @return 
#' TRUE if valid, FALSE otherwise
#' 
#' @noRd
validate_webr_mode <- function(mode_str) {
  if (!nzchar(mode_str)) {
    return(TRUE)  # Empty mode is valid (use webR default)
  }
  
  valid_modes <- c("editor", "plot", "terminal", "files")
  provided_modes <- strsplit(mode_str, "-")[[1]]
  
  # Check if all provided modes are valid
  all(provided_modes %in% valid_modes)
}

#' Parse webR tag parameters
#'
#' Extract parameters from the webR tag line and merge with global config
#'
#' @param tag_line First line of the tag
#' @param global_config Global configuration from DESCRIPTION file
#' 
#' @return 
#' List of parameters
#' 
#' @noRd
parse_webr_params <- function(tag_line, global_config = list()) {
  # Start with global config defaults
  params <- list(
    embed = global_config$embed %||% TRUE,
    version = global_config$version %||% "latest", 
    height = global_config$height %||% 300,
    autorun = global_config$autorun %||% FALSE,
    mode = global_config$mode %||% "editor-plot-terminal",
    channel = global_config$channel %||% ""
  )
  
  # Parse local parameters from tag line (these override global config)
  
  # Handle embed (including explicit false)
  if (grepl("embed=false", tag_line, ignore.case = TRUE)) {
    params$embed <- FALSE
  } else if (grepl("embed", tag_line, ignore.case = TRUE)) {
    params$embed <- TRUE
  }
  
  # Handle autorun (including explicit false)
  if (grepl("autorun=false", tag_line, ignore.case = TRUE)) {
    params$autorun <- FALSE
  } else if (grepl("autorun", tag_line, ignore.case = TRUE)) {
    params$autorun <- TRUE
  }
  
  # Extract version if specified
  version_match <- regmatches(tag_line, regexpr("version=\\S+", tag_line))
  if (length(version_match) > 0) {
    version_str <- sub("version=", "", version_match)
    
    # Validate version
    if (!validate_webr_version(version_str)) {
      stop("Invalid webR version '", version_str, "'. Must be 'latest' or v0.5.4 or higher (e.g., v0.5.4, v0.6.0)")
    }
    
    params$version <- version_str
  }
  
  # Extract height if specified
  height_match <- regmatches(tag_line, regexpr("height=\\d+", tag_line))
  if (length(height_match) > 0) {
    params$height <- as.numeric(sub("height=", "", height_match))
  }
  
  # Extract mode if specified
  mode_match <- regmatches(tag_line, regexpr("mode=[\\w\\-]+", tag_line))
  if (length(mode_match) > 0) {
    mode_str <- sub("mode=", "", mode_match)
    
    # Validate mode
    if (!validate_webr_mode(mode_str)) {
      stop("Invalid webR mode '", mode_str, "'. Valid options are: editor, plot, terminal, files (separated by hyphens)")
    }
    
    params$mode <- mode_str
  }
  
  # Extract channel if specified
  channel_match <- regmatches(tag_line, regexpr("channel=\\S+", tag_line))
  if (length(channel_match) > 0) {
    params$channel <- sub("channel=", "", channel_match)
  }
  
  return(params)
}

#' Generate Rocleteer webR CSS styles
#'
#' Create the complete CSS for webR components as an inline style block
#'
#' @return 
#' HTML string with complete CSS styles
#' 
#' @noRd
webr_inline_css <- function() {
  paste0(
    '<style id="rocleteer-webr-styles">',
    '/* WebR Interactive Examples CSS - rocleteer package */',
    '.rocleteer-webr-container {',
    '  --_container-bg: var(--rocleteer-webr-container-bg, var(--bs-light, #f8f9fa));',
    '  --_container-border: var(--rocleteer-webr-container-border, var(--bs-border-color, #dee2e6));',
    '  --_container-border-radius: var(--rocleteer-webr-container-border-radius, var(--bs-border-radius, 8px));',
    '  --_warning-bg: var(--rocleteer-webr-warning-bg, var(--bs-info-bg-subtle, #e7f3ff));',
    '  --_warning-border: var(--rocleteer-webr-warning-border, var(--bs-info-border-subtle, #b3d9ff));',
    '  --_warning-text: var(--rocleteer-webr-warning-text, var(--bs-info-text-emphasis, #0c5aa6));',
    '  --_btn-primary-bg: var(--rocleteer-webr-btn-primary-bg, var(--bs-primary, #007bff));',
    '  --_btn-primary-hover: var(--rocleteer-webr-btn-primary-hover, var(--bs-primary-hover, #0056b3));',
    '  --_btn-success-bg: var(--rocleteer-webr-btn-success-bg, var(--bs-success, #28a745));',
    '  --_btn-success-hover: var(--rocleteer-webr-btn-success-hover, var(--bs-success-hover, #1e7e34));',
    '  --_btn-secondary-bg: var(--rocleteer-webr-btn-secondary-bg, var(--bs-secondary, #6c757d));',
    '  --_btn-secondary-hover: var(--rocleteer-webr-btn-secondary-hover, var(--bs-secondary-hover, #545b62));',
    '  --_text-color: var(--rocleteer-webr-text-color, var(--bs-body-color, #333));',
    '  --_text-emphasis: var(--rocleteer-webr-text-emphasis, var(--bs-emphasis-color, #000));',
    '  --_container-padding: var(--rocleteer-webr-container-padding, 16px);',
    '  --_container-margin: var(--rocleteer-webr-container-margin, 16px 0);',
    '  --_btn-padding: var(--rocleteer-webr-btn-padding, 12px 20px);',
    '  --_btn-margin: var(--rocleteer-webr-btn-margin, 0 8px 0 0);',
    '  --_font-size: var(--rocleteer-webr-font-size, var(--bs-body-font-size, 14px));',
    '  --_font-weight-bold: var(--rocleteer-webr-font-weight-bold, var(--bs-font-weight-bold, 700));',
    '  border: 1px solid var(--_container-border);',
    '  border-radius: var(--_container-border-radius);',
    '  padding: var(--_container-padding);',
    '  margin: var(--_container-margin);',
    '  background-color: var(--_container-bg);',
    '  color: var(--_text-color);',
    '  font-size: var(--_font-size);',
    '}',
    '.rocleteer-webr-warning {',
    '  background-color: var(--_warning-bg);',
    '  border: 1px solid var(--_warning-border);',
    '  border-radius: var(--bs-border-radius, 4px);',
    '  padding: 12px;',
    '  margin-bottom: 16px;',
    '  color: var(--_warning-text);',
    '  font-size: var(--_font-size);',
    '}',
    '.rocleteer-webr-warning strong {',
    '  font-weight: var(--_font-weight-bold);',
    '}',
    '.rocleteer-webr-btn {',
    '  display: inline-block;',
    '  padding: var(--_btn-padding);',
    '  margin: var(--_btn-margin);',
    '  border: none;',
    '  border-radius: var(--bs-border-radius, 4px);',
    '  cursor: pointer;',
    '  text-decoration: none;',
    '  font-size: var(--_font-size);',
    '  color: white;',
    '  transition: background-color 0.15s ease-in-out;',
    '}',
    '.rocleteer-webr-btn-primary {',
    '  background-color: var(--_btn-primary-bg);',
    '}',
    '.rocleteer-webr-btn-primary:hover {',
    '  background-color: var(--_btn-primary-hover);',
    '  color: white;',
    '  text-decoration: none;',
    '}',
    '.rocleteer-webr-btn-success {',
    '  background-color: var(--_btn-success-bg);',
    '}',
    '.rocleteer-webr-btn-success:hover {',
    '  background-color: var(--_btn-success-hover);',
    '}',
    '.rocleteer-webr-btn-secondary {',
    '  background-color: var(--_btn-secondary-bg);',
    '}',
    '.rocleteer-webr-btn-secondary:hover {',
    '  background-color: var(--_btn-secondary-hover);',
    '}',
    '.rocleteer-webr-initial-text {',
    '  margin: 8px 0;',
    '  font-weight: var(--_font-weight-bold);',
    '  color: var(--_text-emphasis);',
    '}',
    '.rocleteer-webr-iframe-container {',
    '  display: none;',
    '}',
    '.rocleteer-webr-container.rocleteer-webr-fullwidth {',
    '  position: fixed;',
    '  top: 0;',
    '  left: 0;',
    '  width: 100vw;',
    '  height: 100vh;',
    '  z-index: var(--rocleteer-webr-fullwidth-z-index, 1050);',
    '  margin: 0;',
    '  border-radius: 0;',
    '  border: none;',
    '  overflow: auto;',
    '  background-color: var(--_container-bg);',
    '  transition: all 0.3s ease-in-out;',
    '}',
    '.rocleteer-webr-container.rocleteer-webr-fullwidth .rocleteer-webr-iframe {',
    '  height: calc(100vh - 180px) !important;',
    '  border: none;',
    '}',
    '.rocleteer-webr-fullwidth-backdrop {',
    '  position: fixed;',
    '  top: 0;',
    '  left: 0;',
    '  width: 100vw;',
    '  height: 100vh;',
    '  background-color: rgba(0, 0, 0, 0.5);',
    '  z-index: var(--rocleteer-webr-backdrop-z-index, 1040);',
    '  display: none;',
    '}',
    '.rocleteer-webr-iframe-controls {',
    '  margin-bottom: 12px;',
    '}',
    '.rocleteer-webr-iframe-controls .rocleteer-webr-btn {',
    '  padding: 8px 16px;',
    '  font-size: var(--_font-size);',
    '}',
    '.rocleteer-webr-iframe {',
    '  width: 100\\%;',
    '  border: 1px solid var(--_container-border);',
    '  border-radius: var(--bs-border-radius, 4px);',
    '}',
    '@media (max-width: 576px) {',
    '  .rocleteer-webr-container {',
    '    --_container-padding: 12px;',
    '    --_btn-padding: 10px 16px;',
    '    --_font-size: 13px;',
    '  }',
    '  .rocleteer-webr-btn {',
    '    display: block;',
    '    margin: 4px 0;',
    '    text-align: center;',
    '  }',
    '  .rocleteer-webr-iframe-controls .rocleteer-webr-btn {',
    '    display: inline-block;',
    '    margin: 0 4px 0 0;',
    '    font-size: 12px;',
    '    padding: 6px 12px;',
    '  }',
    '  .rocleteer-webr-container.rocleteer-webr-fullwidth {',
    '    padding: 8px;',
    '  }',
    '  .rocleteer-webr-container.rocleteer-webr-fullwidth .rocleteer-webr-iframe {',
    '    height: calc(100vh - 120px) !important;',
    '  }',
    '}',
    '</style>'
  )
}

#' Generate webR warning HTML
#'
#' Create standardized warning message for webR examples
#'
#' @return 
#' HTML string with warning message and contact information
#' 
#' @noRd
webr_experimental_warning <- function() {
  paste0(
    '<div class="rocleteer-webr-warning">',
    '<strong>\U0001F9EA Experimental:</strong> Interactive webR examples are a new feature. ',
    'Loading may take a moment, and the package version might differ from this documentation.',
    '</div>'
  )
}

#' Generate webR REPL link
#' 
#' Create a webR URL with version, mode, channel, and encoded code
#'
#' @param encoded_code Base64 encoded code with flags
#' @param version webR version (e.g. "latest", "v0.5.4"). Default: `"latest"`
#' @param mode webR interface mode (e.g., "editor-plot-terminal-files"). Default: `""`
#' @param channel webR channel (e.g., "Automatic"). Default: `""`
#'  
#' @return
#' A URL string for the webR REPL
#' 
#' @keywords internal
webr_repl_href <- function(encoded_code, version = "latest", mode = "", channel = "") {
  base_url <- paste0("https://webr.r-wasm.org/", version,"/")
  
  # Build query parameters
  query_params <- c()
  
  if (nzchar(mode)) {
    query_params <- c(query_params, paste0("mode=", mode))
  }
  
  if (nzchar(channel)) {
    query_params <- c(query_params, paste0("channel=", channel))
  }
  
  # Construct URL
  if (length(query_params) > 0) {
    url <- paste0(base_url, "?", paste(query_params, collapse = "&"), "#code=", encoded_code)
  } else {
    url <- paste0(base_url, "#code=", encoded_code)
  }
  
  return(url)
  
}

#' Generate webR link HTML
#'
#' Create HTML for webR REPL link
#'
#' @param encoded_code Base64 encoded code
#' @param version webR version
#' @param mode webR interface mode
#' @param channel webR channel
#'  
#' @return 
#' HTML string for link
#' 
#' @noRd
webr_repl_link <- function(encoded_code, version = "latest", mode = "", channel = "") {
  url <- webr_repl_href(encoded_code, version, mode, channel)
  html <- paste0(
    # Include CSS
    # TODO: Figure out how to include it once? Post parser re-write?
    webr_inline_css(),
    
    '<div class="rocleteer-webr-container">',
    
    # Warning message
    webr_experimental_warning(),
    
    # Link button
    '<p><a href="', url, '" target="_blank" class="rocleteer-webr-btn rocleteer-webr-btn-primary">',
    '\U0001F310 View in webR REPL</a></p>',
    
    '</div>'
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
#' @param mode webR interface mode
#' @param channel webR channel
#' 
#' @return 
#' HTML string for iframe
#' 
#' @noRd
webr_repl_iframe <- function(encoded_code, version = "latest", height = 300, mode = "", channel = "") {
  url <- webr_repl_href(encoded_code, version, mode, channel)
  
  # Create an ID for this iframe (based on the encoded code)
  hashed_id <- abs(sum(utf8ToInt(substr(encoded_code, 1, 10))))
  iframe_id <- paste0("webr_iframe_", hashed_id)
  
  html <- paste0(
    # Include CSS once
    webr_inline_css(),
    
    '<div class="rocleteer-webr-container">',
    
    # Warning message
    webr_experimental_warning(),
    
    # Initial buttons (before iframe loads)
    '<div id="', iframe_id, '_initial" class="rocleteer-webr-initial">',
    '<p class="rocleteer-webr-initial-text">Interactive Example Available</p>',
    '<button onclick="loadWebRIframe(\'', iframe_id, '\', \'', url, '\', ', height, ', false)" ',
    'class="rocleteer-webr-btn rocleteer-webr-btn-success rocleteer-webr-btn-try">',
    '\U0001F680 Try it in your browser</button>',
    '<button onclick="window.open(\'', url, '\', \'_blank\')" ',
    'class="rocleteer-webr-btn rocleteer-webr-btn-primary rocleteer-webr-btn-open">',
    '\U0001F310 Open in Tab</button>',
    '</div>',
    
    # Iframe container (hidden initially)
    '<div id="', iframe_id, '_container" class="rocleteer-webr-iframe-container">',
    '<div class="rocleteer-webr-iframe-controls">',
    '<button onclick="hideWebRIframe(\'', iframe_id, '\')" ',
    'class="rocleteer-webr-btn rocleteer-webr-btn-secondary rocleteer-webr-btn-back">',
    '\U0001F519 Go back</button>',
    '<button onclick="toggleWebRFullWidth(\'', iframe_id, '\')" ',
    'class="rocleteer-webr-btn rocleteer-webr-btn-primary rocleteer-webr-btn-toggle" ',
    'id="', iframe_id, '_toggle">',
    '\U00026F6 Full Screen</button>',
    '<button onclick="window.open(\'', url, '\', \'_blank\')" ',
    'class="rocleteer-webr-btn rocleteer-webr-btn-primary rocleteer-webr-btn-open">',
    '\U0001F310 Open in Tab</button>',
    '</div>',
    '<div id="', iframe_id, '_content" class="rocleteer-webr-iframe-content"></div>',
    '</div>',
    
    '</div>',
    
    # JavaScript for iframe management
    '<script>',
    'function loadWebRIframe(id, url, height, fullwidth) {',
    '  fullwidth = fullwidth || false;',
    '  document.getElementById(id + "_initial").style.display = "none";',
    '  document.getElementById(id + "_container").style.display = "block";',
    '  document.getElementById(id + "_content").innerHTML = ',
    '    \'<iframe src="\' + url + \'" class="rocleteer-webr-iframe" height="\' + height + \'px" \' +',
    '    \'title="webR REPL"></iframe>\';',
    '  if (fullwidth) {',
    '    enterWebRFullWidth(id);',
    '  }',
    '}',
    'function hideWebRIframe(id) {',
    '  exitWebRFullWidth(id);',
    '  document.getElementById(id + "_initial").style.display = "block";',
    '  document.getElementById(id + "_container").style.display = "none";',
    '  document.getElementById(id + "_content").innerHTML = "";',
    '}',
    'function toggleWebRFullWidth(id) {',
    '  var container = document.getElementById(id + "_container").closest(".rocleteer-webr-container");',
    '  if (container.classList.contains("rocleteer-webr-fullwidth")) {',
    '    exitWebRFullWidth(id);',
    '  } else {',
    '    enterWebRFullWidth(id);',
    '  }',
    '}',
    'function enterWebRFullWidth(id) {',
    '  var container = document.getElementById(id + "_container").closest(".rocleteer-webr-container");',
    '  var backdrop = document.createElement("div");',
    '  backdrop.className = "rocleteer-webr-fullwidth-backdrop";',
    '  backdrop.id = id + "_backdrop";',
    '  backdrop.onclick = function() { exitWebRFullWidth(id); };',
    '  document.body.appendChild(backdrop);',
    '  backdrop.style.display = "block";',
    '  container.classList.add("rocleteer-webr-fullwidth");',
    '  document.body.style.overflow = "hidden";',
    '  var toggleBtn = document.getElementById(id + "_toggle");',
    '  if (toggleBtn) {',
    '    toggleBtn.innerHTML = "\\u274C Exit Full Screen";',
    '  }',
    '}',
    'function exitWebRFullWidth(id) {',
    '  var container = document.getElementById(id + "_container").closest(".rocleteer-webr-container");',
    '  var backdrop = document.getElementById(id + "_backdrop");',
    '  if (backdrop) {',
    '    backdrop.remove();',
    '  }',
    '  container.classList.remove("rocleteer-webr-fullwidth");',
    '  document.body.style.overflow = "";',
    '  var toggleBtn = document.getElementById(id + "_toggle");',
    '  if (toggleBtn) {',
    '    toggleBtn.innerHTML = "\\u26F6 Full width";',
    '  }',
    '}',
    '</script>'
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
  
  # Read global config from DESCRIPTION (we'll need base_path in roxy_tag_rd)
  # For now, store the tag parameters for later processing
  x$tag_line <- lines[1]
  
  # Extract the actual code (skip first line if it contains only the tag)
  code_lines <- if (grepl("^\\s*$", lines[2])) lines[-c(1, 2)] else lines[-1]
  code <- paste(code_lines, collapse = "\n")
  
  # Process as examples tag first
  x$raw <- paste(code_lines, collapse = "\n")
  x$tag <- "examples"
  results <- roxygen2::tag_examples(x)
  
  # Store the original code and tag line for later processing
  results$original_code <- code
  results$tag_line <- x$tag_line
  
  return(results)
}

#' @noRd
#' @exportS3Method roxygen2::roxy_tag_rd roxy_tag_examplesWebR
roxy_tag_rd.roxy_tag_examplesWebR <- function(x, base_path, env) {
  
  # If no original code, just return examples
  if (is.null(x$original_code) || !nzchar(trimws(x$original_code))) {
    return(roxygen2::rd_section("examples", x$val))
  }
  
  global_config <- list()
  
  # Read global configuration from DESCRIPTION
  tryCatch({
    global_config <- read_webr_config(base_path)
  }, error = function(e) {
    warning("Failed to read webR config from DESCRIPTION:\n", e$message)
  })
  
  # Parse parameters, merging tag-level with global config
  params <- parse_webr_params(x$tag_line %||% "", global_config)
  
  # Generate package installation code if we have repo info
  install_code <- ""
  if (!is.null(global_config$webr_repo) && !is.null(global_config$package_name)) {
    tryCatch({
      install_code <- generate_package_install_code(global_config$package_name, global_config$webr_repo)
    }, error = function(e) {
      warning("Failed to generate package installation code: ", e$message)
    })
  }
  
  # Combine installation code with original example code
  full_code <- paste0(install_code, x$original_code)
  
  # Encode the code for webR
  webr_data <- NULL
  tryCatch({
    encoded_code <- encode_webr_code(full_code, autorun = params$autorun)
    
    # Generate the webR URL for all formats
    webr_url <- paste0("https://webr.r-wasm.org/", params$version, "/#code=", encoded_code)
    
    # Generate webR integration HTML for HTML format
    webr_html <- if (params$embed) {
      webr_repl_iframe(encoded_code, params$version, params$height, params$mode, params$channel)
    } else {
      webr_repl_link(encoded_code, params$version, params$mode, params$channel)
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
    return(list(
      roxygen2::rd_section("examples", x$val),
      webr_section
    ))
    
  }, error = function(e) {
    warning("Failed to create webR integration: ", e$message)
    return(roxygen2::rd_section("examples", x$val))
  })
}
