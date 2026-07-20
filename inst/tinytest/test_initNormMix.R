# initOtsu() and initProp() provide initial (prop, mu, sigma) estimates for
# a normal mixture model, via Otsu multi-level thresholding or via
# user-specified proportions respectively.

set.seed(100)
y <- c(rnorm(200, 10, 1), rnorm(200, 20, 1), rnorm(200, 30, 1))

# initOtsu recovers three well-separated clusters
init <- initOtsu(y, 2)
expect_equal(length(init$prop), 3)
expect_equal(length(init$mu), 3)
expect_equal(length(init$sigma), 3)
expect_equal(sum(init$prop), 1)
expect_true(all(init$sigma > 0))
expect_equal(sort(init$mu), c(10, 20, 30), tolerance=1)

# initProp with balanced proportions on the same data recovers similar
# thresholds/means to initOtsu
initp <- initProp(y, c(1/3, 1/3, 1/3))
expect_equal(initp$mu, init$mu, tolerance=1e-6)
expect_equal(initp$prop, init$prop, tolerance=1e-6)

# initProp with unbalanced proportions still returns a valid partition
initp2 <- initProp(y, c(0.1, 0.8, 0.1))
expect_equal(sum(initp2$prop), 1)
expect_equal(length(initp2$mu), 3)

# a single, very skewed threshold in initProp is reflected in the recovered
# proportions
expect_equal(initp2$prop, c(0.1, 0.8, 0.1), tolerance=1e-6)

# m must leave at least one observation per implied class: with only one
# unique value in y, no threshold can be found
expect_error(initOtsu(rep(1, 10), 2))

# only the first element of 'm' is used, with a warning, if length(m) > 1
expect_warning(init3 <- initOtsu(y, c(2, 3)))
expect_equal(init3, initOtsu(y, 2))

# initProp delegates proportion validation to checkErrors()
expect_error(initProp(y, c(0.5, 0.5, 0.5)))
expect_error(initProp(y, c(0, 0.5, 0.5)))

# otsu(): internal multi-level threshold search. Two well-separated,
# equal-sized clusters should yield a single threshold that falls strictly
# between them, and classifies every point correctly.
yy <- c(rep(0, 50), rep(100, 50))
th <- mritc:::otsu(yy, 1)
expect_true(th >= 0 && th < 100)
expect_equal(sum(yy > th), 50)

# initThresh(): recovers per-class prop/mu/sigma from known threshold(s)
res <- mritc:::initThresh(yy, 50)
expect_equal(res$prop, c(0.5, 0.5))
expect_equal(res$mu, c(0, 100))
expect_equal(res$sigma, c(0, 0))
