# getBlocksMRI(), getNeighborsMRI(), getWeightsMRI() and makeMRIspatial()
# build the spatial (neighbour / checkerboard-block) structures used by the
# Markov random field based classification methods. None of these are
# exported, so they are addressed via ':::'.

mask <- array(0, dim=c(6,6,6))
mask[2:5,2:5,2:5] <- 1
nvox <- sum(mask)

# --- getBlocksMRI -----------------------------------------------------

# a 2-colour checkerboard partitions every masked voxel exactly once
blocks2 <- mritc:::getBlocksMRI(mask, 2)
expect_equal(length(blocks2), 2)
expect_equal(sum(sapply(blocks2, length)), nvox)
expect_equal(sort(unlist(blocks2)), 1:nvox)

# an 8-colour partition does likewise
blocks8 <- mritc:::getBlocksMRI(mask, 8)
expect_equal(length(blocks8), 8)
expect_equal(sum(sapply(blocks8, length)), nvox)
expect_equal(sort(unlist(blocks8)), 1:nvox)

# input validation
expect_error(mritc:::getBlocksMRI(mask, 3))
expect_error(mritc:::getBlocksMRI(array(0, dim=c(6,6,6)), 2))
expect_error(mritc:::getBlocksMRI(array(2, dim=c(6,6,6)), 2))
expect_error(mritc:::getBlocksMRI(matrix(1, 6, 6), 2))

# --- getNeighborsMRI ----------------------------------------------------

nb6 <- mritc:::getNeighborsMRI(mask, 6)
expect_equal(dim(nb6), c(nvox, 6))
# entries are either a valid (1-based) voxel index or nvox+1 (the
# off-mask/"virtual" sentinel index)
expect_true(all(nb6 >= 1 & nb6 <= nvox + 1))

nb18 <- mritc:::getNeighborsMRI(mask, 18)
expect_equal(dim(nb18), c(nvox, 18))

nb26 <- mritc:::getNeighborsMRI(mask, 26)
expect_equal(dim(nb26), c(nvox, 26))

expect_error(mritc:::getNeighborsMRI(mask, 10))

# a voxel in the interior of the masked block (not touching its edge) has
# no off-mask neighbors in the 6-neighbor scheme
ind <- which(mask == 1, arr.ind=TRUE)
idx <- which(ind[,1]==3 & ind[,2]==3 & ind[,3]==3)
expect_equal(length(idx), 1)
expect_true(all(nb6[idx,] <= nvox))

# --- getWeightsMRI --------------------------------------------------------

w <- mritc:::getWeightsMRI(26, sigma=1)
expect_equal(length(w), 26)
expect_equal(sum(w), 1)
expect_true(all(w > 0))
# under an isotropic Gaussian kernel, the 6 face-touching (unit-distance)
# neighbors get equal, and the largest, weight; the 8 corner (sqrt(3))
# neighbors get the smallest
expect_equal(sum(w == max(w)), 6)
expect_equal(sum(w == min(w)), 8)

expect_error(mritc:::getWeightsMRI(6, sigma=1))
expect_error(mritc:::getWeightsMRI(18, sigma=1))

# --- makeMRIspatial -------------------------------------------------------

sp <- makeMRIspatial(mask, nnei=6, sub=FALSE)
expect_equal(dim(sp$neighbors), c(nvox, 6))
expect_equal(length(sp$blocks), 2)
expect_false(sp$sub)
expect_null(sp$subvox)
expect_null(sp$weights)

sp8 <- makeMRIspatial(mask, nnei=26, sub=FALSE)
expect_equal(length(sp8$blocks), 8)

# sub=TRUE splits every voxel into 8 sub-voxels
spsub <- makeMRIspatial(mask, nnei=6, sub=TRUE)
expect_equal(dim(spsub$neighbors), c(nvox*8, 6))
expect_equal(dim(spsub$subvox), c(nvox, 8))
expect_true(spsub$sub)

# bias=TRUE additionally returns per-neighbor weights
spbias <- makeMRIspatial(mask, nnei=26, sub=FALSE, bias=TRUE)
expect_equal(length(spbias$weights), 26)
expect_equal(length(spbias$weineighbors), nvox)

expect_error(makeMRIspatial(mask, nnei=10))
