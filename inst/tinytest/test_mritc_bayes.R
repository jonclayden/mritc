# mritc.bayes() fits the hierarchical Bayesian hidden Markov normal mixture
# model via MCMC, in three flavours: whole-voxel ("nobias", sub=FALSE),
# higher-resolution sub-voxel (sub=TRUE), and sub-voxel with intensity
# non-uniformity ("bias") correction. Small niter/mask keep these fast.

set.seed(31)
mask <- array(0, dim=c(8,8,8))
mask[2:7,2:7,2:7] <- 1
intarr <- array(rnorm(8^3, 100, 10), dim=c(8,8,8))
intarr[mask==1] <- intarr[mask==1] + rep(c(0,20,40), length.out=sum(mask==1))
y <- intarr[mask==1]
init <- initOtsu(y, 2)

# whole-voxel (sub=FALSE)

sp <- makeMRIspatial(mask, nnei=6, sub=FALSE)
rb <- mritc.bayes(y, sp$neighbors, sp$blocks, sub=FALSE, subvox=NULL,
                   mu=init$mu, sigma=init$sigma, niter=20, verbose=FALSE)
expect_equal(dim(rb$prob), c(length(y), 3))
expect_equal(rowSums(rb$prob), rep(1, length(y)), tolerance=1e-6)
expect_true(all(rb$prob >= 0 & rb$prob <= 1))
expect_equal(sort(rb$mu), sort(init$mu), tolerance=10)

# higher-resolution sub-voxel (sub=TRUE)

spsub <- makeMRIspatial(mask, nnei=6, sub=TRUE)
rbsub <- mritc.bayes(y, spsub$neighbors, spsub$blocks, sub=TRUE, subvox=spsub$subvox,
                      mu=init$mu, sigma=init$sigma, niter=20, verbose=FALSE)
# the sub-voxel model still reports one fuzzy membership row per original
# (whole) voxel
expect_equal(dim(rbsub$prob), c(length(y), 3))
expect_equal(rowSums(rbsub$prob), rep(1, length(y)), tolerance=1e-6)

# sub-voxel with bias-field correction

sp26 <- makeMRIspatial(mask, nnei=26, sub=TRUE, bias=TRUE)
rbbias <- mritc.bayes(y, spsub$neighbors, spsub$blocks, sub=TRUE, subvox=spsub$subvox,
                       subbias=TRUE, neighbors.bias=sp26$neighbors, blocks.bias=sp26$blocks,
                       weineighbors.bias=sp26$weineighbors, weights.bias=sp26$weights,
                       mu=init$mu, sigma=init$sigma, niter=5, verbose=FALSE)
expect_equal(dim(rbbias$prob), c(length(y), 3))
expect_equal(rowSums(rbbias$prob), rep(1, length(y)), tolerance=1e-6)

# subbias=TRUE requires the higher-resolution (sub=TRUE) model: the two
# features address partial-volume and bias-field effects simultaneously
# and cannot be decoupled (see mritc.bayes.R)
expect_error(mritc.bayes(y, sp$neighbors, sp$blocks, sub=FALSE, subvox=NULL,
                          subbias=TRUE, neighbors.bias=sp26$neighbors, blocks.bias=sp26$blocks,
                          weineighbors.bias=sp26$weineighbors, weights.bias=sp26$weights,
                          mu=init$mu, sigma=init$sigma, niter=5, verbose=FALSE))

# mu/sigma are validated via checkErrors()
expect_error(mritc.bayes(y, sp$neighbors, sp$blocks, sub=FALSE, subvox=NULL,
                          mu=c(1,2,3), sigma=c(1,-1,1), niter=5, verbose=FALSE))
