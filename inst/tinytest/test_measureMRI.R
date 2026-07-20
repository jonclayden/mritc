# measureMRI() compares a predicted fuzzy-membership matrix against a
# ground-truth one, returning several agreement measures.

actual <- matrix(c(1,0,0,
                    1,0,0,
                    0,1,0,
                    0,0,1), ncol=3, byrow=TRUE)

# a perfect prediction
perfect <- actual
res <- measureMRI(actual=actual, pre=perfect)
expect_equal(res$mse, 0)
expect_equal(res$misclass, 0)
expect_equal(res$rseVolume, c(0,0,0))
expect_equal(res$DSM, c(1,1,1))
expect_equal(res$conTable, diag(3))

# a prediction that is confident but wrong for one voxel (row 3: true
# class 2, predicted class 3)
pre <- matrix(c(1,0,0,
                 1,0,0,
                 0,0,1,
                 0,0,1), ncol=3, byrow=TRUE)
res2 <- measureMRI(actual=actual, pre=pre)
expect_equal(res2$misclass, 1/4)
expect_true(res2$mse > 0)
# class 2 (row 3 in 'actual') was never predicted, so its Dice similarity
# is 0
expect_equal(res2$DSM[2], 0)

# dimension mismatch is rejected
expect_error(measureMRI(actual=actual, pre=pre[1:3,]))

# intvec, when given, must be a plain vector matching the number of voxels
expect_error(measureMRI(intvec=matrix(1:8, 2), actual=actual, pre=pre))
expect_error(measureMRI(intvec=1:3, actual=actual, pre=pre))

# getConTable()/getDSM() are the (unexported) internal helpers behind
# measureMRI(), operating directly on discrete class labels
ct <- mritc:::getConTable(c(1,1,2,3), c(1,1,3,3))
expect_equal(dim(ct), c(3,3))
expect_equal(sum(ct), 3)  # one column per predicted class, each summing to 1
dsm <- mritc:::getDSM(c(1,1,2,3), c(1,1,3,3))
expect_equal(dsm[2], 0)   # class 2 never predicted
expect_equal(dsm[1], 1)   # class 1 perfectly predicted

expect_error(mritc:::getConTable(c(1,2), c(1,2,3)))
expect_error(mritc:::getConTable(c(1,2,3), c(1,2,4)))
