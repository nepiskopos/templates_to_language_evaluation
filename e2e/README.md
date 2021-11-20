### Description
This directory contains some Bash and Python scripts for evaluating both neural-template-gen and TGen on the E2E dataset.

Let's see what these scripts do and how they can be executed.

---

### Details & Guidelines
Evaluation of the original neural-template-gen models (as provided by the software authors):
```console
./e2e_metrics_ntg_original.sh AUTOREGRESSION TABULATE_FORMAT

Arguments:

AUTOREGRESSION
    Can take one of the following two string values: -nar -war
        -nar: Evaluate the non-autoregressive model
        -war: Evaluate the autoregressive model

TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by [tabulate](https://pypi.org/project/tabulate/).
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
    Optional argument, which can take any string value that is acceptable by [tabulate](https://pypi.org/project/tabulate/).
        Default: psql
```


Evaluation of a custom re-trained TGen model:
```console
./e2e_metrics_tgen.sh TABULATE_FORMAT

Arguments:

TABULATE_FORMAT
    Optional argument, which can take any string value that is acceptable by [tabulate](https://pypi.org/project/tabulate/).
        Default: psql
```
