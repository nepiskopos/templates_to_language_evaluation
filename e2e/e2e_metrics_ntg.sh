#!/bin/bash


# Usage: ./e2e_metrics_ntg.sh -nar [or -war] -decay ['psql' (or see tabulate docs)]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -nar && $1 != -war ]]; then
    echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -war] ['psql' (or see tabulate docs)]"
    
    exit 1
elif [[ $2 != -decay ]]; then
    echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -war] ['psql' (or see tabulate docs)]"
    
    exit 1
fi


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh
conda activate e2e_metrics

# If decay option chosen
dec=0
if [ ! -z "$2" ]; then
    dec=1
fi



if [[ $1 == -nar ]]; then
    # Evaluate non-autoregressive NTG outputs on the validation set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_valid_dec"$dec"_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-valid-dec"$dec"-postprocessed.txt
    
    # Evaluate non-autoregressive NTG outputs on the test set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_test_dec"$dec"_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/test-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-test-dec"$dec"-postprocessed.txt
    
    if [ ! -z "$3" ]; then
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_valid_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_valid_dec"$dec"_scores_final.csv -t -f $3
        
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_test_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_test_dec"$dec"_scores_final.csv -t -f $3
    else
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_valid_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_valid_dec"$dec"_scores_final.csv -t
        
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_test_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_test_dec"$dec"_scores_final.csv -t
    fi
elif [[ $1 == -war ]]; then
    # Evaluate autoregressive NTG outputs on the validation set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_war_valid_dec"$dec"_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-war-valid-dec"$dec"-postprocessed.txt
    
    # Evaluate autoregressive NTG outputs on the test set
    /root/e2e-metrics/measure_scores.py -l /root/e2e-metrics/output_scores/complete_scores/ntg_war_test_dec"$dec"_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/test-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-war-test-dec"$dec"-postprocessed.txt

    if [ ! -z "$3" ]; then
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_war_valid_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_war_valid_dec"$dec"_scores_final.csv -t -f $3
        
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_war_test_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_war_test_dec"$dec"_scores_final.csv -t -f $3
    else
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_war_valid_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_war_valid_dec"$dec"_scores_final.csv -t
        
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_war_test_dec"$dec"_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_war_test_dec"$dec"_scores_final.csv -t
    fi
fi


# Deactivate e2e_metrics conda virtual environment
conda deactivate


exit 0
