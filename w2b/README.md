### Description
This directory contains a Bash script for executing all basic operations (dataset pre-processing, model training and text generation) with the TGen software.

Let's see what this script does and how it can be executed.

---

### Details & Guidelines

The basic script which performs the evaluation and is called by the Bash script with its respective model:
```console
usage: display_test_metrics.py [-h] [-e OUTPUT_PATH] [-t] [-f TABLE_FORMAT]
                               test_log_path

Display the BLEU-4 and ROUGE-4 with and without copy for the model by Liu et
al. (2017) on the WikiBio test set

positional arguments:
  test_log_path         Directory path of the input test log file

optional arguments:
  -h, --help            show this help message and exit
  -e OUTPUT_PATH, --export OUTPUT_PATH
                        If given, the DataFrame is exported asa csv file to
                        the output path specified by the user
  -t, --table           Defaults to "False". If given, the DataFrameis
                        displayed as a table. If not given, the DataFrame is
                        displayed as a string
  -f TABLE_FORMAT, --format TABLE_FORMAT
                        Table format (see tablefmt in tabulate documention) to
                        be displayed only if user has chosen to display table.
                        Defaults to "psql"
```


The basic script which chooses the best model and is called by the Bash script with its respective model:
```console
usage: select_best_model.py [-h] [-m METRIC] [-no_copy]
                            train_log_path model_path save_path

Display the average metrics and their corresponding standard deviation for
the WikiBio dataset

positional arguments:
  train_log_path        Directory path of the input train log file
  model_path            Directory path of the re-trained model.
  save_path             Directory path to save the best model.

optional arguments:
  -h, --help            show this help message and exit
  -m METRIC, --metric METRIC
                        Defaults to "BLEU". The metric that will be used to
                        determine the best epoch of the model. Choose between
                        "BLEU" and "ROUGE".
  -no_copy              If used, the BLEU or ROUGE without copy will be used
                        to determine the best epoch. Defaults to "False"
```


Dataset pre-processing, model training and model testing / evaluation on a new custom wiki2bio model using the WikiBio dataset:
```console
usage: ./w2b.sh OPERATION MODEL METRIC TABULATE_FORMAT GPU

Arguments:

OPERATION
    Can take one of the following three string values: -preprocess -train -test
        -preprocess: Perform text pre-processing before training a new model
        -train: Train a custom new model
        -test: Perform model testing / evaluation using a trained model

MODEL
    To be used only when testing / evaluating a model.
    Can take one of the following two string values: new best
        new: Perform testing / evaluating of a custom new model
        best: Perform testing / evaluating of the custom model with the best score

METRIC
    To be used only when testing / evaluating a model.
    Can take one of the following two string values: BLEU ROUGE
        BLEU: measures precision / how much the words (and/or n-grams) in the machine generated summaries appeared in the human reference summaries
        ROUGE: measures recall / how much the words (and/or n-grams) in the human reference summaries appeared in the machine generated summaries

TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by python-tabulate.
        Default: psql

GPU
    Optional argument, which can take the following string value: -gpu
        If provided, use an available Nvidia GPU for the selected operation
        If not provided, perform the selected operation on the CPU
```
