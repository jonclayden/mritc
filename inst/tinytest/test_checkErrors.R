# checkErrors() is an internal helper used throughout the package to
# validate mixture-model parameters (prop, mu, sigma) and convergence
# tolerances (err) before an algorithm starts iterating.

# valid input: no error
expect_silent(mritc:::checkErrors(prop=c(0.3,0.3,0.4), mu=c(1,2,3), sigma=c(1,1,1), err=1e-4))
expect_silent(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,1,1), err=1e-4))
expect_silent(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,1,1)))

# prop must lie strictly between 0 and 1
expect_error(mritc:::checkErrors(prop=c(0, 0.5, 0.5), mu=c(1,2,3), sigma=c(1,1,1)))
expect_error(mritc:::checkErrors(prop=c(1, 0, 0), mu=c(1,2,3), sigma=c(1,1,1)))

# prop must sum to 1
expect_error(mritc:::checkErrors(prop=c(0.2, 0.2, 0.2), mu=c(1,2,3), sigma=c(1,1,1)))

# prop, mu and sigma must all have matching lengths
expect_error(mritc:::checkErrors(prop=c(0.5,0.5), mu=c(1,2,3), sigma=c(1,1,1)))
expect_error(mritc:::checkErrors(prop=c(0.5,0.5), mu=c(1,2), sigma=c(1,1,1)))

# mu and sigma must have matching lengths when prop is not supplied
expect_error(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,1)))

# sigma must be strictly positive, with or without prop
expect_error(mritc:::checkErrors(prop=c(0.3,0.3,0.4), mu=c(1,2,3), sigma=c(1,-1,1)))
expect_error(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,0,1)))

# err (when supplied) must be non-negative
expect_error(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,1,1), err=c(1e-4,-1)))
expect_silent(mritc:::checkErrors(mu=c(1,2,3), sigma=c(1,1,1), err=c(1e-4,0)))
