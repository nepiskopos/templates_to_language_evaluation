#!/bin/bash


# Usage: ./tgen.sh -train [or -gen] [or -preprocess]


# Load bashrc
source /root/.bashrc


# Check the corectness of the provided command-line arguments
if [[ $1 != -train && $1 != -gen && $1 != -preprocess ]]; then
    echo 'Usage: ./tgen.sh -train [or -gen] [or -preprocess]'
    
    exit 1
fi


# Activate tgen conda virtual environment
source /root/miniconda3/etc/profile.d/conda.sh
conda activate tgen


if [[ $1 == -preprocess ]]; then
    # Remove previous pre-processed dataset and outputs
    find /root/tgen/e2e-challenge/input/ -type f -name '*.txt' -delete
    
    # Convert the E2E dataset into a format used by TGen
    python3 /root/tgen/e2e-challenge/input/convert.py -a name,near -n /root/original-datasets/e2e-dataset/trainset.csv train
    python3 /root/tgen/e2e-challenge/input/convert.py -a name,near -n -m /root/original-datasets/e2e-dataset/devset.csv valid
    python3 /root/tgen/e2e-challenge/input/convert.py -a name,near -n -m /root/original-datasets/e2e-dataset/testset_w_refs.csv test
elif [[ $1 == -train ]]; then    
    # Train TGen on the training set
    python3 /root/tgen/run_tgen.py seq2seq_train /root/tgen/e2e-challenge/config/config.yaml \
    /root/tgen/e2e-challenge/input/train-das.txt /root/tgen/e2e-challenge/input/train-text.txt \
    /root/tgen/e2e-challenge/model/model.pickle.gz
elif [[ $1 == -gen ]]; then
    # Remove previous pre-processed dataset and outputs
    find /root/tgen/e2e-challenge/output/ -type f -name '*.txt' -delete
    
    # Generate outputs on the validation set
    python3 /root/tgen/run_tgen.py seq2seq_gen -w /root/tgen/e2e-challenge/output/e2e-valid-outputs.txt -a /root/tgen/e2e-challenge/input/valid-abst.txt \
    /root/tgen/e2e-challenge/model/model.pickle.gz /root/tgen/e2e-challenge/input/valid-das.txt

    # Generate outputs on the test set
    python3 /root/tgen/run_tgen.py seq2seq_gen -w /root/tgen/e2e-challenge/output/e2e-test-outputs.txt -a /root/tgen/e2e-challenge/input/test-abst.txt \
    /root/tgen/e2e-challenge/model/model.pickle.gz /root/tgen/e2e-challenge/input/test-das.txt
    
    # Postprocess the outputs
    python3 /root/tgen/e2e-challenge/postprocess/postprocess.py /root/tgen/e2e-challenge/output/e2e-valid-outputs.txt \
    /root/tgen/e2e-challenge/output/e2e-valid-outputs-postprocessed.txt
    python3 /root/tgen/e2e-challenge/postprocess/postprocess.py /root/tgen/e2e-challenge/output/e2e-test-outputs.txt \
    /root/tgen/e2e-challenge/output/e2e-test-outputs-postprocessed.txt
fi


# Deactivate tgen conda virtual environment
conda deactivate


exit 0
