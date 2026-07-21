\name{plot.mritc}
\alias{plot.mritc}
\title{Plot Method for Class "mritc"}
\description{
  Visualize MRI tissue classification results. 
}
\usage{
   \method{plot}{mritc}(x, method=c("RNifti","misc3d"), ...)
}
\arguments{
   \item{x}{an object of class "mritc"}
   \item{method}{the visualisation backend to use. The default,
     \code{"RNifti"}, uses \code{\link[RNifti]{view}}; the alternative,
     \code{"misc3d"}, uses the three-plane Tk-based viewer
     \code{\link[misc3d]{slices3d}}, which requires the \pkg{tkrplot}
     \pkg{tcltk} packages to be installed and useable.}
   \item{...}{any additional arguments for the relevant viewer.}
}
\details{
  Allocate a voxel to the tissue type with the highest probability and
  then visualise the result.
}
\note{
  Prior to version 0.6.0, \code{"misc3d"} was the only viewer supported,
  but owing to its system requirements \code{"RNifti"} was added as a
  new default for better portability.
}
 \value{
   \code{NULL}, invisibly
}
\seealso{
  \code{\link[RNifti]{view}}, \code{\link[misc3d]{slices3d}}
}
\examples{
  T1 <- readMRI(system.file("extdata/t1.rawb.gz", package="mritc"),
                c(91,109,91), format="rawb.gz")
  mask <-readMRI(system.file("extdata/mask.rawb.gz", package="mritc"),
                 c(91,109,91), format="rawb.gz")
  tc.icm <- mritc(T1, mask, method="ICM")
  plot(tc.icm)
}
\keyword{methods}



