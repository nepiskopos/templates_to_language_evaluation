#!/bin/bash


# Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -train && $1 != -seg && $1 != -gen ]]; then
    echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'
    
    exit 1
elif [[ $2 != -nar && $2 != -war ]]; then
    echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

    exit 1
elif [ ! -z "$3" ]; then
    if [[ $3 != -decay ]]; then
        echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

        exit 1
    fi
elif [ ! -z "$4" ]; then
    if [[ $4 != -cuda ]]; then
        echo 'Usage: ./ntg_wb.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

        exit 1
    fi
fi


# Activate ntg conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh

# If -cuda is provided, activate ntg_gpu environment
# otherwise, activate ntg_cpu environment
if [ -z "$4" ]; then
    conda activate ntg_cpu
else
    nvidia-smi
    conda activate ntg_gpu
fi

# If decay option chosen
decayed=''
dec=0
if [ ! -z "$3" ]; then
    decayed='-onmt_decay'
    dec=1
fi


if [[ $1 == -train ]]; then
    # Model Training
    
    if [[ $2 == -nar ]]; then
        # Train the non-autoregressive model using the WikiBio data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed $4 -save /root/neural-template-gen/models/wb-45-3-new.pt
    elif [[ $2 == -war ]]; then
        # Train the autoregressive model using the WikiBio data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed $4 -save /root/neural-template-gen/models/wb-45-3-war-new.pt -ar_after_decay -word_ar
    fi
elif [[ $1 == -seg ]]; then
    # Viterbi Segmentation/Template Extraction
    
    if [[ $2 == -nar ]]; then
        # Run the segmentation for the non-autoregressive WikiBio model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 -\
        log_interval 200 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed $4 -load /root/neural-template-gen/models/wb-45-3-new.pt.$3 -label_train | tee /root/neural-template-gen/segs/seg-wb-45-3-new-dec"$dec".txt
    elif [[ $2 == -war ]]; then
        # Run the segmentation for the autoregressive WikiBio model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 200 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed $4 -load /root/neural-template-gen/models/wb-45-3-war-new.pt.$3 -label_train | tee /root/neural-template-gen/segs/seg-wb-45-3-war-new-dec"$dec".txt
    fi
elif [[ $1 == -gen ]]; then
    # Text Generation

    if [[ $2 == -nar ]]; then
        # Generate on the WikiBio test set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt \
        -load /root/neural-template-gen/models/wb-45-3-new.pt.$3 -tagged_fi /root/neural-template-gen/segs/seg-wb-45-3-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        $4 -min_gen_tokes 20 > /root/neural-template-gen/gens/gen-wb-45-3-dec"$dec".txt
    elif [[ $2 == -war ]]; then
        # Generate on the WikiBio test set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
        -log_interval 1000 -thresh 29 -emb_drop -bsz 1 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool \
        -unif_lenps -one_rnn -Kmul 3 -mlpinp $decayed -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt \
        -load /root/neural-template-gen/models/wb-45-3-war-new.pt.$3.pt -tagged_fi /root/neural-template-gen/segs/seg-wb-45-3-war-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        $4 -min_gen_tokes 20 > /root/neural-template-gen/gens/gen-wb-45-3-war-dec"$dec".txt
    fi
fi


# Deactivate ntg virtual environment
conda deactivate


exit 0
