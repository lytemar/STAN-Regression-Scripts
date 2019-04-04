// gp_regr_exp_quad_ard_zero_mean_w_pred.stan
// Fit an automatic relevance determination Gaussian process model using a squared exponential kernel with zero mean,
// and compute posterior predictive distribution of new inputs X2 
// Adapted from https://github.com/stan-dev/example-models/blob/master/misc/gaussian-process/gp-fit-ARD.stan

functions{
    matrix L_cov_exp_quad_ARD(vector[] x, real alpha, vector rho, real delta) {
        int N = size(x);
        matrix[N, N] K;
        real sq_alpha = square(alpha);
        for (i in 1:(N-1)) {
            K[i, i] = sq_alpha + delta;
                for (j in (i + 1):N) {
                    K[i, j] = sq_alpha * exp(-0.5*dot_self((x[i]-x[j])./rho));
                    K[j, i] = K[i, j];
                }
            }
        K[N, N] = sq_alpha + delta;
        return cholesky_decompose(K);
    }
}
data {
	int<lower=1> N1;    // Number of data points in the model fitting data matrix
	int<lower=1> P;     // Number of features (dimensions) in the model matrix     
	vector[P] X1[N1];   // Model fitting data predictors
	vector[N1] y;       // Model fitting data outcomes
	int<lower=1> N2;    // Number of data points in the prediction data matrix
	vector[P] X2[N2];   // Prediction data predictors
}
transformed data {
	real delta = 1e-9;
	int<lower=1> N = N1 + N2;
	vector[P] X[N];
	for (n1 in 1:N1) X[n1] = X1[n1];
	for (n2 in 1:N2) X[N1 + n2] = X2[n2];
}
parameters {
    vector<lower=0>[P] rho;
    real<lower=0> alpha;
    real<lower=0> sigma;
    vector[N] eta;
}
transformed parameters{
    vector[N] f;
	{
		matrix[N, N] L_K = L_cov_exp_quad_ARD(X, alpha, rho, delta);
		f = L_K * eta;
	}
}
model {
	rho ~ inv_gamma(5, 5);
	alpha ~ std_normal();
	sigma ~ std_normal();
	eta ~ std_normal();
	y ~ normal(f[1:N1], sigma);
}
generated quantities {
    vector[N1] log_lik;     // log likelihood
    vector[N1] y_rep;       // outcome replications to assess goodness of model
    vector[N2] y2;          // Predicted outcomes
    for (n1 in 1:N1) {
        log_lik[n1] = normal_lpdf(y[n1] | f[n1], sigma);
        y_rep[n1] = normal_rng(f[n1], sigma);
    }
    for (n2 in 1:N2) {
        y2[n2] = normal_rng(f[N1 + n2], sigma);
    }
}
