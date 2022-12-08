#!/bin/bash


# Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]


# Load bashrc
source /root/.bashrc


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh


# Check the corectness of the provided command-line arguments
if [[ $1 != -preprocess && $1 != -train && $1 != -test ]]; then
    echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

    exit 1
elif [[ $1 == -train ]]; then
    if [ ! -z "$2" ]; then
        if [[ $2 != new && $2 != latest ]]; then
            echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

            exit 1
        fi
        if [ ! -z "$3" ]; then
            if [[ $3 != -gpu ]]; then
                echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

                exit 1
            fi
        fi
    else
        echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

        exit 1
    fi
elif [[ $1 == -test ]]; then
    if [[ $2 != latest && $2 != best ]]; then
        echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

        exit 1
    elif [[ $2 == latest ]]; then
        if [[ $3 != BLEU && $3 != ROUGE ]]; then
            echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

            exit 1
        fi
    elif [[ $3 == best ]]; then
        if [[ $3 != BLEU ]]; then
            echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

            exit 1
        fi
    fi
    if [ ! -z "$5" ]; then
        if [[ $5 != -gpu ]]; then
            echo "Usage: ./w2b.sh -train [or -test or -preprocess] new [or latest or best (only with test)] BLEU [or ROUGE (only with test latest)] [psql (or see tabulate docs - only with test)] [-gpu]"

            exit 1
        fi
    fi
fi


# Check given arguments to extract values
gpu=''
if [ ! -z "$3" ]; then
    if [[ $3 == -gpu ]]; then
        gpu='--gpu 0'
    fi
elif [ ! -z "$4" ]; then
    if [[ $4 == -gpu ]]; then
        gpu='--gpu 0'
    fi
elif [ ! -z "$5" ]; then
    if [[ $5 == -gpu ]]; then
        gpu='--gpu 0'
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
    if [[ $2 == latest ]]; then
        # Get directory of last trained model
        ltd=$(ls -t /root/wiki2bio/results/res/ | head -1)

        # Delete previously selected model with the best BLEU score
        rm -rf /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/

        # Delete previously selected model with the best ROUGE score
        rm -rf /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/

        # Get last train epoch
        lte=$(ls -t /root/wiki2bio/results/res/$ltd/loads/ | head -1)

        # Continue training the model (up to 50 total epochs)
        python2 /root/wiki2bio/Main.py --mode train --load $ltd/loads/$lte $gpu
    elif [[ $2 == new ]]; then
        # Train a new model from the start
        python2 /root/wiki2bio/Main.py --mode train $gpu
    fi
elif [[ $1 == -test && $2 == latest ]]; then
    # Get directory of most recently trained model
    ltd=$(ls -t /root/wiki2bio/results/res/ | head -1)

    if [[ $3 == BLEU ]]; then
        # Delete previously selected model with the best BLEU score
        rm -rf /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/

        # Select the best model from the re-trained ones based on BLEU
        python2 /root/wiki2bio/select_best_model.py -l /root/wiki2bio/results/res/$ltd/log_train.txt --model /root/wiki2bio/results/res/$ltd/ --output /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/ -m $3

        # Run main for testing user's re-trained model with the best BLEU score
        python2 /root/wiki2bio/Main.py --mode test --load $ltd/loads/model_best_bleu_with $gpu

        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/log_test.txt -o /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/table_test.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/log_test.txt -o /root/wiki2bio/results/res/$ltd/loads/model_best_bleu_with/table_test.csv -t
        fi
    elif [[ $3 == ROUGE ]]; then
        # Delete previously selected model with the best ROUGE score
        rm -rf /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/

        # Select the best model from the re-trained ones based on ROUGE
        python2 /root/wiki2bio/select_best_model.py -l /root/wiki2bio/results/res/$ltd/log_train.txt --model /root/wiki2bio/results/res/$ltd/ --output /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/ -m $3

        # Run main for testing user's re-trained model with the best ROUGE score
        python2 /root/wiki2bio/Main.py --mode test --load $ltd/loads/model_best_rouge_with $gpu

        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/log_test.txt -o /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/table_test.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/log_test.txt -o /root/wiki2bio/results/res/$ltd/loads/model_best_rouge_with/table_test.csv -t
        fi
    fi
elif [[ $1 == -test && $2 == best ]]; then
    if [[ $3 == BLEU ]]; then
        # Delete previous test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with/log_test
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with/table_test.csv

        # Run main for testing our own pre-trained model
        python2 /root/wiki2bio/Main.py --mode test --load model_best_bleu_with $gpu

        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/model_best_bleu_with/log_test.txt -o /root/wiki2bio/results/res/model_best_bleu_with/table_test.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/model_best_bleu_with/log_test.txt -o /root/wiki2bio/results/res/model_best_bleu_with/table_test.csv -t
        fi
    elif [[ $3 == ROUGE ]]; then
        # Delete previous test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with/log_test.txt
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with/table_test.csv

        # Run main for testing our own pre-trained model
        python2 /root/wiki2bio/Main.py --mode test --load model_best_rouge_with $gpu

        # Display results
        if [ ! -z "$4" ]; then
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/model_best_rouge_with/log_test.txt -o /root/wiki2bio/results/res/model_best_rouge_with/table_test.csv -t -f $4
        else
            python2 /root/wiki2bio/display_test_metrics.py -l /root/wiki2bio/results/res/model_best_rouge_with/log_test.txt -o /root/wiki2bio/results/res/model_best_rouge_with/table_test.csv -t
        fi
    fi
fi


# Deactivate w2b conda virtual environment
conda deactivate


exit 0
