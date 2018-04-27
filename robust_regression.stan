// robust_regression.stan

data {
  int N; // the number of observations
  int P; // the number of columns in the model matrix
  real y[N]; // the response
  matrix[N,P] X; // the model matrix
  real beta_loc; // the location of the beta priors
  real<lower=0> beta_scale; // the scale of the beta priors
  real<lower=0> sigma_loc; // the location of the sigma prior
  real<lower=0> sigma_scale; // the scale of the sigma prior
  real expLambda; // The parameter for nu's exponential prior
}
parameters {
  vector[P] beta; // the regression parameters
  real<lower=0> sigma; // the standard deviation
  real<lower=0> nuMinusOne; // Student-t degrees of freedom minus 1
}
transformed parameters {
  real<lower=0> nu; // actually lower=1, Student-t degrees of freedom
  nu = nuMinusOne + 1;
}
model {
  beta ~ cauchy(beta_loc, beta_scale); // prior for the intercept and slopes
  sigma ~ cauchy(sigma_loc, sigma_scale); // prior for sigma
  nuMinusOne ~ exponential(expLambda); // prior for nu
  y ~ student_t(nu, X*beta, sigma); // vectorized likelihood
}
generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {
    log_lik[n] = student_t_lpdf(y[n] | nu, X[n]*beta, sigma);
    y_rep[n] = student_t_rng(nu, X[n]*beta, sigma);
  }
}
