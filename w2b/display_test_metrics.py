#!/usr/bin/env python2

import argparse
import pandas as pd
import re
from tabulate import tabulate


def display_test_metrics(test_log_path, output_path='', 
                         table=True, table_format='psql'):
    """
    Display the BLEU-4 and the F-Measure of the ROUGE-4
    for the input test log file given by the user, which is
    generated on the test set of the WikiBio dataset by
    the model of Liu et al. (2017). The user can choose how
    the metrics are displayed (table or string), as well as
    the table format (see https://pypi.org/project/tabulate/)
    """
    
    # Read the text file and get the number of its lines
    with open(test_log_path) as text:
        lines = text.readlines()
    
    idx = 0
    for i in range(0, len(lines)):
        if "with" in lines[i]:
            idx = i
            break
    
    # Delete the first lines from the log, since they are useless for the evaluation
    del lines[:idx]
    
    # Initialize metrics to zero
    BLEU_copy = .0
    BLEU_no_copy = .0
    ROUGE4_F_copy = .0
    ROUGE4_F_no_copy = .0
    
    # Read the text file line by line so as to extract the metrics
    with open(test_log_path) as text:
        for line in lines:
            # Get the BLEU and ROUGE-4 with copy 
            if re.findall(r'with copy', line):
                splitted = re.split(r': |\n', line)
                BLEU_copy = float(splitted[4])
                ROUGE4_F_copy = float(re.split(r', |]', splitted[1])[3])

            #Get the BLEU and ROUGE-4 without copy 
            if re.findall(r'without copy', line):
                splitted = re.split(r': |\n', line)
                BLEU_no_copy = float(splitted[4])
                ROUGE4_F_no_copy = float(re.split(r', |]', splitted[1])[3])
    
    # Create a DataFrame which is used to display the above    
    display = pd.DataFrame(columns=['BLEU-4', 'ROUGE-4'],
                       index=['With Copy', 'Without Copy'])
    
    # Format BLEU-4 and append it in the DataFrame
    display['BLEU-4'].iloc[0] = BLEU_copy * 100
    display['BLEU-4'].iloc[1] = BLEU_no_copy * 100

    # Format ROUGE-4 and append it in the DataFrame
    display['ROUGE-4'].iloc[0] = ROUGE4_F_copy * 100
    display['ROUGE-4'].iloc[1] = ROUGE4_F_no_copy * 100
    
    # Optionally, export display DataFrame as a csv file to the output path
    if output_path != '':
        display.to_csv(output_path, sep='\t')
                       
    if table:
        print(tabulate(display.round(3), headers='keys', tablefmt=table_format))
    else:
        print(display.round(3).to_string())


if __name__=='__main__':
    parser = argparse.ArgumentParser(
    description='Display the BLEU-4 and ROUGE-4 with and without copy' \
                'for the model by Liu et al. (2017) on the WikiBio test set'
    )
    
    parser.add_argument('test_log_path', type=str, action='store',
                        help='Directory path of the input test log file')
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
    
    
    display_test_metrics(args.test_log_path, args.output_path, 
                         args.table, args.table_format)
