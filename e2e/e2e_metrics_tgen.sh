#!/bin/bash


# Usage: ./e2e_metrics_tgen.sh [psql (or see tabulate docs)]


# Load bashrc
source /root/.bashrc


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh
conda activate e2e


# Evaluate TGen outputs on validation set
/root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/tgen_valid_scores.tsv \
-t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
/root/tgen/e2e-challenge/output/e2e-valid-outputs-postprocessed.txt

# Evaluate TGen outputs on test set
/root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/tgen_test_scores.tsv \
-t -H /root/tgen/e2e-challenge/input/test-conc.txt \
/root/tgen/e2e-challenge/output/e2e-test-outputs-postprocessed.txt

if [ ! -z "$1" ]; then
    # Export the mean and standard deviations of the scores of TGen outputs on validation set
    /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/tgen_valid_scores.tsv \
    -e /root/e2e-metrics/output_scores/mean_stdev_scores/tgen_valid_scores_final.csv -t -f $1

    # Export the mean and standard deviations of the scores of TGen outputs on test set
    /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/tgen_test_scores.tsv \
    -e /root/e2e-metrics/output_scores/mean_stdev_scores/tgen_test_scores_final.csv -t -f $1
else
    # Export the mean and standard deviations of the scores of TGen outputs on validation set
    /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/tgen_valid_scores.tsv \
    -e /root/e2e-metrics/output_scores/mean_stdev_scores/tgen_valid_scores_final.csv -t

    # Export the mean and standard deviations of the scores of TGen outputs on test set
    /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/tgen_test_scores.tsv \
    -e /root/e2e-metrics/output_scores/mean_stdev_scores/tgen_test_scores_final.csv -t
fi

# Deactivate e2e conda virtual environment
conda deactivate


exit 0
