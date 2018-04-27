###################
# main_setup.R
# Subroutines for common modeling setup
###################

###################
# CONSTANTS
###################

SNR_BETA_LOC <- 0  # Location of beta prior for simple normal regression
SNR_BETA_SCALE <- 10  # Scale of beta prior for simple normal regression
SNR_SIGMA_LOC <- 0  # Location of sigma prior for simple normal regression
SNR_SIGMA_SCALE <- 10  # Scale of sigma prior for simple normal regression
EXP_LAMBDA <- 1/10 # Rate for exponential prior in robust regression
NUM_REPL <- 100  # Number of replication data sets for posterior predictive check


# Set the random number generator seed
set.seed(1118)

# Load libraries
library(plyr)
library(dplyr)
library(GGally)
library(shinystan)
library(rstan)
library(openxlsx)
library(boot)
library(loo)
library(bayesplot)
library(ggplot2)
library(gridExtra)
library(grid)

# Stan options
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Source files to get functions
source("helper_functions.R")

# Preprocess the data
df.full <- openxlsx::read.xlsx('./Output Data/DOE test runs.xlsx')

# Thin the data set
df.thinned <- thinDataSet(df.full, 'Test_ID', 1)

# All numeric variables
numericVars <- colnames(df.full)[grepl("X_PI", names(df.full))]

# make data frame with only PIs and Valve_Type
df <- df.full[, numericVars]
df.thinned <- df.thinned[, numericVars]

# Dependent variable
depVar <- c("X_PI_0") 

# Explanatory variables
expVars <- numericVars[!numericVars %in% depVar]

# Set the name of the column of the dependent variable to Y
colnames(df)[1] <- "Y"
colnames(df.thinned)[1] <- "Y"
