# Linux Installation Guide for chatAI4R

## 🐧 Quick Start for Linux Users

This guide provides step-by-step instructions for installing **chatAI4R** on Linux systems.

---

## Problem: "dependency 'pdftools' is not available"

If you see this error:
```
ERROR: dependency 'pdftools' is not available for package 'chatAI4R'
```

This happens because the `pdftools` R package requires system libraries that aren't installed by default on Linux.

---

## ✅ Solution 1: Install with Full PDF Support (Recommended)

Follow these steps to install chatAI4R with complete PDF processing functionality:

### Step 1: Install System Dependencies

Choose your Linux distribution:

#### **Ubuntu / Debian / Linux Mint**
```bash
sudo apt-get update
sudo apt-get install -y libqpdf-dev
```

#### **CentOS / RHEL (versions 7-8)**
```bash
sudo yum install -y qpdf-devel
```

#### **Rocky Linux / AlmaLinux / Fedora (newer versions)**
```bash
sudo dnf install -y qpdf-devel
```

#### **Arch Linux / Manjaro**
```bash
sudo pacman -S qpdf
```

#### **openSUSE**
```bash
sudo zypper install qpdf-devel
```

### Step 2: Verify System Library Installation

```bash
# Check if qpdf library is installed
ldconfig -p | grep qpdf
```

You should see output like:
```
libqpdf.so.29 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libqpdf.so.29
```

### Step 3: Install pdftools in R

Open R and run:
```r
# Install pdftools first
install.packages("pdftools")

# Verify installation
library(pdftools)
```

If successful, you'll see no errors.

### Step 4: Install chatAI4R

```r
# Now install chatAI4R with all dependencies
install.packages("chatAI4R")

# Load the package
library(chatAI4R)
```

---

## ⚡ Solution 2: Install Without PDF Support (Quick Install)

If you **don't need PDF processing** functionality, you can skip system dependencies:

```r
# Install without optional dependencies
install.packages("chatAI4R", dependencies = FALSE)

# Load the package
library(chatAI4R)
```

**What works:**
- ✅ All AI chat functions (`chat4R`, `gemini4R`, etc.)
- ✅ Multi-LLM execution (`multiLLMviaionet`)
- ✅ Text processing and summarization
- ✅ R package development tools
- ✅ All core, workflow, and expertise functions

**What doesn't work:**
- ❌ `chatAI4pdf()` - PDF document analysis

The package will show a helpful error message if you try to use PDF functions without `pdftools` installed.

---

## 🔍 Troubleshooting

### Issue: "libqpdf.so: cannot open shared object file"

**Solution:** The system library is installed but not found. Update the library cache:

```bash
sudo ldconfig
```

Then restart R and try installing pdftools again.

### Issue: "Permission denied" during system library installation

**Solution:** You need administrator privileges. Use `sudo` with the installation commands.

### Issue: "Package not found" when installing system libraries

**Solution:** Update your package manager's repository list first:

**Ubuntu/Debian:**
```bash
sudo apt-get update
```

**CentOS/RHEL:**
```bash
sudo yum update
```

**Fedora/Rocky Linux:**
```bash
sudo dnf update
```

### Issue: Installation works but pdftools fails to load

**Solution:** Check if you have compatible system library versions:

```r
# In R, check system info
Sys.info()

# Try reinstalling pdftools from source
install.packages("pdftools", type = "source")
```

---

## 📦 Development Version Installation (Linux)

For the latest development version from GitHub:

### With PDF support:
```bash
# 1. Install system dependencies first (see Step 1 above)

# 2. Install from GitHub in R
install.packages("devtools")
devtools::install_github("kumeS/chatAI4R")
```

### Without PDF support:
```r
# Install from GitHub without optional dependencies
devtools::install_github("kumeS/chatAI4R", dependencies = FALSE)
```

---

## 🧪 Verify Installation

After installation, verify everything works:

```r
# Load the package
library(chatAI4R)

# Check package version
packageVersion("chatAI4R")

# Test basic functionality (requires OpenAI API key)
Sys.setenv(OPENAI_API_KEY = "your-api-key")
chat4R("Hello, world!")

# If you installed with PDF support, test it:
if (requireNamespace("pdftools", quietly = TRUE)) {
  cat("✅ PDF functionality available\n")
} else {
  cat("❌ PDF functionality not available (pdftools not installed)\n")
}
```

---

## 📋 System Requirements

- **R**: Version 4.2.0 or higher
- **Linux**: Most modern distributions (Ubuntu 18.04+, CentOS 7+, Fedora 30+, etc.)
- **System Libraries** (optional, for PDF support):
  - `libqpdf-dev` (Debian/Ubuntu)
  - `qpdf-devel` (RHEL/CentOS/Fedora)

---

## 🆘 Still Having Issues?

1. **Check R version:**
   ```r
   R.version.string
   ```
   Make sure you have R ≥ 4.2.0

2. **Check system library installation:**
   ```bash
   dpkg -l | grep qpdf        # Debian/Ubuntu
   rpm -qa | grep qpdf        # RHEL/CentOS/Fedora
   ```

3. **Try installing dependencies manually:**
   ```r
   # Install all required packages first
   install.packages(c("httr", "jsonlite", "assertthat", "clipr",
                      "crayon", "rstudioapi", "future", "igraph",
                      "xml2", "rvest", "curl", "base64enc", "glue"))

   # Then try chatAI4R again
   install.packages("chatAI4R")
   ```

4. **Report an issue:** If you still encounter problems, please report them at:
   - GitHub: https://github.com/kumeS/chatAI4R/issues
   - Include:
     - Your Linux distribution and version: `lsb_release -a`
     - R version: `R.version.string`
     - Error messages
     - Output of `sessionInfo()`

---

## 🌟 Additional Resources

- **Main README:** [README.md](README.md)
- **GitHub Repository:** https://github.com/kumeS/chatAI4R
- **Package Documentation:** https://kumes.github.io/chatAI4R/
- **Bug Reports:** https://github.com/kumeS/chatAI4R/issues

---

## 📝 Summary

**Option 1 - Full Installation (with PDF support):**
```bash
# In terminal
sudo apt-get install libqpdf-dev  # or equivalent for your distro

# In R
install.packages("pdftools")
install.packages("chatAI4R")
```

**Option 2 - Quick Installation (without PDF support):**
```r
# In R only
install.packages("chatAI4R", dependencies = FALSE)
```

Both options give you access to all core AI functionality. Choose based on whether you need PDF document processing.
