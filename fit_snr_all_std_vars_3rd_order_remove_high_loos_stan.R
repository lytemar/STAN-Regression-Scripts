# fit_snr_all_std_vars_3rd_order_remove_high_loos_stan.R

# Get the prefix from the file name
prefix <- tools::file_path_sans_ext(getSrcFilename(function(x) {x}))

# Model setup: variable transformations, dataframe subsets, model formulas, etc.
source("main_setup.R")

# Order of the model
mod.order = 3

# Use the thinned data set
df_snr_all_std_vars_3rd_order_remove_high_loos = df

# Remove rows with LOOCV p_loo > 0.7
df_snr_all_std_vars_3rd_order_remove_high_loos =
  df_snr_all_std_vars_3rd_order_remove_high_loos[-c(381, 366),]
df_snr_all_std_vars_3rd_order_remove_high_loos =
  df_snr_all_std_vars_3rd_order_remove_high_loos[-c(380),]
df_snr_all_std_vars_3rd_order_remove_high_loos =
  df_snr_all_std_vars_3rd_order_remove_high_loos[-c(393, 455),]
  
# Generate the special model matrix for potential feature reduction
X <- list()
X[[1]] <- genModelMatrix(df_snr_all_std_vars_3rd_order_remove_high_loos, order = mod.order)

# Remove insignificant terms
# X[[1]] <- X[[1]][, -c(39, 41, 44, 45, 49, 51, 53, 54, 55, 56)]

##########################################################
# Fit simple linear models using all standardized variables
##########################################################
assign(prefix, 
       fit_stan_model(
         stan_file = 'simple_normal_regression.stan',
         prefix = prefix,
		 X_mats = X,
         df = df_snr_all_std_vars_3rd_order_remove_high_loos,
         params = list(beta_loc=SNR_BETA_LOC, beta_scale=SNR_BETA_SCALE, 
                       sigma_loc=SNR_SIGMA_LOC, sigma_scale=SNR_SIGMA_SCALE),
         control = list(max_treedepth = 20),
         chains = 16,
         orders = mod.order,
         iter = 1000,
         fit_pars = c("beta", "sigma")
         )
       )