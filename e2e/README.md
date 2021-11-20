### Description
This directory contains some Bash and Python scripts for evaluating both neural-template-gen and TGen on the E2E dataset.

Let's see what these scripts do and how they can be executed.

---

### Details & Guidelines

The basic script which performs the evaluation and is called from every Bash script with its respective model:
```console
usage: display_scores.py [-h] [-e OUTPUT_PATH] [-t] [-f TABLE_FORMAT] tsv_path

Display the average metrics and their correspondingstandard deviation of for
the E2E challenge

positional arguments:
  tsv_path              Directory path of the input tsv file

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


Evaluation of the original neural-template-gen models (as provided by the software authors):
```console
./e2e_metrics_ntg_original.sh AUTOREGRESSION TABULATE_FORMAT

Arguments:

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by python-tabulate.
        Default: psql
```


Evaluation of a custom re-trained neural-template-gen model:
```console
./e2e_metrics_ntg.sh AUTOREGRESSION DECAY TABULATE_FORMAT

Arguments:

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

DECAY
    Optional argument, which can take the following string value: -decay
        If provided, evaluate the model with decaying learning rate
        If not provided, evalutate the model with non-decaying learning rate


TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by python-tabulate.
        Default: psql
```


Evaluation of a custom re-trained TGen model:
```console
./e2e_metrics_tgen.sh TABULATE_FORMAT

Arguments:

TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by python-tabulate.
        Default: psql
```
