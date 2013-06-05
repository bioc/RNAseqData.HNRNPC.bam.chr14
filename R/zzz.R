###

RNAseqData.HNRNPC.bam.chr14_RUNNAMES <- paste0("ERR12730", c(6:9, 2:5))

RNAseqData.HNRNPC.bam.chr14_BAMFILES <- NULL

.onLoad <- function(libname, pkgname)
{
    tmp <- sapply(RNAseqData.HNRNPC.bam.chr14_RUNNAMES,
                  function(runname)
                      system.file("extdata", paste0(runname, "_chr14.bam"),
                                  package=pkgname, lib.loc=libname))
    names(tmp) <- RNAseqData.HNRNPC.bam.chr14_RUNNAMES
    RNAseqData.HNRNPC.bam.chr14_BAMFILES <<- tmp
}

