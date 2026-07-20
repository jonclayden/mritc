plot.mritc <- function(x, ...){
    class <- max.col(x$prob, ties.method="first")
    x$mask[x$mask==1] <- class
    slices3d(x$mask, ...)
}
