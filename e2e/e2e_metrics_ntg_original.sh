#!/bin/bash


# Usage: ./e2e_metrics_ntg_original.sh -nar [or -war] ['psql' (or see tabulate docs)]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -nar && $1 != -war ]]; then
    echo "Usage: ./e2e_metrics_ntg_original.sh -nar [or -war] ['psql' (or see tabulate docs)]"
    
    exit 1
fi


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh
conda activate e2e


if [[ $1 == -nar ]]; then
    # Evaluate non-autoregressive NTG outputs of the original model on the validation set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_valid_scores_original.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/original_gens/gen-e2e-55-5-postprocessed.txt
    
    # Export and display the mean and standard deviations of the scores
    # of non-autoregressive NTG outputs on validation set
    if [ ! -z "$2" ]; then
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_valid_scores_original.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_valid_scores_final_original.csv -t -f $2
    else
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_valid_scores_original.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_valid_scores_final_original.csv -t
    fi
elif [[ $1 == -war ]]; then
    # Evaluate autoregressive NTG outputs on the validation set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_far_valid_scores_original.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/original_gens/gen-e2e-60-1-far-postprocessed.txt

    # Export and display the mean and standard deviations of the scores
    # of autoregressive NTG outputs on validation set
    if [ ! -z "$2" ]; then
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_far_valid_scores_original.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_far_valid_scores_final_original.csv -t -f $2
    else
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_far_valid_scores_original.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_far_valid_scores_final_original.csv -t
    fi
fi


# Deactivate e2e conda virtual environment
conda deactivate


exit 0
