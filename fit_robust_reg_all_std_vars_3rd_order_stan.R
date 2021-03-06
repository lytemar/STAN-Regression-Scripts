# fit_robust_reg_all_std_vars_3rd_order_stan.R

# Get the prefix from the file name
prefix <- tools::file_path_sans_ext(getSrcFilename(function(x) {x}))

# Model setup: variable transformations, dataframe subsets, model formulas, etc.
source("main_setup.R")

# Use the thinned data set
df_robust_reg_all_std_vars_3rd_order = df

##########################################################
# Fit robust regression in Stan using all standardized variables
##########################################################
assign(prefix,
       fit_stan_model(
         stan_file = 'robust_regression.stan',
         prefix = prefix,
         df = df_robust_reg_all_std_vars_3rd_order,
         params = list(beta_loc=SNR_BETA_LOC, beta_scale=SNR_BETA_SCALE, 
                       sigma_loc=SNR_SIGMA_LOC, sigma_scale=SNR_SIGMA_SCALE,
                       expLambda = EXP_LAMBDA),
         control = list(max_treedepth = 20),
         chains = 16,
         orders = 3,
         iter = 1000,
         fit_pars = c("beta", "sigma", "nu")
         )
       )
