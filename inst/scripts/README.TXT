This README.TXT file is located in the scripts/ folder of the
RNAseqData.HNRNPC.bam.chr14 package. This folder contains the scripts that
were used to generate the data contained in the package (note that all the
data contained in the package is located in its extdata/ folder).

This README.TXT file describes how to use those scripts to re-generate the
content of the extdata/ folder.

0. Requirements
---------------

- Good hardware. Running step "6. Align the reads" below will take a long
  time (between 20h and 3 or 4 days, depending on your hardware). This step
  was run on one of the very crowded rhino servers at the Fred Hutchinson
  Cancer Research Center in May 2013 to generate the data contained in the
  RNAseqData.HNRNPC.bam.chr14 package. Each rhino server is a 64-bit Ubuntu
  system with 16 cores and 384Gb of RAM. Step "6. Align the reads" took about
  3 days to complete. If no other users were competing for resources, it
  would still probably take about the same amount of time on a Linux server
  with only 4 cores and 16Gb of RAM.

- 50Gb of available disk space.

- Fast internet access (there is about 30Gb of data to download). 

- Software: Bowtie2 + TopHat2, SAMtools, and R + Bioconductor (Rsamtools
  package). A brief overview of how to install Bowtie2 + TopHat2 is given
  below.

1. Set SCRIPTS_DIR
------------------

Set the SCRIPTS_DIR shell variable to the *absolute* path of the scripts/
folder of the RNAseqData.HNRNPC.bam.chr14 package. If the package is installed,
you can get that path with:

  pkgname="RNAseqData.HNRNPC.bam.chr14"
  rscript="cat(system.file('scripts', package='$pkgname'))"
  SCRIPTS_DIR=`echo "$rscript" | R --slave`

Make sure SCRIPTS_DIR is set to something:

  echo $SCRIPTS_DIR

Otherwise, download the package source tarball from the Bioconductor package
repository (http://bioconductor.org/packages/release/data/experiment/) and
extract it with 'tar zxf <path/to/tarball>'. This creates the package source
tree in your current directory. Right after extraction is complete (and
*before* you move to another directory with 'cd'), do:

  SCRIPTS_DIR="`pwd`/RNAseqData.HNRNPC.bam.chr14/inst/scripts"

In either case, make sure SCRIPTS_DIR is set correctly by doing:

  cat $SCRIPTS_DIR/README.TXT

It should should display the content of this README.TXT file.

2. Create the "main working directory"
--------------------------------------

For example with:

  mkdir ~/E-MTAB-1147

Also create the 3 following subdirs:

  cd ~/E-MTAB-1147
  mkdir fastq tmp_downloads tophat2_out bam_chr14

3. Download the 16 FASTQ files (2 per sequencing run)
-----------------------------------------------------

This will take a long time: there is about 30Gb of data to download!

  cd ~/E-MTAB-1147/fastq
  $SCRIPTS_DIR/download-fastq.sh

Alternatively, you can do this in R with:

  library(RNAseqData.HNRNPC.bam.chr14)
  setwd("~/E-MTAB-1147/fastq")
  cmd <- system.file("scripts", "download-fastq.sh",
                     package="RNAseqData.HNRNPC.bam.chr14")
  system(cmd)

4. Download and install Bowtie2 + TopHat2
-----------------------------------------

(a) Download the latest pre-compiled binary of Bowtie2 from

      http://sourceforge.net/projects/bowtie-bio/files/bowtie2/

    The version that was used in May 2013 for generating the data in this
    package is the 2.1.0 version for 64-bit Linux (i.e. file
    bowtie2-2.1.0-linux-x86_64.zip) downloaded from:

      http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.1.0/

(b) Download the latest pre-compiled binary of TopHat2 from

      http://tophat.cbcb.umd.edu/tutorial.shtml

    The version that was used in May 2013 for generating the data in this
    package is the 2.0.8b version for 64-bit Linux (i.e. file
    tophat-2.0.8b.Linux_x86_64.tar.gz) downloaded from:

      http://tophat.cbcb.umd.edu/downloads/
 
(c) Extract them in your home. Make sure the executables located in
    ~/bowtie2-2.1.0/ and ~/tophat-2.0.8b.Linux_x86_64/ are in your PATH.
    Create the Bowtie indexes subdirectory with:

      mkdir ~/bowtie2-2.1.0/indexes

5. Create Bowtie2 index for hg19
--------------------------------

This took about 2h on rhino02:

  cd ~/E-MTAB-1147/tmp_downloads
  wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz
  tar zxvf chromFa.tar.gz
  hg19_seqnames=`cat $SCRIPTS_DIR/seqnames.txt`
  reference_in=""
  for seqname in $hg19_seqnames; do
      file=${seqname}.fa
      if [ "$reference_in" == "" ]; then
          reference_in="$file"
      else
          reference_in="$reference_in,$file"
      fi
  done
  bowtie2-build $reference_in hg19

This produces 6 files: hg19.1.bt2, hg19.2.bt2, hg19.3.bt2, hg19.4.bt2,
                       hg19.rev.1.bt2, hg19.rev.2.bt2

Move them to the Bowtie indexes subdirectory with:

  mv -i hg19.*.bt2 ~/bowtie2-2.1.0/indexes

Test that the index is properly installed:

  export BOWTIE2_INDEXES="~/bowtie2-2.1.0/indexes"
  bowtie2 -c hg19 GTTTTAGTAGAGACAAGGTCTCACTGTGCTGCCCTGGTGGGTCTCAAATTCCTGA

6. Align the reads
------------------

There are 8 sequencing runs in this experiment so we're going to fire 1
instance of TopHat2 per run. Each instance of TopHat2 will write its output
to a folder under ~/E-MTAB-1147/tophat2_out
Have a look at the start-tophat2-on-all-runs.sh script and make any necessary
adjustements to it. Then run it with:

  cd ~/E-MTAB-1147
  $SCRIPTS_DIR/start-tophat2-on-all-runs.sh

The script will exit almost instantly after starting the tophat2 commands
in the background. You can log out and come back any time to the server to
check how things are going e.g. with:

  cd ~/E-MTAB-1147
  tail tophat2-*.log

Or with:

  tail -f tophat2-ERR127306.log

to follow the output of 1 TopHat2 instance in real-time.

Depending on your hardware, it should take between 20h and 3 or 4 days for
the 8 TopHat2 instances to complete.

7. Extract the alignments located on chr14
------------------------------------------

We do this for the 8 BAM files produced in step 6:

  cd ~/E-MTAB-1147
  R --vanilla <$SCRIPTS_DIR/subset_bam_chr14.R

This will produce 16 files: 1 <run_name>_chr14.bam and 1
<run_name>_chr14.bam.bai file per sequencing run. Those are the files
located in the extdata/ folder of the RNAseqData.HNRNPC.bam.chr14 package.

