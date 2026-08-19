# mritc 0.6.2

* An uninitialised memory bug picked up by `valgrind` has been corrected.

# mritc 0.6.1

* A buffer overflow and an OpenMP-related name clash detected by CRAN checks
  have both been resolved.

# mritc 0.6.0

* Package dependencies have been simplified. The `lattice` and `misc3d`
  packages have become optional (`Suggests`) dependencies rather than required
  ones, and `tkrplot` is not directly connected at all. Visualisation can now
  be performed by `RNifti` (an existing dependency through `oro.nifti`), which
  has more easily met system requirements than `misc3d`.
* A suite of tests has been added to the package. `tinytest` and `covr` are
  now suggested dependencies for testing and code-coverage support.
* `plot.mritc()` gains a `method` argument for choosing the visualisation
  backend: the new default, `"RNifti"`, uses `RNifti::view()` and requires
  only packages already needed elsewhere by `mritc`; the previous behaviour is
  still available via `method="misc3d"`, which uses the Tk-based
  `misc3d::slices3d()` viewer and requires the `misc3d` and `tkrplot` packages
  to be installed.
* Added a `verbose` argument to `mritc()`, passed through to the underlying
  fitting methods, to allow progress messages to be suppressed.
* Fixed a bug where `mritc(..., method="MCMCsubbias")` used the wrong
  spatial neighbourhood construction (`sub=FALSE` instead of `sub=TRUE`),
  affecting results for that method.
* Fixed a bug in `mritc.pvhmrfem()` where argument checks on `mu`, `sigma`
  and `err` were not actually performed, which could lead to a downstream
  segfault for invalid inputs.
* Fixed a bug in `writeMRI()` involving incorrect vectorised use of
  `ifelse()`, which could fail for some input object types.
* Class labels are now assigned deterministically when tied
  (`print.mritc()`, `summary.mritc()`, `plot.mritc()` and `measureMRI()` all
  used `max.col()` without breaking ties consistently, which could change
  reported results from run to run).
* The package citation style has been updated to match current requirements.

# mritc 0.5-3

* Jon Clayden took over as maintainer.
* Newly allocated variables are now protected in the C code, to prevent
  potential problems arising from garbage collection.
* Documentation URLs were updated to HTTPS.
* The `LazyData` field was dropped from the package `DESCRIPTION`.
* Long-running examples now use `\donttest`, as requested by CRAN.

# mritc 0.5-2

* Maintainer contact details updated (metadata-only release).

# mritc 0.5-1

* Fixed missing S3 method registrations and namespace imports.

# mritc 0.5-0

* Added support for bias field correction, via a new `"MCMCsubbias"` method
  for `mritc()` and a new `getWeightsMRI()` function.
* Image file input and output (`readMRI()`/`writeMRI()`) now uses the
  `oro.nifti` package, rather than the previously used `AnalyzeFMRI` and
  `fmri` packages.

# mritc 0.4-0

* The core computations were parallelised using OpenMP, for improved
  performance.

# mritc 0.3-5

* `tkrplot` added as a suggested package dependency, required for the
  interactive 3D viewer used by `plot.mritc()` (thanks to Brian Ripley for
  reporting the missing dependency).
* Documented that the package supports normal mixture models with up to
  eight components (thanks to Matthew Moores).
* Updated the documentation for the `plot.mritc()`, `print.mritc()` and
  `summary.mritc()` methods to use standard `\method{}{}` markup (thanks to
  Achim Zeileis).

# mritc 0.3-4

* Added a citation for the associated *Journal of Statistical Software*
  paper.

# mritc 0.3-3

* `measureMRI()` now uses discrete (rather than fuzzy) classifications to
  calculate tissue volumes, simplifying the calculation of `rseVolume`.
* Changed the x-axis label of the density plot produced by `measureMRI()`.

# mritc 0.3-2

* Fixed a bug in `checkErrors()` affecting the comparison `sum(prop)==1`.
* Added new `initProp()` and `initThresh()` initialisation functions, alongside
  `initOtsu()`.
* Increased the minimum required version of `misc3d` to 0.7-1, which fixed
  a crosshair display bug (thanks to Brandon Whitcher for testing and
  reporting the problem).

# mritc 0.3-1

* Initial CRAN release.
