### Description
This directory contains some Bash and Python scripts for executing all basic operations (model training, viterbi segmentation and text generation) with the neural-template-gen software.

Let's see what these scripts do and how they can be executed.

---

### Details & Guidelines

The basic script which performs generated text post-processing and is called from every Bash script with its respective model:
```console
usage: postprocess_gens_e2e.py [-h] input_file [output_file]

Post-process NTG files for E2E challenge

positional arguments:
  input_file   input file (and output file, if in-place)
  output_file  output file (if not in-place)

optional arguments:
  -h, --help   show this help message and exit
```


Text generation with the E2E dataset using the original neural-template-gen models (as provided by the software authors):
```console
usage: ./ntg_e2e_original.sh AUTOREGRESSION GPU

Arguments:

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

GPU
    Optional argument, which can take the following string value: -gpu
        If provided, use an available Nvidia GPU for text generation
        If not provided, perform the text generation on the CPU
```


Text generation with the WikiBio dataset using the original neural-template-gen models (as provided by the software authors):
```console
usage: ./ntg_wb_original.sh.sh AUTOREGRESSION GPU

Arguments:

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

GPU
    Optional argument, which can take the following string value: -gpu
        If provided, use an available Nvidia GPU for text generation
        If not provided, perform the text generation on the CPU
```


Model training, viterbi segmentation and text generation on a new custom neural-template-gen model using the E2E dataset:
```console
usage: ./ntg_e2e.sh OPERATION AUTOREGRESSION DECAY GPU

Arguments:

OPERATION
    Can take one of the following three string values: -train -seg -gen
        -train: Train a new model
        -seg: Perform viterbi segmentation using a trained model
        -gen: Perform text generation using a trained model

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

DECAY
    Optional argument, which can take the following string value: -decay
        If provided, evaluate the model with decaying learning rate
        If not provided, evalutate the model with non-decaying learning rate

GPU
    Optional argument, which can take the following string value: -gpu
        If provided, use an available Nvidia GPU for the selected operation
        If not provided, perform the selected operation on the CPU
```


Model training, viterbi segmentation and text generation on a new custom neural-template-gen model using the WikiBio dataset:
```console
usage: ./ntg_wb.sh OPERATION AUTOREGRESSION DECAY GPU

Arguments:

OPERATION
    Can take one of the following three string values: -train -seg -gen
        -train: Train a new model
        -seg: Perform viterbi segmentation using a trained model
        -gen: Perform text generation using a trained model

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

DECAY
    Optional argument, which can take the following string value: -decay
        If provided, evaluate the model with decaying learning rate
        If not provided, evalutate the model with non-decaying learning rate

GPU
    Optional argument, which can take the following string value: -gpu
        If provided, use an available Nvidia GPU for the selected operation
        If not provided, perform the selected operation on the CPU
```
