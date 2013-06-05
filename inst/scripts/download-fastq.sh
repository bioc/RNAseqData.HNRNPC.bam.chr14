#!/bin/bash

set -e # Exit immediately if a simple command exits with a non-zero status.

SRC_DIR="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR127/"
run_names="ERR127306 ERR127307 ERR127308 ERR127309 ERR127302 ERR127303 ERR127304 ERR127305"

for run_name in $run_names; do
    url1=$SRC_DIR/$run_name/${run_name}_1.fastq.gz
    url2=$SRC_DIR/$run_name/${run_name}_2.fastq.gz
    wget $url1
    wget $url2
done

