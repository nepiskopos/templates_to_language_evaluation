#!/bin/bash


# Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -train && $1 != -seg && $1 != -gen ]]; then
    echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]'
    
    exit 1
elif [[ $2 != -nar && $2 != -war ]]; then
    echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]'

    exit 1
elif [ ! -z "$3" ]; then
    if [[ $3 != -decay ]]; then
        echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]'

        exit 1
	elif [[ $3 != -gpu ]]; then
		echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]'

        exit 1
    fi
elif [ ! -z "$4" ]; then
    if [[ $4 != -gpu ]]; then
        echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-gpu]'

        exit 1
    fi
fi


# Check given arguments to extract values
decay=''
dec=0
gpu=''
if [ ! -z "$3" ]; then
	if [[ $3 == -decay ]]; then
        decay='-onmt_decay'
		dec=1
		if [ ! -z "$4" ]; then
			gpu='-cuda'
		fi
	else
		gpu='-cuda'
    fi
fi


# Activate ntg conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh

# If -gpu is provided, activate ntg_gpu environment
# otherwise, activate ntg_cpu environment
if [ -z "$gpu" ]; then
    conda activate ntg_cpu
else
    nvidia-smi
    conda activate ntg_gpu
fi


if [[ $1 == -train ]]; then
    # Model Training
    
    if [[ $2 == -nar ]]; then
        # Train the non-autoregressive model using the WikiBio data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 \
        -mlpinp $decay $gpu -save /root/neural-template-gen/models/wb-45-3-new.pt."$dec"
    elif [[ $2 == -war ]]; then
        # Train the autoregressive model using the WikiBio data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 \
        -mlpinp $decay $gpu -save /root/neural-template-gen/models/wb-45-3-war-new.pt."$dec" -ar_after_decay -word_ar
    fi
elif [[ $1 == -seg ]]; then
    # Viterbi Segmentation/Template Extraction
    
    if [[ $2 == -nar ]]; then
        # Run the segmentation for the non-autoregressive WikiBio model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 -\
        log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 \
        -mlpinp $decay $gpu -load /root/neural-template-gen/models/wb-45-3-new.pt."$dec" -label_train \
        | tee /root/neural-template-gen/segs/seg-wb-45-3-new-dec"$dec".txt
    elif [[ $2 == -war ]]; then
        # Run the segmentation for the autoregressive WikiBio model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 \
        -mlpinp $decay $gpu -load /root/neural-template-gen/models/wb-45-3-war-new.pt."$dec" -label_train -ar_after_decay -word_ar \
        | tee /root/neural-template-gen/segs/seg-wb-45-3-war-new-dec"$dec".txt
    fi
elif [[ $1 == -gen ]]; then
    # Text Generation

    if [[ $2 == -nar ]]; then
        # Generate on the WikiBio test set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 -mlpinp $decay $gpu \
        -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt -load /root/neural-template-gen/models/wb-45-3-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-wb-45-3-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' -min_gen_tokes 20 \
        > /root/neural-template-gen/gens/gen-wb-45-3-dec"$dec".txt
    elif [[ $2 == -war ]]; then
        # Generate on the WikiBio test set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 -mlpinp $decay $gpu \
        -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt -load /root/neural-template-gen/models/wb-45-3-war-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-wb-45-3-war-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' -min_gen_tokes 20 \
        > /root/neural-template-gen/gens/gen-wb-45-3-war-dec"$dec".txt
    fi
fi


# Deactivate ntg virtual environment
conda deactivate


exit 0