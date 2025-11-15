#!/usr/bin/env Rscript
# chatAI4R Package Repair Script
#
# This script fixes corrupted help database errors by reinstalling chatAI4R from GitHub
#
# Error this fixes:
# "Error in fetch(key): lazy-load database '...chatAI4R.rdb' is corrupt"
#
# Usage:
#   From R console:
#     system.file("rebuild_package.R", package = "chatAI4R") |> source()
#
#   Or if chatAI4R cannot load:
#     source(file.path(find.package("chatAI4R"), "rebuild_package.R"))
#
# Author: chatAI4R package maintainers
# Last updated: 2025-11-16

cat("\n")
cat("========================================\n")
cat("  chatAI4R Package Repair Tool\n")
cat("========================================\n\n")

# Check if running interactively
if (!interactive()) {
  cat("Warning: This script should be run in an interactive R session.\n")
  cat("Starting repair process...\n\n")
}

# Function to check and install required packages
check_and_install <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing required package:", pkg, "...\n")
    install.packages(pkg, repos = "https://cloud.r-project.org/")
    return(TRUE)
  }
  return(FALSE)
}

# Step 1: Install remotes if needed (for GitHub installation)
cat("Step 1: Checking required packages...\n")
check_and_install("remotes")
cat("  -> Required packages ready\n\n")

# Step 2: Uninstall corrupted package
cat("Step 2: Removing corrupted chatAI4R installation...\n")
removal_success <- tryCatch({
  remove.packages("chatAI4R")
  cat("  -> Package removed successfully\n\n")
  TRUE
}, error = function(e) {
  cat("  -> Warning: Could not remove package:", conditionMessage(e), "\n")
  cat("  -> Continuing with reinstallation...\n\n")
  FALSE
})

# Step 3: Clean package cache (if exists)
cat("Step 3: Cleaning package cache...\n")
cache_paths <- c(
  "~/.Rcache/chatAI4R",
  file.path(tempdir(), "chatAI4R")
)
for (cache_path in cache_paths) {
  expanded_path <- path.expand(cache_path)
  if (dir.exists(expanded_path)) {
    unlink(expanded_path, recursive = TRUE)
    cat("  -> Removed cache:", expanded_path, "\n")
  }
}
cat("  -> Cache cleaning complete\n\n")

# Step 4: Reinstall from GitHub
cat("Step 4: Reinstalling chatAI4R from GitHub...\n")
cat("  -> Repository: kumeS/chatAI4R\n")
cat("  -> This may take a few minutes...\n\n")

install_success <- tryCatch({
  remotes::install_github(
    "kumeS/chatAI4R",
    upgrade = "never",
    force = TRUE,
    build_vignettes = FALSE,
    quiet = FALSE
  )
  cat("\n  -> Installation completed successfully\n\n")
  TRUE
}, error = function(e) {
  cat("\n  -> ERROR during installation:", conditionMessage(e), "\n")
  cat("  -> Please check your internet connection and GitHub access\n\n")
  FALSE
})

if (!install_success) {
  cat("========================================\n")
  cat("  Installation FAILED\n")
  cat("========================================\n\n")
  cat("Troubleshooting steps:\n")
  cat("1. Check internet connection\n")
  cat("2. Verify GitHub is accessible\n")
  cat("3. Try manual installation:\n")
  cat("   remotes::install_github('kumeS/chatAI4R', force = TRUE)\n\n")
  stop("Package installation failed. See messages above.")
}

# Step 5: Verify installation
cat("Step 5: Verifying installation...\n")

verification_passed <- FALSE
tryCatch({
  # Try to load the package
  library(chatAI4R)
  cat("  -> Package loaded successfully\n")

  # Check if help system works
  help_test <- tryCatch({
    h <- help("chat4R", package = "chatAI4R")
    !is.null(h)
  }, error = function(e) FALSE)

  if (help_test) {
    cat("  -> Help system verified\n")
    verification_passed <- TRUE
  } else {
    cat("  -> Warning: Help system may need R restart\n")
  }

  # List some functions to verify
  funcs <- c("chat4R", "chat4R_history", "gemini4R", "multiLLMviaionet")
  available_funcs <- funcs[funcs %in% ls("package:chatAI4R")]
  cat("  -> Available functions:", length(available_funcs), "/", length(funcs), "\n")

}, error = function(e) {
  cat("  -> Error during verification:", conditionMessage(e), "\n")
})

# Final message
cat("\n")
cat("========================================\n")
if (verification_passed) {
  cat("  Repair SUCCESSFUL!\n")
} else {
  cat("  Repair COMPLETED (verification pending)\n")
}
cat("========================================\n\n")

cat("Next steps:\n")
cat("1. RESTART R SESSION:\n")
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  cat("   - Use: .rs.restartR()\n")
  cat("   - Or: Session > Restart R (Ctrl+Shift+F10 / Cmd+Shift+F10)\n")
} else {
  cat("   - Close and reopen R\n")
}
cat("\n2. After restart, test the package:\n")
cat("   library(chatAI4R)\n")
cat("   ?chat4R\n\n")

# Ask if user wants to restart now (RStudio only)
if (interactive() && requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  restart_now <- readline(prompt = "Restart R now? (y/n): ")
  if (tolower(trimws(restart_now)) %in% c("y", "yes")) {
    cat("\nRestarting R session...\n")
    rstudioapi::restartSession()
  }
}

cat("\nThank you for using chatAI4R!\n\n")

invisible(TRUE)
