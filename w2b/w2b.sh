#!/bin/bash


# Usage: ./w2b.sh -train [or -test or -preprocess] best [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]


# Load bashrc
source /root/.bashrc


# Activate w2b conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh


# Check the corectness of the provided command-line arguments
if [[ $1 != -preprocess && $1 != -train && $1 != -test ]]; then
    echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]"
    
    exit 1
elif [[ $1 == -train ]]; then
    if [ ! -z "$2" ]; then
        if [[ $2 != -cuda ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]"
        
            exit 1
        fi
    fi
elif [[ $1 == -test ]]; then
    if [[ $2 != old && $2 != new ]]; then
        echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]"
    
        exit 1
    elif [[ $2 == new ]]; then
        if [[ $3 != 'BLEU' && $3 != 'ROUGE' ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]"
        
            exit 1
        fi
    fi
    if [ ! -z "$5" ]; then
        if [[ $5 != -cuda ]]; then
            echo ".Usage: ./w2b.sh -train [or -test or -preprocess] old [or new (only with test)] 'BLEU' [or 'ROUGE' (only with test new)] ['psql' (or see tabulate docs - only with test)] [-cuda]"
        
            exit 1
        fi
    fi
fi


# If -cuda is provided, activate w2b_gpu environment
# otherwise, activate w2b_cpu environment
if [[ $1 == -preprocess ]]; then
    conda activate w2b_cpu
else
    if [[ $2 == -cuda || $5 == -cuda ]]; then
        nvidia-smi
        conda activate w2b_gpu
    else
        conda activate w2b_cpu
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
    
    # Modify Main.py for re-training of the model by the user
    sed -e '/tf.app.flags.DEFINE_string("mode","train","train or test")/ s/^#*//' -i /root/wiki2bio/Main.py
    sed -e '/tf.app.flags.DEFINE_string("mode","test","train or test")/ s/^#*/#/' -i /root/wiki2bio/Main.py
    sed -e '/tf.app.flags.DEFINE_string("load","0","load directory")/ s/^#*//' -i /root/wiki2bio/Main.py
    sed -e '/tf.app.flags.DEFINE_string("load","model_retrained_by_user","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
    sed -e '/tf.app.flags.DEFINE_string("load","model_best_bleu_with","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
    
    # Re-train the model
    python2 /root/wiki2bio/Main.py
    
    # Get directory of most recently trained model
    ltd=$(ls -1 /root/wiki2bio/results/res/ | tail -n 1)
    
    # Rename log
    mv /root/wiki2bio/results/res/$ltd/log.txt /root/wiki2bio/results/res/$ltd/log_train.txt
    
    # Create directories for placing the new models
    mkdir /root/wiki2bio/results/res/model_best_bleu_with_new/
    mkdir /root/wiki2bio/results/res/model_best_rouge_with_new/
elif [[ $1 == -test && $2 == best ]]; then
    if [[ $3 == 'BLEU' ]]; then
		# Delete previous new test log and result table
		rm -rf /root/wiki2bio/results/res/model_best_bleu_with/log_test_old.txt
		rm -rf /root/wiki2bio/results/res/model_best_bleu_with/table_test_old.csv
		
		# Rename previous new test log and result table to old
		mv /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt /root/wiki2bio/results/res/model_best_bleu_with/log_test_old.txt
		mv /root/wiki2bio/results/res/model_best_bleu_with/test_table_new.csv /root/wiki2bio/results/res/model_best_bleu_with/table_test_old.csv
		
		# Modify Main.py for testing our own pre-trained model
		sed -e '/tf.app.flags.DEFINE_string("mode","test","train or test")/ s/^#*//' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("mode","train","train or test")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","0","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","model_best_bleu_with","load directory")/ s/^#*//' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","model_retrained_by_user","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		
		# Run main for testing our own pre-trained model
		python2 /root/wiki2bio/Main.py
		
		# Rename new test log
		mv /root/wiki2bio/results/res/model_best_bleu_with/log.txt /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt
		
		# Display results
		python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_bleu_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_bleu_with/table_test_new.csv -t -f $4
	if [[ $3 == 'ROUGE' ]]; then
		# Delete previous new test log and result table
		rm -rf /root/wiki2bio/results/res/model_best_rouge_with/log_test_old.txt
		rm -rf /root/wiki2bio/results/res/model_best_rouge_with/table_test_old.csv
		
		# Rename previous new test log and result table to old
		mv /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt /root/wiki2bio/results/res/model_best_rouge_with/log_test_old.txt
		mv /root/wiki2bio/results/res/model_best_rouge_with/test_table_new.csv /root/wiki2bio/results/res/model_best_rouge_with/table_test_old.csv
		
		# Modify Main.py for testing our own pre-trained model
		sed -e '/tf.app.flags.DEFINE_string("mode","test","train or test")/ s/^#*//' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("mode","train","train or test")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","0","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","model_best_bleu_with","load directory")/ s/^#*//' -i /root/wiki2bio/Main.py
		sed -e '/tf.app.flags.DEFINE_string("load","model_retrained_by_user","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
		
		# Run main for testing our own pre-trained model
		python2 /root/wiki2bio/Main.py
		
		# Rename new test log
		mv /root/wiki2bio/results/res/model_best_rouge_with/log.txt /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt
		
		# Display results
		python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/results/res/model_best_rouge_with/log_test_new.txt -e /root/wiki2bio/results/res/model_best_rouge_with/table_test_new.csv -t -f $4
elif [[ $1 == -test && $2 == new ]]; then
    # Get directory of most recently trained model
    ltd=$(ls -1 /root/wiki2bio/results/res/ | tail -n 1)
    
    if [[ $3 == 'BLEU' ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_old.csv
    
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_new.txt /root/wiki2bio/results/res/model_best_bleu_with_new/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_bleu_with_new/test_table_new.csv /root/wiki2bio/results/res/model_best_bleu_with_new/table_test_old.csv
        
        # Select the best model from the re-trained ones based on 'BLEU' or 'ROUGE'
        python2 /root/wiki2bio/select_best_model.py /root/wiki2bio/results/res/$ltd/log_train.txt /root/wiki2bio/results/res/$ltd/ /root/wiki2bio/results/res/model_best_bleu_with_new/ -m $3
        
        # Modify Main.py for testing user's re-trained model
        sed -e '/tf.app.flags.DEFINE_string("mode","test","train or test")/ s/^#*//' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("mode","train","train or test")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","0","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","model_best_bleu_with","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","model_retrained_by_user","load directory")/ s/^#*//' -i /root/wiki2bio/Main.py
    elif [[ $3 == 'ROUGE' ]]; then
        # Delete previous new test log and result table
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_old.txt
        rm -rf /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_old.csv
    
        # Rename previous new test log and result table to old
        mv /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_new.txt /root/wiki2bio/results/res/model_best_rouge_with_new/log_test_old.txt
        mv /root/wiki2bio/results/res/model_best_rouge_with_new/test_table_new.csv /root/wiki2bio/results/res/model_best_rouge_with_new/table_test_old.csv
        
        # Select the best model from the re-trained ones based on 'BLEU' or 'ROUGE'
        python2 /root/wiki2bio/select_best_model.py /root/wiki2bio/results/res/$ltd/log_train.txt /root/wiki2bio/results/res/$ltd/ /root/wiki2bio/results/res/model_best_rouge_with_new/ -m $3
        
        # Modify Main.py for testing user's re-trained model
        sed -e '/tf.app.flags.DEFINE_string("mode","test","train or test")/ s/^#*//' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("mode","train","train or test")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","0","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","model_best_rouge_with","load directory")/ s/^#*/#/' -i /root/wiki2bio/Main.py
        sed -e '/tf.app.flags.DEFINE_string("load","model_retrained_by_user","load directory")/ s/^#*//' -i /root/wiki2bio/Main.py
    fi
    
    # Run main for testing our user's re-trained model    
    python2 /root/wiki2bio/Main.py
    
    # Display results
    python2 /root/wiki2bio/display_test_metrics.py /root/wiki2bio/log/log_test_new.txt -e /root/wiki2bio/log/test_table_new.csv -t -f $4
fi


# Deactivate w2b conda virtual environment
conda deactivate


exit 0
