#!/usr/bin/env Rscript
# Script to regenerate package documentation
# Run this script from the package root directory

cat("Regenerating package documentation...\n")

# Check if roxygen2 is installed
if (!requireNamespace("roxygen2", quietly = TRUE)) {
  cat("Installing roxygen2...\n")
  install.packages("roxygen2")
}

# Check if devtools is installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  cat("Installing devtools...\n")
  install.packages("devtools")
}

# Regenerate documentation
cat("Running roxygen2::roxygenize()...\n")
roxygen2::roxygenize()

cat("\nDocumentation regenerated successfully!\n")
cat("\nNext steps:\n")
cat("1. Review the changes in man/ and NAMESPACE\n")
cat("2. Run devtools::check() to verify the package\n")
cat("3. Commit the updated documentation files\n")
