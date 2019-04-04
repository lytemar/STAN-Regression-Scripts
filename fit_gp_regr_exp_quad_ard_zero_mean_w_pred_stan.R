# fit_gp_regr_exp_quad_ard_zero_mean_w_pred_stan.R

source("bayesian_functions.R")

fit_gp_regr_exp_quad_ard_zero_mean_w_pred_stan <- function(df_train, df_pred, prefix, rows_to_drop=NULL, 
                                                           order=1, chains=8, iter=500, include_intercept=FALSE, 
                                                           control_lst=list(max_treedepth = 15)){
    
    # Generate the model matrices
    if (rows_to_drop) {
        X1 <- genModelMatrix(df_train[-rows_to_drop,], order=order, include_intercept=include_intercept) # training data
        X2 <- genModelMatrix(df_pred[-rows_to_drop,], order=order, include_intercept=include_intercept) # prediction data
    } else {
        X1 <- genModelMatrix(df_train, order=order, include_intercept=include_intercept) # training data
        X2 <- genModelMatrix(df_pred, order=order, include_intercept=include_intercept) # prediction data
    }
    
    # Fit the Gaussian Process model with predictions
    fit_stan_model_with_y_pred(
        stan_file = 'gp_regr_fit_rbf_zero_mean_w_pred.stan',
        prefix = prefix,
        data = list(N1=nrow(X1),
                    N2=nrow(X2),
                    P=ncol(X1),
                    y=df_train$Y,
                    X1=X1, X2=X2),
        control = control_lst,
        chains = chains,
        iter = iter,
        fit_pars = c("rho", "alpha", "sigma")
        )
}
