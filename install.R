#!/usr/bin/env Rscript

#--------------------------------------------------------
# configuration for c++11 compiler flags
# pretty agressive - on modern processors speedup is ~ 2x over "-O3"
COMPILER_FLAGS = c("CXX1XFLAGS" = "-mtune=native -Ofast")
# point CRAN repository
CRAN_REPO = "https://cran.rstudio.com/"
USR_LIB = Sys.getenv("R_LIBS_USER")
if(!dir.exists(USR_LIB))
  dir.create(USR_LIB, recursive = TRUE)

#--------------------------------------------------------
# install "withr" package for temporary modification of Makevars
# isntall "devtools" for installing packages from github
# isntall "readr" for I/O management 

install.packages(c("withr", "devtools", "readr"), repos = CRAN_REPO, lib = USR_LIB)
#--------------------------------------------------------
# isntall "text2vec" from source with agressive Makevars
inst_pkgs = function() {
  devtools::install_github("dselivanov/text2vec", lib = USR_LIB)
}
withr::with_makevars(COMPILER_FLAGS, 
                     code = inst_pkgs(), 
                     assignment = "+=")
#--------------------------------------------------------