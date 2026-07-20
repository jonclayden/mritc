# rnormmix() draws samples from a normal mixture, returning a two-column
# matrix of (value, component-label) pairs.

set.seed(1)
n <- 5000
prop <- c(0.2, 0.3, 0.5)
mu <- c(-10, 0, 10)
sigma <- c(1, 1, 1)
out <- rnormmix(n, prop, mu, sigma)

expect_equal(dim(out), c(n, 2))
expect_equal(colnames(out), c("y", "c"))
expect_true(all(out[,"c"] %in% 1:3))

# empirical proportions and per-component means/sds should be close to the
# generating parameters
tab <- table(out[,"c"]) / n
expect_equal(as.numeric(tab), prop, tolerance=0.05)
for (i in 1:3) {
    vals <- out[out[,"c"]==i, "y"]
    expect_equal(mean(vals), mu[i], tolerance=0.5)
    expect_equal(sd(vals), sigma[i], tolerance=0.2)
}

# input validation: mismatched lengths
expect_error(rnormmix(10, prop=c(0.5,0.5), mu=c(1,2,3), sigma=c(1,1,1)))
expect_error(rnormmix(10, prop=c(0.5,0.5), mu=c(1,2), sigma=c(1,1,1)))

# prop must be valid
expect_error(rnormmix(10, prop=c(0.5,0.6), mu=c(1,2), sigma=c(1,1)))
expect_error(rnormmix(10, prop=c(0,1), mu=c(1,2), sigma=c(1,1)))

# sigma must be positive
expect_error(rnormmix(10, prop=c(0.5,0.5), mu=c(1,2), sigma=c(1,-1)))
