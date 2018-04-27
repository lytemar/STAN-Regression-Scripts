# fit_snr_all_std_vars_3rd_4th_order_stan.R

# Get the prefix from the file name
prefix <- tools::file_path_sans_ext(getSrcFilename(function(x) {x}))

# Model setup: variable transformations, dataframe subsets, model formulas, etc.
source("main_setup.R")

# Use the thinned data set
df_snr_all_std_vars_3rd_4th_order = df

##########################################################
# Fit simple linear models using all standardized variables
##########################################################
assign(prefix,
       fit_stan_model(
         stan_file = 'simple_normal_regression.stan',
         prefix = prefix,
         df = df_snr_all_std_vars_3rd_4th_order,
         params = list(beta_loc=SNR_BETA_LOC, beta_scale=SNR_BETA_SCALE, 
                       sigma_loc=SNR_SIGMA_LOC, sigma_scale=SNR_SIGMA_SCALE),
         control = list(max_treedepth = 20),
         chains = 16,
         orders = 3:4,
         iter = c(1000, 1000),
         fit_pars = c("beta", "sigma")
         )
       )