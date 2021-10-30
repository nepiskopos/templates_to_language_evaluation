#!/usr/bin/env python3

import argparse
import pandas as pd
from tabulate import tabulate


def display_metrics(tsv_path, output_path='', table=True, table_format='psql'):
    """
    Display the mean and standard deviation of each metric for 
    the tsv file given by the user. The user can choose how
    the metrics are displayed (table or string), as well as
    the table format (see https://pypi.org/project/tabulate/) 
    """

    # Load and preprocess the tsv file with the scores
    df = pd.read_csv(tsv_path, sep='\t', header=0)
    df.drop('src', axis=1, inplace=True)

    # Calculate the mean and standard deviation for each metric
    mean_metrics = df.mean()
    stdev_metrics = df.std()

    # Format the metrics to the style of Wiseman et al. (2018)
    mean_metrics = format_metrics(mean_metrics)
    stdev_metrics = format_metrics(stdev_metrics)

    # Create a DataFrame which is used to display the above
    display = pd.DataFrame(data=[mean_metrics, stdev_metrics],
                           columns=mean_metrics.index,
                           index=['Average', 'Standard Deviation'])
                           
    # Optionally, export display DataFrame as a csv file to the output path
    if output_path != '':
        display.to_csv(output_path, sep='\t')
                       
    if table:
        print(tabulate(display.round(3), headers='keys', tablefmt=table_format))
    else:
        print(display.round(3).to_string())


def format_metrics(metrics):
    """
    Format the metrics in a way which corresponds to 
    Wiseman et al. (2018), i.e. 'Learning Neural Templates for Text Generation' 
    """
    
    metrics.BLEU = metrics.BLEU * 100
    metrics.sentBLEU = metrics.sentBLEU * 100
    metrics.METEOR = metrics.METEOR * 100
    metrics.ROUGE_L = metrics.ROUGE_L * 100
    
    return metrics


if __name__=='__main__':
    parser = argparse.ArgumentParser(
    description='Display the average metrics and their corresponding' \
                'standard deviation of for the E2E challenge'
    )

    parser.add_argument('tsv_path', type=str, action='store',
                        help='Directory path of the input tsv file')
    parser.add_argument('-e', '--export', type=str, action='store', 
                        dest='output_path', default='',
                        help='If given, the DataFrame is exported as' +
                        'a csv file to the output path specified by the user')                    
    parser.add_argument('-t', '--table', action='store_true', default=False,
                        help='Defaults to "False". If given, the DataFrame' +
                        'is displayed as a table. If not given, the ' +
                        'DataFrame is displayed as a string')
    parser.add_argument('-f', '--format', action='store', dest='table_format', 
                        default='psql', help='Table format (see tablefmt in ' +
                        'tabulate documention) to be displayed only if user has ' + 
                        'chosen to display table. Defaults to "psql"')
    args = parser.parse_args()


    display_metrics(args.tsv_path, args.output_path, args.table, args.table_format)
