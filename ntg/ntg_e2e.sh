#!/bin/bash


# Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -train && $1 != -seg && $1 != -gen ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]'
    
    exit 1
elif [[ $2 != -decayed ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]'

    exit 1
elif [[ $3 != 0 && $3 != 1 ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]'

    exit 1
elif [[ $4 != -nar && $4 != -far ]]; then
    echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]'

    exit 1
elif [ ! -z "$5" ]; then
    if [[ $5 != -cuda ]]; then
        echo 'Usage: ./ntg_e2e.sh -train [or -seg] [or -gen] -decayed 1 [or 0] -nar [or -far] [-cuda]'

        exit 1
    fi
fi


# Activate ntg conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh

# If -cuda is provided, activate ntg_gpu environment
# otherwise, activate ntg_cpu environment
if [ -z "$5" ]; then
    conda activate ntg_cpu
else
    nvidia-smi
    conda activate ntg_gpu
fi


if [[ $1 == -train ]]; then
    # Model Training
    
    if [[ $4 == -nar ]]; then
        # Train the non-autoregressive model using the E2E data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 \
        -mlpinp -onmt_decay $5 -seed 1818 -save /root/neural-template-gen/models/e2e-55-5-new.pt
    elif [[ $4 == -far ]]; then
        # Train the autoregressive model using the E2E data
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 \
        -mlpinp -onmt_decay $5 -seed 1111 -save /root/neural-template-gen/models/e2e-60-1-far-new.pt -ar_after_decay
    fi
elif [[ $1 == -seg ]]; then
    # Viterbi Segmentation/Template Extraction
    
    if [[ $4 == -nar ]]; then
        # Run the segmentation for the non-autoregressive E2E model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 55 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 5 \
        -mlpinp -onmt_decay $5 -load /root/neural-template-gen/models/e2e-55-5-new.pt.$3 -label_train | \
        tee /root/neural-template-gen/segs/seg-e2e-55-5-new-dec$3.txt
    elif [[ $4 == -far ]]; then
        # Run the segmentation for the autoregressive E2E model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -K 60 -L 4 \
        -log_interval 200 -thresh 9 -emb_drop -bsz 10 -max_seqlen 55 -lr 0.5 -sep_attn -max_pool -unif_lenps -one_rnn -Kmul 1 \
        -mlpinp -onmt_decay $5 -load /root/neural-template-gen/models/e2e-60-1-far-new.pt.$3 -label_train \
        -ar_after_decay | tee /root/neural-template-gen/segs/seg-e2e-60-1-far-new-dec$3.txt
    fi
elif [[ $1 == -gen ]]; then
    # Text Generation

    if [[ $4 == -nar ]]; then
        # Generate on the E2E validation set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 55 -L 4 \
        -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/e2e-55-5-new.pt.$3 \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-55-5-new-dec$3.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' $5 -min_gen_tokes 0 \
        > /root/neural-template-gen/gens/gen-e2e-55-5-valid-dec$3.txt

        # Generate on the E2E test set using the non-autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 55 -L 4 \
        -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_test.txt -load /root/neural-template-gen/models/e2e-55-5-new.pt.$3 \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-55-5-new-dec$3.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' $5 -min_gen_tokes 0 \
        > /root/neural-template-gen/gens/gen-e2e-55-5-test-dec$3.txt
        
        # Postprocess the outputs
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-55-5-valid-dec$4.txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-valid-dec$4-postprocessed.txt
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-55-5-test-dec$4.txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-55-5-test-dec$4-postprocessed.txt
    elif [[ $4 == -far ]]; then
        # Generate on the E2E validation set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 60 -L 4 \
        -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_uniq_valid.txt -load /root/neural-template-gen/models/e2e-60-1-far-new.pt.$3 \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-60-1-far-new-dec$3.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' $5 -min_gen_tokes 0 \
        > /root/neural-template-gen/gens/gen-e2e-60-1-far-valid-dec$3.txt

        # Generate on the E2E test set using the autoregressive model
        python2 /root/neural-template-gen/chsmm.py -data /root/neural-template-gen/data/e2e_aligned/ -emb_size 300 -hid_size 300 -layers 1 -dropout 0.3 -K 60 -L 4 \
        -log_interval 100 -thresh 9 -lr 0.5 -sep_attn -unif_lenps -emb_drop -mlpinp -onmt_decay -one_rnn -max_pool \
        -gen_from_fi /root/neural-template-gen/data/e2e_aligned/src_test.txt -load /root/neural-template-gen/models/e2e-60-1-far-new.pt.$3 \
        -tagged_fi /root/neural-template-gen/segs/seg-e2e-60-1-far-new-dec$3.txt -beamsz 5 -ntemplates 100 -gen_wts '1,1' $5 -min_gen_tokes 0 \
        > /root/neural-template-gen/gens/gen-e2e-60-1-far-test-dec$3.txt

        # Postprocess the outputs
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-60-1-far-valid-dec$3.txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-far-valid-dec$3-postprocessed.txt
        python2 /root/neural-template-gen/gens/postprocess_gens_e2e.py /root/neural-template-gen/gens/gen-e2e-60-1-far-test-dec$3.txt \
        /root/neural-template-gen/gens_postprocessed/gen-e2e-60-1-far-test-dec$3-postprocessed.txt
    fi
fi


# Deactivate ntg conda virtual environment
conda deactivate


exit 0
