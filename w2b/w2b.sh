#!/bin/bash


# Usage: ./w2b.sh -train [or -test or -preprocess] [new (only with test)] [or best (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]


# Load bashrc
source /root/.bashrc


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh


# Check the corectness of the provided command-line arguments
if [[ $1 != -preprocess && $1 != -train && $1 != -test ]]; then
    echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]"
    
    exit 1
elif [[ $1 == -train ]]; then
    if [ ! -z "$2" ]; then
        if [[ $2 != -gpu ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]"
        
            exit 1
        fi
    fi
elif [[ $1 == -test ]]; then
    if [[ $2 != new && $2 != best ]]; then
        echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]"
    
        exit 1
    elif [[ $2 == new ]]; then
        if [[ $3 != BLEU && $3 != ROUGE ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]"
        
            exit 1
        fi
    fi
    if [ ! -z "$5" ]; then
        if [[ $5 != -gpu ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] BLEU [or ROUGE (only with test new)] [psql (or see tabulate docs - only with test)] [-gpu]"
        
            exit 1
        fi
    fi
fi


# Check given arguments to extract values
gpu=''
if [ ! -z "$2" ]; then
	if [[ $2 == -gpu ]]; then
        gpu='-cuda'
	fi
elif [ ! -z "$4" ]; then
	if [[ $4 == -gpu ]]; then
		gpu='-cuda'
	fi
elif [ ! -z "$5" ]; then
    if [[ $5 == -gpu ]]; then
		gpu='-cuda'
	fi
fi


# Activate ntg conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh

# If -gpu is provided, activate w2b_gpu environment
# otherwise, activate w2b_cpu environment
if [[ $1 == -preprocess ]]; then
    conda activate w2b_cpu
else
	if [ -z "$gpu" ]; then
        conda activate w2b_cpu
    else
        nvidia-smi
        conda activate w2b_gpu
    fi
fi


if [[ $1 == -preprocess ]]; then
    # Delete previous pre-processed data
    find /root/wiki2bio/processed_data/ -type f -name '*.id' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.lab' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.lab.id' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.pos' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.rpos' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.val' -delete
    find /root/wiki2bio/processed_data/ -type f -name '*.val.id' -delete
    find /root/wiki2bio/processed_data/test/test_split_for_rouge/ -type f -name 'gold_summary_*' -delete
    find /root/wiki2bio/processed_data/valid/valid_split_for_rouge/ -type f -name 'gold_summary_*' -delete
    
    # Preprocess data
    python2 /root/wiki2bio/preprocess.py
elif [[ $1 == -train ]]; then
    # Delete previous train results
    for i in /root/wiki2bio/results/res/model_retrained_by_user*/*; do rm -rf "$i"; done
    for i in /root/wiki2bio/results/evaluation/model_retrained_by_user*/*; do rm -rf "$i"; done
    rm -rf /root/wiki2bio/results/res/model_retrained_by_user*/
    rm -rf /root/wiki2bio/results/evaluation/model_retrained_by_user*/
    
    # Re-train the model
    python2 /root/wiki2bio/Main.py --mode train
    
    # Get directory of most recently trained model
    ltd=$(ls -1 /root/wiki2bio/results/res/ | tail -n 1)
    
    # Rename log
    mv /root/wiki2bio/results/res/$ltd/log.txt /root/wiki2bio/results/res/$ltd/log_train.txt
elif [[ $1 == -test && $2 == best ]]; then
    if [[ $3 == BLEU ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with/table_test_old.csv
        
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt /root/wiki2bio/results/res/model_best_bleu_with/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_bleu_with/test_table_new.csv /root/wiki2bio/results/res/model_best_bleu_with/table_test_old.csv
        
        # Run main for testing our own pre-trained model
        python2 /root/wiki2bio/Main.py --mode test --load model_best_bleu_with
        
        # Rename new test log
        mv /root/wiki2bio/results/res/model_best_bleu_with/log.txt /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt
        
        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_bleu_with/table_test_new.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_bleu_with/table_test_new.csv -t
        fi
    elif [[ $3 == ROUGE ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with/table_test_old.csv
        
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt /root/wiki2bio/results/res/model_best_rouge_with/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_rouge_with/test_table_new.csv /root/wiki2bio/results/res/model_best_rouge_with/table_test_old.csv
        
        # Run main for testing our own pre-trained model
        python2 /root/wiki2bio/Main.py --mode test --load model_best_rouge_with
        
        # Rename new test log
        mv /root/wiki2bio/results/res/model_best_rouge_with/log.txt /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt
        
        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_rouge_with/table_test_new.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_rouge_with/table_test_new.csv -t
        fi
    fi
elif [[ $1 == -test && $2 == new ]]; then
    # Get directory of most recently trained model
    ltd=$(ls -1 /root/wiki2bio/results/res/ | tail -n 1)
    
    if [[ $3 == BLEU ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_old.csv
    
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_new.txt /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_bleu_with_new/test_table_new.csv /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_old.csv
        
        # Select the best model from the re-trained ones based on BLEU
        python2 /root/wiki2bio/select_best_model.py /root/wiki2bio/results/res/$ltd/log_train.txt /root/wiki2bio/results/res/$ltd/ /root/wiki2bio/results/res/model_best_bleu_with_new/ -m $3
        
        # Run main for testing user's re-trained model with the best bleu score
        python2 /root/wiki2bio/Main.py --mode test --load model_best_bleu_with_new
        
        # Rename new test log
        mv /root/wiki2bio/results/res/model_best_bleu_with_new/log.txt /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_new.txt
        
        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_new.txt -e /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_new.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_new.txt -e /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_new.csv -t
        fi
    elif [[ $3 == ROUGE ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_old.csv
    
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_new.txt /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_rouge_with_new/test_table_new.csv /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_old.csv
        
        # Select the best model from the re-trained ones based on ROUGE
        python2 /root/wiki2bio/select_best_model.py /root/wiki2bio/results/res/$ltd/log_train.txt /root/wiki2bio/results/res/$ltd/ /root/wiki2bio/results/res/model_best_rouge_with_new/ -m $3
        
        # Run main for testing user's re-trained model with the best bleu score
        python2 /root/wiki2bio/Main.py --mode test --load model_best_rouge_with_new
        
        # Rename new test log
        mv /root/wiki2bio/results/res/model_best_rouge_with_new/log.txt /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_new.txt
        
        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_new.txt -e /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_new.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_new.txt -e /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_new.csv -t
        fi
    fi
fi


# Deactivate w2b conda virtual environment
conda deactivate


exit 0