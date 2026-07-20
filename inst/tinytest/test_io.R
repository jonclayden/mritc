# readMRI()/writeMRI() read and write MR images in "rawb.gz" (raw bytes,
# gzip-compressed), "analyze" and "nifti" formats.

set.seed(51)
arr <- array(sample(0:255, 4*4*4, replace=TRUE), dim=c(4,4,4))

# rawb.gz round trip
tmp <- tempfile(fileext=".rawb.gz")
writeMRI(arr, tmp, format="rawb.gz")
arr2 <- readMRI(tmp, dim=c(4,4,4), format="rawb.gz")
expect_equal(as.vector(arr2), as.vector(arr))
expect_equal(dim(arr2), c(4,4,4))
unlink(tmp)

# readMRI validates its 'dim' argument for rawb.gz
tmp2 <- tempfile(fileext=".rawb.gz")
writeMRI(arr, tmp2, format="rawb.gz")
expect_error(readMRI(tmp2, dim=c(4,4), format="rawb.gz"))
unlink(tmp2)

# unsupported format
expect_error(readMRI(tmp2, dim=c(4,4,4), format="bogus"))
expect_error(writeMRI(arr, tempfile(), format="bogus"))

# writeMRI validates the shape/class of 'data'
expect_error(writeMRI(array(1, dim=c(4,4)), tempfile(fileext=".rawb.gz"), format="rawb.gz"))
expect_error(writeMRI(1:10, tempfile(fileext=".rawb.gz"), format="rawb.gz"))

# a 4-D array whose 4th dimension is 1 is also accepted
arr4d <- array(arr, dim=c(4,4,4,1))
tmp3 <- tempfile(fileext=".rawb.gz")
expect_silent(writeMRI(arr4d, tmp3, format="rawb.gz"))
arr4d.back <- readMRI(tmp3, dim=c(4,4,4), format="rawb.gz")
expect_equal(as.vector(arr4d.back), as.vector(arr))
unlink(tmp3)

# read the package's bundled example data

maskfile <- system.file("extdata/mask.rawb.gz", package="mritc")
mask <- readMRI(maskfile, dim=c(91,109,91), format="rawb.gz")
expect_equal(dim(mask), c(91,109,91))
expect_true(all(mask %in% c(0,1)))
expect_true(sum(mask) > 0)
