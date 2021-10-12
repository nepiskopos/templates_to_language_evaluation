#!/bin/bash


# Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -decayed ]]; then
    echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]"
    
    exit 1
elif [[ $2 != 0 && $2 != 1 ]]; then
    echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]"
    
    exit 1
elif [[ $3 != -nar && $3 != -far ]]; then
    echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]"
    
    exit 1
elif [ ! -z $4 ]; then
    if [[ $4 != -mean_stdev ]]; then
        echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]"
        
        exit 1
    elif [ -z "$5" ]; then
        echo "Usage: ./e2e_metrics_ntg.sh -decayed 1 [or 0] -nar [or -far] [-mean_stdev] ['psql' (or see tabulate docs - only with -mean_stdev)]"
        
        exit 1
    fi
fi


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh
conda activate e2e_metrics


if [[ $3 == -nar ]]; then
    # Evaluate non-autoregressive NTG outputs on the validation set
    /root/e2e-metrics/measure_scores.py -l output_scores/complete_scores/ntg_valid_dec$2_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-valid-dec$2-postprocessed.txt
    
    # Evaluate non-autoregressive NTG outputs on the test set
    /root/e2e-metrics/measure_scores.py -l output_scores/complete_scores/ntg_test_dec$2_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/test-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-test-dec$2-postprocessed.txt
    
    if [ ! -z "$4" ]; then
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_valid_dec$2_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_valid_dec$2_scores_final.csv -t -f $5
        
        # Export the mean and standard deviations of the scores of non-autoregressive 
        # NTG outputs on test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_test_dec$2_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_test_dec$2_scores_final.csv -t -f $5
    fi
elif [[ $3 == -far ]]; then
    # Evaluate autoregressive NTG outputs on the validation set
    /root/e2e-metrics/measure_scores.py -l output_scores/complete_scores/ntg_far_valid_dec$2_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/valid-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-far-valid-dec$2-postprocessed.txt
    
    # Evaluate autoregressive NTG outputs on the test set
    /root/e2e-metrics/measure_scores.py -l output_scores/complete_scores/ntg_far_test_dec$2_scores.tsv \
    -t -H /root/tgen/e2e-challenge/input/test-conc.txt \
    /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-far-test-dec$2-postprocessed.txt

    if [ ! -z "$4" ]; then
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the validation set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_far_valid_dec$2_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_far_valid_dec$2_scores_final.csv -t -f $5
        
        # Display and export the mean and standard deviations of the 
        # scores of autoregressive NTG outputs on the test set
        /root/e2e-metrics/display_scores.py /root/e2e-metrics/output_scores/complete_scores/ntg_far_test_dec$2_scores.tsv \
        -e /root/e2e-metrics/output_scores/mean_stdev_scores/ntg_far_test_dec$2_scores_final.csv -t -f $5
    fi
fi


# Deactivate e2e_metrics conda virtual environment
conda deactivate


exit 0
