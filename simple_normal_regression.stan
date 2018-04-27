// simple_normal_regression.stan

data {
  int N; // the number of observations
  int P; // the number of columns in the model matrix
  real y[N]; // the response
  matrix[N,P] X; // the model matrix
  real beta_loc; // the location of the beta priors
  real<lower=0> beta_scale; // the scale of the beta priors
  real<lower=0> sigma_loc; // the location of the sigma prior
  real<lower=0> sigma_scale; // the scale of the sigma prior
}
parameters {
  vector[P] beta; // the regression parameters
  real<lower=0> sigma; // the standard deviation
}
model {
  beta ~ cauchy(beta_loc, beta_scale); // prior for regression coefficients
  sigma ~ cauchy(sigma_loc, sigma_scale); // prior for sigma
  y ~ normal(X*beta, sigma); // vectorized likelihood
}
generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {
    log_lik[n] = normal_lpdf(y[n] | X[n]*beta, sigma);
    y_rep[n] = normal_rng(X[n]*beta, sigma);
  }
}
