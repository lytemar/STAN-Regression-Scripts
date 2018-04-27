// hierarchical_normal_regression.stan

data {
  int N; // the number of observations
  int J; // the number of groups
  int P; // the number of columns in the model matrix
  int id[N];  // vector of group indices 
  real y[N]; // the response
  matrix[N,P] X; // the model matrix
}
parameters {
  vector[P] gamma; // population-level regression coefficients
  vector<lower=0>[P] tau; // standard deviation of the regression coefficients
  vector[P] beta_raw[J]; // matrix of standard normals for beta parameterization
  real<lower=0> sigma; // the standard deviation of individual observations
}
transformed parameters {
  vector[P] beta[J]; // matrix of group-level regression coefficients
  // compute the group-level coefficient, based on non-centered parameterization
  // based on section 28.6 of the Stan manual (v2.17.0)
  for(j in 1:J) {
    beta[j] = gamma + tau .* beta_raw[j];
  }
}
model {
  vector[N] mu; // linear predictor
  // priors
  gamma ~ normal(0, 5); // weakly informative priors on regression coefficients
  tau ~ cauchy(0, 2.5); // weakly informative priors, sec 9.13 in Stan manual
  sigma ~ gamma(2, 0.1); // weakly informative prior, sec 9.13 in Stan manual
  // fill the matrix of group-level regression coefficients
  for(j in 1:J) {
    beta_raw[j] ~ normal(0, 1);
  }
  // compute the linear predictor using relevant group-level
  // regression coefficients
  for(n in 1:N) {
    mu[n] = X[n] * beta[id[n]]; 
  }
  y ~ normal(mu, sigma); // vectorized likelihood
}
generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | X[n] * beta[id[n]], sigma);
    y_rep[n] = normal_rng(X[n] * beta[id[n]], sigma);
  }
}
