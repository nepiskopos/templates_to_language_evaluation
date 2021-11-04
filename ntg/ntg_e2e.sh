#!/bin/bash


# Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -train && $1 != -seg && $1 != -gen ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'
    
    exit 1
elif [[ $2 != -nar && $2 != -war ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

    exit 1
elif [ ! -z "$3" ]; then
    if [[ $3 != -decay ]]; then
        echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

        exit 1
    fi
elif [ ! -z "$4" ]; then
    if [[ $4 != -cuda ]]; then
        echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -nar [or -war] [-decay] [-cuda]'

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
        # Train the non-autoregressive model using the E2E data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 \
        -mlpinp $decayed $4 -seed 1818 -save /root/neural-template-gen/models/e2e-55-5-new.pt."$dec"
    elif [[ $2 == -war ]]; then
        # Train the autoregressive model using the E2E data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 \
        -mlpinp $decayed $4 -seed 1111 -save /root/neural-template-gen/models/e2e-60-1-war-new.pt."$dec" -ar_after_decay
    fi
elif [[ $1 == -seg ]]; then
    # Viterbi Segmentation/Template Extraction
    
    if [[ $2 == -nar ]]; then
        # Run the segmentation for the non-autoregressive E2E model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 \
        -mlpinp $decayed $4 -load /root/neural-template-gen/models/e2e-55-5-new.pt."$dec" -label_train \
        | tee /root/neural-template-gen/segs/seg-e2e-55-5-new-dec"$dec".txt
    elif [[ $2 == -war ]]; then
        # Run the segmentation for the autoregressive E2E model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 \
        -mlpinp $decayed $4 -load /root/neural-template-gen/models/e2e-60-1-war-new.pt."$dec" -label_train -ar_after_decay \
        | tee /root/neural-template-gen/segs/seg-e2e-60-1-war-new-dec"$dec".txt
    fi
elif [[ $1 == -gen ]]; then
    # Text Generation

    if [[ $2 == -nar ]]; then
        # Generate on the E2E validation set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 -mlpinp $decayed $4 \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/e2e-55-5-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-55-5-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        > /root/neural-template-gen/gens/gen-e2e-55-5-valid-dec"$dec".txt

        # Generate on the E2E test set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 -mlpinp $decayed $4 \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_test.txt -load /root/neural-template-gen/models/e2e-55-5-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-55-5-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        > /root/neural-template-gen/gens/gen-e2e-55-5-test-dec"$dec".txt
        
        # Postprocess the outputs
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-55-5-valid-dec"$dec".txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-valid-dec"$dec"-postprocessed.txt
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-55-5-test-dec"$dec".txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-test-dec"$dec"-postprocessed.txt
    elif [[ $2 == -war ]]; then
        # Generate on the E2E validation set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 -mlpinp $decayed $4 \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/e2e-60-1-war-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-60-1-war-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        > /root/neural-template-gen/gens/gen-e2e-60-1-war-valid-dec"$dec".txt

        # Generate on the E2E test set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 -mlpinp $decayed $4 \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_test.txt -load /root/neural-template-gen/models/e2e-60-1-war-new.pt."$dec" \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-60-1-war-new-dec"$dec".txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' \
        > /root/neural-template-gen/gens/gen-e2e-60-1-war-test-dec"$dec".txt

        # Postprocess the outputs
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-60-1-war-valid-dec"$dec".txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-war-valid-dec"$dec"-postprocessed.txt
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-60-1-war-test-dec"$dec".txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-war-test-dec"$dec"-postprocessed.txt
    fi
fi


# Deactivate ntg conda virtual environment
conda deactivate


exit 0
