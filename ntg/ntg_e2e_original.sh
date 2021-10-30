#!/bin/bash


# Usage: ./ntg_e2e_original.sh -nar [or -war] [-cuda]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -nar && $1 != -war ]]; then
    echo 'Usage: ./ntg_e2e_original.sh -nar [or -war] [-cuda]'

    exit 1
elif [[ ! -z "$2" ]]; then
    if [[ $2 != -cuda ]]; then
        echo 'Usage: ./ntg_e2e_original.sh -nar [or -war] [-cuda]'

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


# Text Generation
if [[ $1 == -nar ]]; then
    # Generate on the E2E validation set using the non-autoregressive model
    python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 55 -L 4 \
    -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
    -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/original_models/e2e-55-5.pt \
    -tagged_fi /root/neural-template-gen/segs/original_segs/seg-e2e-55-5.txt \
    -beamsz 5 -ntemplates 100 -gen_wts '1,1' $2 -min_gen_tokes 0 > /root/neural-template-gen/gens/original_gens/gen-e2e-55-5.txt
    
    # Postprocess the outputs
    python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/original_gens/gen-e2e-55-5.txt \
    /root/neural-template-gen/gens_postprocessed/original_gens/gen-e2e-55-5-postprocessed.txt
elif [[ $1 == -war ]]; then
    # Generate on the E2E validation set using the autoregressive model
    python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 60 -L 4 \
    -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
    -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/original_models/e2e-60-1-far.pt \
    -tagged_fi /root/neural-template-gen/segs/original_segs/seg-e2e-60-1-far.txt \
    -beamsz 5 -ntemplates 100 -gen_wts '1,1' $2 -min_gen_tokes 0 > /root/neural-template-gen/gens/original_gens/gen-e2e-60-1-far.txt

    # Postprocess the outputs
    python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/original_gens/gen-e2e-60-1-far.txt \
    /root/neural-template-gen/gens_postprocessed/original_gens/gen-e2e-60-1-far-postprocessed.txt
fi


# Deactivate ntg conda virtual environment
conda deactivate


exit 0
