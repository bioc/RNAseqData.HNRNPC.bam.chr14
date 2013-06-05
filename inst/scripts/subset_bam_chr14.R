### ==========================================================================
### Extract alignments on chr14 from the 8 BAM files produced by TopHat2
### --------------------------------------------------------------------------
###
### Run with:
###   R --vanilla <subset_bam_chr14.R
###

library(Rsamtools)

run_names <- paste0("ERR12730", c(6:9, 2:5))
in_bam_files <- file.path("tophat2_out", run_names, "accepted_hits.bam")
out_bam_files <- file.path("bam_chr14", paste0(run_names, "_chr14.bam"))

chr14_len <- seqlengths(BamFile(in_bam_files[1L]))[["chr14"]]
param <- ScanBamParam(which=GRanges("chr14", IRanges(1, chr14_len)))

for (i in seq_along(run_names)) {
    cat("subsetting", in_bam_files[i], "->", out_bam_files[i], "... ")
    filterBam(in_bam_files[i], out_bam_files[i], param=param)
    cat("OK\n")
}

