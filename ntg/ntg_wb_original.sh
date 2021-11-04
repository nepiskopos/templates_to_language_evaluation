#!/bin/bash


# Usage: ./ntg_wb_original.sh -nar [or -war] [-cuda]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -nar && $1 != -war ]]; then
    echo 'Usage: ./ntg_wb_original.sh -nar [or -war] [-cuda]'

    exit 1
elif [[ ! -z "$2" ]]; then
    if [[ $2 != -cuda ]]; then
        echo 'Usage: ./ntg_wb_original.sh -nar [or -war] [-cuda]'

        exit 1
    fi
fi


# Activate ntg conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh

# If -cuda is provided, activate ntg_gpu environment
# otherwise, activate ntg_cpu environment
if [ -z "$2" ]; then
    conda activate ntg_cpu
else
    nvidia-smi
    conda activate ntg_gpu
fi


if [[ $2 == -nar ]]; then
    # Generate on the WikiBio test set using the non-autoregressive model
    python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
    -log_interval 1000 -thresh 29 -emb_drop -bsz 5 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 -mlpinp -onmt_decay $4 \
    -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt -load /root/neural-template-gen/models/original_models/wb-45-3.pt \
    -tagged_fi /root/neural-template-gen/segs/original_segs/seg-wb-45-3.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' -min_gen_tokes 20 \
    > /root/neural-template-gen/segs/original_gens/gen-wb-45-3.txt
elif [[ $2 == -war ]]; then
    # Generate on the WikiBio test set using the autoregressive model
    python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/wb_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 45 -L 4 \
    -log_interval 1000 -thresh 29 -emb_drop -bsz 5 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 3 -mlpinp -onmt_decay $4 \
    -gen_from_fi /root/neural-template-gen/data/wb_aligned/src_test.txt -load /root/neural-template-gen/models/original_models/wb-45-3-war.pt \
    -tagged_fi /root/neural-template-gen/segs/original_segs/seg-wb-45-3-war.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' -min_gen_tokes 20 \
    > /root/neural-template-gen/segs/original_gens/gen-wb-45-3-war.txt
fi


# Deactivate ntg virtual environment
conda deactivate


exit 0
