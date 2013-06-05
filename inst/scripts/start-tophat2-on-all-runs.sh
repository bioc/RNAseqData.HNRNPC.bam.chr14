#!/bin/bash
#

set -e # Exit immediately if a simple command exits with a non-zero status.

# 3. Create the tophat2_out folder:
#      mkdir tophat2_out

TOPHAT2_CMD="~/tophat-2.0.8b.Linux_x86_64/tophat2 --mate-inner-dist 150 --solexa-quals --max-multihits 5 --no-discordant --no-mixed --coverage-search --microexon-search --library-type fr-unstranded"
BOWTIE_INDEX="~/bowtie2-2.1.0/indexes/hg19"
INPUT_FILE_DIR="fastq"
OUTPUT_DIR="tophat2_out"

input_file_suffix=".fastq.gz"

# Prepare command for aligning Run1:
run1_name="ERR127306"
output_dir1="$OUTPUT_DIR/$run1_name"
tophat2_cmd1="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir1 $BOWTIE_INDEX $INPUT_FILE_DIR/${run1_name}_1$input_file_suffix $INPUT_FILE_DIR/${run1_name}_2$input_file_suffix && samtools index $output_dir1/accepted_hits.bam && echo DONE)"
cmd1_logfile="tophat2-$run1_name.log"

# Prepare command for aligning Run2:
# (takes about 17 hours on rhino02 using --num-threads 4)
run2_name="ERR127307"
output_dir2="$OUTPUT_DIR/$run2_name"
tophat2_cmd2="($TOPHAT2_CMD --num-threads 4 --output-dir $output_dir2 $BOWTIE_INDEX $INPUT_FILE_DIR/${run2_name}_1$input_file_suffix $INPUT_FILE_DIR/${run2_name}_2$input_file_suffix && samtools index $output_dir2/accepted_hits.bam && echo DONE)"
cmd2_logfile="tophat2-$run2_name.log"

# Prepare command for aligning Run3:
run3_name="ERR127308"
output_dir3="$OUTPUT_DIR/$run3_name"
tophat2_cmd3="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir3 $BOWTIE_INDEX $INPUT_FILE_DIR/${run3_name}_1$input_file_suffix $INPUT_FILE_DIR/${run3_name}_2$input_file_suffix && samtools index $output_dir3/accepted_hits.bam && echo DONE)"
cmd3_logfile="tophat2-$run3_name.log"

# Prepare command for aligning Run4:
run4_name="ERR127309"
output_dir4="$OUTPUT_DIR/$run4_name"
tophat2_cmd4="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir4 $BOWTIE_INDEX $INPUT_FILE_DIR/${run4_name}_1$input_file_suffix $INPUT_FILE_DIR/${run4_name}_2$input_file_suffix && samtools index $output_dir4/accepted_hits.bam && echo DONE)"
cmd4_logfile="tophat2-$run4_name.log"

# Prepare command for aligning Run5:
run5_name="ERR127302"
output_dir5="$OUTPUT_DIR/$run5_name"
tophat2_cmd5="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir5 $BOWTIE_INDEX $INPUT_FILE_DIR/${run5_name}_1$input_file_suffix $INPUT_FILE_DIR/${run5_name}_2$input_file_suffix && samtools index $output_dir5/accepted_hits.bam && echo DONE)"
cmd5_logfile="tophat2-$run5_name.log"

# Prepare command for aligning Run6:
run6_name="ERR127303"
output_dir6="$OUTPUT_DIR/$run6_name"
tophat2_cmd6="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir6 $BOWTIE_INDEX $INPUT_FILE_DIR/${run6_name}_1$input_file_suffix $INPUT_FILE_DIR/${run6_name}_2$input_file_suffix && samtools index $output_dir6/accepted_hits.bam && echo DONE)"
cmd6_logfile="tophat2-$run6_name.log"

# Prepare command for aligning Run7:
run7_name="ERR127304"
output_dir7="$OUTPUT_DIR/$run7_name"
tophat2_cmd7="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir7 $BOWTIE_INDEX $INPUT_FILE_DIR/${run7_name}_1$input_file_suffix $INPUT_FILE_DIR/${run7_name}_2$input_file_suffix && samtools index $output_dir7/accepted_hits.bam && echo DONE)"
cmd7_logfile="tophat2-$run7_name.log"

# Prepare command for aligning Run8:
run8_name="ERR127305"
output_dir8="$OUTPUT_DIR/$run8_name"
tophat2_cmd8="($TOPHAT2_CMD --num-threads 2 --output-dir $output_dir8 $BOWTIE_INDEX $INPUT_FILE_DIR/${run8_name}_1$input_file_suffix $INPUT_FILE_DIR/${run8_name}_2$input_file_suffix && samtools index $output_dir8/accepted_hits.bam && echo DONE)"
cmd8_logfile="tophat2-$run8_name.log"

## Choose between the 3 predefined workflows below: 2batchesof4, 4batchesof2,
## or 8batchesof1.
workflow="2batchesof4"

if [ "$workflow" == "2batchesof4" ]; then
  # We divide the 8 commands in 2 batches of 4 commands. The 2 batches are run
  # in parallel and the 4 tophat2 commands within each batch are run
  # sequencially. The following diagram shows the workflow:
  #   
  #           .--> cmd1 --> cmd2 --> cmd3 --> cmd4 --.
  #          /                                        \
  #       -->                                          -->
  #          \                                        /
  #           `--> cmd5 --> cmd6 --> cmd7 --> cmd8 --´
  #
  # This workflow should take between 60 and 70 h to complete on a modern Linux
  # server.
  echo "start commands for aligning Runs 1 && 2 && 3 && 4 (sequentially)"
  tophat2_cmd1234_sequencial="(($tophat2_cmd1 >>$cmd1_logfile 2>&1) && \
                               ($tophat2_cmd2 >>$cmd2_logfile 2>&1) && \
                               ($tophat2_cmd3 >>$cmd3_logfile 2>&1) && \
                               ($tophat2_cmd4 >>$cmd4_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd1234_sequencial"
  echo "start commands for aligning Runs 5 && 6 && 7 && 8 (sequentially)"
  tophat2_cmd5678_sequencial="(($tophat2_cmd5 >>$cmd5_logfile 2>&1) && \
                               ($tophat2_cmd6 >>$cmd6_logfile 2>&1) && \
                               ($tophat2_cmd7 >>$cmd7_logfile 2>&1) && \
                               ($tophat2_cmd8 >>$cmd8_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd5678_sequencial"
elif [ "$workflow" == "4batchesof2" ]; then
  # Here is another workflow if you can afford running 4 tophat2 commands in
  # parallel (you need at least 4 cores for that and probably > 16 GB of RAM):
  #   
  #            .--> cmd1 --> cmd2 --.
  #           /                      \
  #          /----> cmd3 --> cmd4 ----\
  #       -->                          -->
  #          \----> cmd5 --> cmd6 ----/
  #           \                      /
  #            `--> cmd7 --> cmd8 --´
  #
  # This workflow should take between 30 and 35 h to complete on a modern Linux
  # server.
  echo "start commands for aligning Runs 1 && 2 (sequentially)"
  tophat2_cmd12_sequencial="(($tophat2_cmd1 >>$cmd1_logfile 2>&1) && \
                             ($tophat2_cmd2 >>$cmd2_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd12_sequencial"
  echo "start commands for aligning Runs 3 && 4 (sequentially)"
  tophat2_cmd34_sequencial="(($tophat2_cmd3 >>$cmd3_logfile 2>&1) && \
                             ($tophat2_cmd4 >>$cmd4_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd34_sequencial"
  echo "start commands for aligning Runs 5 && 6 (sequentially)"
  tophat2_cmd56_sequencial="(($tophat2_cmd5 >>$cmd5_logfile 2>&1) && \
                             ($tophat2_cmd6 >>$cmd6_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd56_sequencial"
  echo "start commands for aligning Runs 7 && 8 (sequentially)"
  tophat2_cmd78_sequencial="(($tophat2_cmd7 >>$cmd7_logfile 2>&1) && \
                             ($tophat2_cmd8 >>$cmd8_logfile 2>&1)) &"
  /bin/bash -c "$tophat2_cmd78_sequencial"
elif [ "$workflow" == "8batchesof1" ]; then
  # Very likely to blow up your server. Use at your own risk!
  echo "start commands for aligning Run 1"
  /bin/bash -c "$tophat2_cmd1 >>$cmd1_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd2 >>$cmd2_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd3 >>$cmd3_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd4 >>$cmd4_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd5 >>$cmd5_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd6 >>$cmd6_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd7 >>$cmd7_logfile 2>&1 &"
  /bin/bash -c "$tophat2_cmd8 >>$cmd8_logfile 2>&1 &"
fi

