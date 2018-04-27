# fit_normal_hierarchical_all_std_vars_stan.R

# Get the prefix from the file name
prefix <- tools::file_path_sans_ext(getSrcFilename(function(x) {x}))

# Model setup: variable transformations, dataframe subsets, model formulas, etc.
source("main_setup.R")

# Use the thinned data set
df_normal_hierarchical_all_std_vars = df

##########################################################
# Fit hierarchical normal regression using all standardized variables
##########################################################
assign(prefix,
       fit_stan_model(
         stan_file = 'hierarchical_normal_regression.stan',
         prefix = prefix,
         df = df_normal_hierarchical_all_std_vars,
         form_list = polyForms,
         params = list(id=id, J=J),
		 # control = list(max_treedepth = 20),
         chains = 8,
         orders = 1:4,
         iter = c(2000, 2000, 6000, 8000),
         fit_pars = c("beta", "gamma", "sigma", "tau")
         )
       )