#!/usr/bin/env Rscript

# =============================================================================
# chatAI4R Package Examples Extractor v1.0
# =============================================================================
# Extract all @examples sections from R/*.R files and combine them into a 
# single executable R file.
#
# FEATURES:
# • Extracts @examples sections from all R files in R/ directory
# • Removes roxygen2 comment prefixes (#')
# • Handles \dontrun{} blocks by unwrapping them
# • Adds function name headers for organization
# • Creates a single executable R file
#
# OUTPUT: all_examples_combined.R
# =============================================================================

# Function to extract examples from a single R file
extract_examples_from_file <- function(file_path) {
  
  # Read the file
  lines <- readLines(file_path, warn = FALSE)
  
  # Find all @examples sections
  examples_start <- grep("^#'\\s*@examples", lines)
  
  if (length(examples_start) == 0) {
    return(NULL)  # No examples found
  }
  
  all_examples <- list()
  
  for (i in seq_along(examples_start)) {
    start_line <- examples_start[i]
    
    # Find the end of this examples section
    # Look for the next roxygen tag (@param, @return, @export, etc.) or end of roxygen comments
    end_line <- length(lines)
    
    for (j in (start_line + 1):length(lines)) {
      # Check if we hit another roxygen tag or end of roxygen comments
      if (grepl("^#'\\s*@[a-zA-Z]", lines[j]) || 
          !grepl("^#'", lines[j]) || 
          grepl("^[a-zA-Z_][a-zA-Z0-9_]*\\s*<-", lines[j])) {
        end_line <- j - 1
        break
      }
    }
    
    # Extract the examples section
    examples_lines <- lines[(start_line + 1):end_line]
    
    # Remove empty lines at the end
    while (length(examples_lines) > 0 && grepl("^#'\\s*$", examples_lines[length(examples_lines)])) {
      examples_lines <- examples_lines[-length(examples_lines)]
    }
    
    if (length(examples_lines) > 0) {
      all_examples[[length(all_examples) + 1]] <- examples_lines
    }
  }
  
  return(all_examples)
}

# Function to process examples lines
process_examples_lines <- function(examples_lines) {
  if (length(examples_lines) == 0) {
    return(character(0))
  }
  
  # Remove #' prefix from all lines
  processed_lines <- gsub("^#'\\s*", "", examples_lines)
  
  # Handle \dontrun{} blocks
  in_dontrun <- FALSE
  result_lines <- character(0)
  
  for (line in processed_lines) {
    if (grepl("\\\\dontrun\\s*\\{", line)) {
      in_dontrun <- TRUE
      # Remove \dontrun{ part
      line <- gsub("\\\\dontrun\\s*\\{", "", line)
      # If line becomes empty after removal, skip it
      if (nchar(trimws(line)) == 0) {
        next
      }
    }
    
    if (in_dontrun && grepl("\\}", line)) {
      in_dontrun <- FALSE
      # Remove the closing } 
      line <- gsub("\\}", "", line)
      # If line becomes empty after removal, skip it
      if (nchar(trimws(line)) == 0) {
        next
      }
    }
    
    # Add non-empty lines
    if (nchar(trimws(line)) > 0) {
      result_lines <- c(result_lines, line)
    }
  }
  
  return(result_lines)
}

# Main extraction function
main <- function() {
  cat("Starting extraction of @examples sections from R/*.R files...\n")
  
  # Get list of R files
  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  
  if (length(r_files) == 0) {
    stop("No R files found in R/ directory")
  }
  
  cat("Found", length(r_files), "R files\n")
  
  # Initialize output
  output_lines <- c(
    "# =============================================================================",
    "# Combined Examples from chatAI4R Package",
    paste("# Generated on:", Sys.time()),
    "# =============================================================================",
    "",
    "# Load the chatAI4R package",
    "library(chatAI4R)",
    "",
    "# Note: Some examples may require API keys to be set:",
    "# Sys.setenv(OPENAI_API_KEY = 'your_openai_key')",
    "# Sys.setenv(GoogleGemini_API_KEY = 'your_gemini_key')",
    "# Sys.setenv(Replicate_API_KEY = 'your_replicate_key')",
    "# Sys.setenv(IONET_API_KEY = 'your_ionet_key')",
    "",
    "# =============================================================================",
    ""
  )
  
  total_examples <- 0
  files_with_examples <- 0
  
  # Process each file
  for (file_path in r_files) {
    file_name <- basename(file_path)
    function_name <- gsub("\\.R$", "", file_name)
    
    cat("Processing:", file_name, "...")
    
    examples_list <- extract_examples_from_file(file_path)
    
    if (!is.null(examples_list) && length(examples_list) > 0) {
      files_with_examples <- files_with_examples + 1
      
      # Add function header
      output_lines <- c(
        output_lines,
        paste("# -----------------------------------------------------------------------------"),
        paste("#", function_name, "examples"),
        paste("# -----------------------------------------------------------------------------"),
        ""
      )
      
      # Process each examples section in this file
      for (j in seq_along(examples_list)) {
        examples_lines <- examples_list[[j]]
        processed_lines <- process_examples_lines(examples_lines)
        
        if (length(processed_lines) > 0) {
          total_examples <- total_examples + 1
          
          if (length(examples_list) > 1) {
            output_lines <- c(output_lines, paste("#", function_name, "- Example", j))
          }
          
          output_lines <- c(output_lines, processed_lines, "")
        }
      }
      
      cat(" Found", length(examples_list), "example(s)\n")
    } else {
      cat(" No examples found\n")
    }
  }
  
  # Add final note
  output_lines <- c(
    output_lines,
    "# =============================================================================",
    "# End of Combined Examples",
    paste("# Total functions with examples:", files_with_examples),
    paste("# Total example sections:", total_examples),
    "# ============================================================================="
  )
  
  # Write output file
  output_file <- "all_examples_combined.R"
  writeLines(output_lines, output_file)
  
  cat("\n=== EXTRACTION SUMMARY ===\n")
  cat("Files processed:", length(r_files), "\n")
  cat("Files with examples:", files_with_examples, "\n")
  cat("Total example sections:", total_examples, "\n")
  cat("Output file:", output_file, "\n")
  cat("Extraction completed successfully!\n")
  
  return(invisible(output_file))
}

# Run the extraction
if (!interactive()) {
  main()
} else {
  cat("Run main() to extract examples\n")
} 