plot.mritc <- function(x, method=c("RNifti","misc3d"), ...){
    method <- match.arg(method)
    class <- max.col(x$prob, ties.method="first")
    x$mask[x$mask==1] <- class
    if (method == "misc3d" && requireNamespace("misc3d",quietly=TRUE))
        misc3d::slices3d(x$mask, ...)
    else if (method == "RNifti" && requireNamespace("RNifti",quietly=TRUE))
        RNifti::view(RNifti::lyr(x$mask, min=0, max=max(class)), ...)
    else
        stop("The requested viewer package (", method, ") is not available")
    invisible(NULL)
}
