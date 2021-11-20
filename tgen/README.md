### Description
This directory contains a Bash script for executing all basic operations (dataset pre-processing, model training and text generation) with the TGen software.

Let's see what this script does and how it can be executed.

---

### Details & Guidelines

Dataset pre-processing, model training and text generation on a new custom TGen model using the E2E dataset:
```console
usage: ./tgen.sh OPERATION

Arguments:

OPERATION
    Can take one of the following three string values: -preprocess -train -gen
        -preprocess: Perform text pre-processing before training a new model
        -train: Train a new model
        -gen: Perform text generation using a trained model
```
