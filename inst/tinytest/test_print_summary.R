# print.mritc() and summary.mritc() report per-tissue-class proportions
# (and, for summary, fitted means/SDs) derived from a fitted "mritc"
# object's fuzzy membership matrix. summary.mritc() invisibly returns the
# table it prints, which is used below to check values without having to
# parse formatted text.

set.seed(61)
n <- 20
prob3 <- matrix(0, n, 3)
cls3 <- c(rep(1,2), rep(2,12), rep(3,6))  # 10%, 60%, 30%
for (i in 1:n) {
    p <- runif(3, 0.01, 0.05)
    p[cls3[i]] <- 0.6
    prob3[i,] <- p / sum(p)
}
stopifnot(all(max.col(prob3) == cls3))

r3 <- list(prob=prob3, mu=c(10,20,30), sigma=c(1,1,1), method="EM")
class(r3) <- "mritc"

pout <- capture.output(print(r3))
expect_true(any(grepl("^10% are classified to CSF,$", pout)))
expect_true(any(grepl("^60% are classified to GM,$", pout)))
expect_true(any(grepl("^30% are classified to WM\\.$", pout)))

s3 <- capture.output(out3 <- summary(r3))
expect_equal(unname(out3[,"proportion%"]), c(10, 60, 30))
expect_equal(unname(out3[,"mean"]), c(10, 20, 30))
expect_equal(unname(out3[,"standard deviation"]), c(1, 1, 1))
expect_equal(rownames(out3), c("CSF","GM","WM"))

# k=5 (a PVHMRFEM-style result): summary.mritc() re-orders the 5 raw
# probability columns (CSF, CSF-GM, GM, GM-WM, WM) into
# (CSF, GM, WM, CSF-GM, GM-WM) to align proportions against the
# length-3 mu/sigma of the 3 "pure" classes; check this reordering
# against print.mritc()'s un-reordered proportions, which are taken
# directly from the raw column order.
prob5 <- matrix(0, n, 5)
cls5 <- c(rep(1,2), rep(2,3), rep(3,8), rep(4,4), rep(5,3))  # 10,15,40,20,15
for (i in 1:n) {
    p <- runif(5, 0.01, 0.05)
    p[cls5[i]] <- 0.6
    prob5[i,] <- p / sum(p)
}
stopifnot(all(max.col(prob5) == cls5))

r5 <- list(prob=prob5, mu=c(10,20,30), sigma=c(1,1,1), method="PVHMRFEM")
class(r5) <- "mritc"

pout5 <- capture.output(print(r5))
expect_true(any(grepl("^10% are classified to CSF,$", pout5)))
expect_true(any(grepl("^15% are classified to CG,$", pout5)))
expect_true(any(grepl("^40% are classified to GM,$", pout5)))
expect_true(any(grepl("^20% are classified to GW,$", pout5)))
expect_true(any(grepl("^15% are classified to WM\\.$", pout5)))

s5 <- capture.output(out5 <- summary(r5))
expect_equal(rownames(out5), c("CSF","GM","WM","CG","GW"))
expect_equal(unname(out5[,"proportion%"]), c(10, 40, 15, 15, 20))
expect_equal(unname(out5[,"mean"]), c(10, 20, 30, NA, NA))

# --- max.col() tie-breaking determinism ----------------------------------
# Regression test: print.mritc()/summary.mritc()/plot.mritc()/measureMRI()
# discretise the fuzzy membership matrix with max.col(), which by default
# breaks ties at random. Whenever two classes are exactly tied for a
# voxel, the reported proportions used to change from call to call
# depending on the RNG state.
tied <- matrix(c(0.5,0.5,0,
                  0.9,0.05,0.05,
                  0.05,0.9,0.05,
                  0.05,0.05,0.9), ncol=3, byrow=TRUE)
rtie <- list(prob=tied, mu=c(1,2,3), sigma=c(1,1,1), method="EM")
class(rtie) <- "mritc"

set.seed(1); out.a <- capture.output(print(rtie))
set.seed(4); out.b <- capture.output(print(rtie))
expect_identical(out.a, out.b)

set.seed(1); capture.output(sum.a <- summary(rtie))
set.seed(4); capture.output(sum.b <- summary(rtie))
expect_identical(sum.a, sum.b)
