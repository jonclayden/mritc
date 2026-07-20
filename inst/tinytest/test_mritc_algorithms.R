# mritc.em() (and its internal workhorse emnormmix()) fit a normal mixture
# model to a vector of voxel intensities via the EM algorithm, with no
# spatial (Markov random field) component.

set.seed(21)
y <- c(rnorm(300, 10, 1), rnorm(300, 20, 1), rnorm(300, 30, 1))
init <- initOtsu(y, 2)

r <- mritc.em(y, init$prop, init$mu, init$sigma, verbose=FALSE)
expect_equal(dim(r$prob), c(length(y), 3))
expect_equal(rowSums(r$prob), rep(1, length(y)), tolerance=1e-6)
expect_true(all(r$prob >= 0 & r$prob <= 1))
expect_equal(sort(r$mu), c(10, 20, 30), tolerance=0.5)
expect_true(all(r$sigma > 0))

# each voxel's most probable class agrees with the mixture component it was
# actually generated from, for this well-separated case
truth <- rep(1:3, each=300)
classified <- max.col(r$prob)
# allow the label permutation to differ, but classes should still align
tab <- table(truth, classified)
expect_equal(sum(apply(tab, 1, max)) / length(y), 1, tolerance=0.01)

# input validation is delegated to checkErrors()
expect_error(mritc.em(y, prop=c(0.5,0.5), mu=c(1,2,3), sigma=c(1,1,1), verbose=FALSE))
expect_error(mritc.em(y, prop=init$prop, mu=init$mu, sigma=c(-1,1,1), verbose=FALSE))

# emnormmix() is the internal engine used by mritc.em(); mritc.em() adds
# the per-voxel 'prob' matrix on top of the same (prop, mu, sigma) fit
em <- mritc:::emnormmix(y, init$prop, init$mu, init$sigma, err=1e-4, maxit=200, verbose=FALSE)
expect_equal(em$mu, r$mu)
expect_equal(em$sigma, r$sigma)

# --- mritc.icm / mritc.hmrfem / mritc.pvhmrfem --------------------------
# These add a spatial (Potts model) smoothing term, so need a mask and a
# neighbour structure.

set.seed(22)
mask <- array(0, dim=c(8,8,8))
mask[2:7,2:7,2:7] <- 1
intarr <- array(rnorm(8^3, 100, 10), dim=c(8,8,8))
intarr[mask==1] <- intarr[mask==1] + rep(c(0,20,40), length.out=sum(mask==1))
yv <- intarr[mask==1]
initv <- initOtsu(yv, 2)
sp <- makeMRIspatial(mask, nnei=6, sub=FALSE)

ricm <- mritc.icm(yv, sp$neighbors, sp$blocks, mu=initv$mu, sigma=initv$sigma, verbose=FALSE)
expect_equal(dim(ricm$prob), c(length(yv), 3))
expect_equal(rowSums(ricm$prob), rep(1, length(yv)), tolerance=1e-6)
expect_equal(sort(ricm$mu), sort(initv$mu), tolerance=5)

rhmrf <- mritc.hmrfem(yv, sp$neighbors, sp$blocks, mu=initv$mu, sigma=initv$sigma, verbose=FALSE)
expect_equal(dim(rhmrf$prob), c(length(yv), 3))
expect_equal(rowSums(rhmrf$prob), rep(1, length(yv)), tolerance=1e-6)

rpv <- mritc.pvhmrfem(yv, sp$neighbors, sp$blocks, mu=initv$mu, sigma=initv$sigma, verbose=FALSE)
# PVHMRFEM models 3 pure classes plus 2 intermediate partial-volume
# classes; i.e., prob has 5 columns
expect_equal(dim(rpv$prob), c(length(yv), 5))
expect_equal(rowSums(rpv$prob), rep(1, length(yv)), tolerance=1e-6)
expect_equal(length(rpv$mu), 3)

# mritc.icm/mritc.hmrfem validate mu/sigma via checkErrors()
expect_error(mritc.icm(yv, sp$neighbors, sp$blocks, mu=c(1,2,3), sigma=c(1,-1,1), verbose=FALSE))
expect_error(mritc.hmrfem(yv, sp$neighbors, sp$blocks, mu=c(1,2,3), sigma=c(1,-1,1), verbose=FALSE))

# mritc.pvhmrfem must likewise reject a non-positive sigma rather than
# silently proceeding into undefined behaviour (regression test: this
# used to skip validation entirely and could crash R on bad input)
expect_error(mritc.pvhmrfem(yv, sp$neighbors, sp$blocks, mu=c(1,2,3), sigma=c(1,-1,1), verbose=FALSE))
expect_error(mritc.pvhmrfem(yv, sp$neighbors, sp$blocks, mu=c(1,2,3), sigma=c(1,0,1), verbose=FALSE))
