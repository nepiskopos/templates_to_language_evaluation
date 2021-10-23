#!/usr/bin/env python2


import argparse
import pandas as pd
import subprocess
import re


def select_best_model(train_log_path, model_path, save_path,
                      metric='BLEU', no_copy=False):
    
    # No matter how many epochs does the user let the model be trained,
    # this script will only look at the first 100 epochs (or less than that)
    epochs = range(1, 101)
    
    df = pd.DataFrame(index=epochs,
                      columns=['loss', 'time_mins', 
                               'BLEU_copy', 'BLEU_no_copy',
                               'ROUGE4_F_copy', 'ROUGE4_F_no_copy'
                               ])
    
    # Store log in a buffer
    with open(train_log_path) as text:
        lines = text.readlines()
    
    idx = 0
    for i in range(1, len(lines)):
        if "#######################################################" in lines[i]:
            idx = i
            break
    
    # Delete the first lines from the log, since they are useless for the evaluation
    del lines[:idx+1]

    # Extract useful info from log
    for line in lines:
        if re.findall(r'.{1,3} : ', line):
            i = int(line.split(' : ', 1)[0])
        if re.findall(r'loss = ', line):
            line_components = re.split(r'= |,| \n', line)
            df.loss.loc[i] = line_components[1]
            df.time_mins.loc[i] = line_components[3]
        if re.findall(r'with copy', line):
            splitted = re.split(r': |\n', line)
            df.BLEU_copy.loc[i] = splitted[4]
            df.ROUGE4_F_copy.loc[i] = re.split(r', |]', splitted[1])[3]
        if re.findall(r'without copy', line):
            splitted = re.split(r': |\n', line)
            df.BLEU_no_copy.loc[i] = splitted[4]
            df.ROUGE4_F_no_copy.loc[i] = re.split(r', |]', splitted[1])[3]
    
    # Format columns of df for easier inspection
    df = df.astype('float64')
    df.time_mins = df.time_mins / 60
    df.BLEU_copy = df.BLEU_copy * 100
    df.BLEU_no_copy = df.BLEU_no_copy * 100
    df.ROUGE4_F_copy = df.ROUGE4_F_copy * 100
    df.ROUGE4_F_no_copy = df.ROUGE4_F_no_copy * 100
    
    # Find total time of execution for WikiBio in hours
    exec_time = df.time_mins.sum() / 60
    
    try:
        if metric == 'BLEU':
            if no_copy:
                # Find epoch with max BLEU score and its value
                epoch_best = df.BLEU_no_copy.idxmax()
                metric_best = df.BLEU_no_copy.max()
            else:
                # Find epoch with max BLEU (with copy) score and its value
                epoch_best = df.BLEU_copy.idxmax()
                metric_best = df.BLEU_copy.max()
        elif metric == 'ROUGE':
            if no_copy:
                # Find epoch with max BLEU score and its value
                epoch_best = df.ROUGE4_F_no_copy.idxmax()
                metric_best = df.ROUGE4_F_no_copy.max()
            else:
                # Find epoch with max BLEU score and its value
                epoch_best = df.ROUGE4_F_copy.idxmax()
                metric_best = df.ROUGE4_F_copy.max()
    except:
        print 'Please choose a valid metric: "BLEU" or "ROUGE".'
    else:
        print '''The training process took {:0.2f} hours and the 
                 best model based on {} is that of epoch {} 
                 with a value of {:0.4f}.''' \
                 .format(exec_time, metric, epoch_best, metric_best)
    
    # Get the path of the epoch with the best metric
    best_model_path = model_path + '/loads/' + str(epoch_best)
    
    # Copy log to the path used by the testing process
    bash_command = 'cp -r {}/log.txt {}'.format(model_path, save_path)
    
    process = subprocess.Popen(bash_command.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    
    # Copy best model to the path used by the testing process
    bash_command = 'cp -r {}/. {}'.format(best_model_path, save_path)
    
    process = subprocess.Popen(bash_command.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()


if __name__=='__main__':
    parser = argparse.ArgumentParser(
        description='Display the average metrics and their corresponding' \
                    'standard deviation of for the E2E challenge'
    )
    
    parser.add_argument('train_log_path', type=str, action='store',
                        help='Directory path of the input train log file')
    parser.add_argument('model_path', type=str, action='store',
                        help='Directory path of the re-trained model.')
    parser.add_argument('save_path', type=str, action='store',
                        help='Directory path to save the best model.')
    parser.add_argument('-m', '--metric', type=str, default='BLEU',
                        help='Defaults to "BLEU". The metric that will be ' +
                        'used to determine the best epoch of the model. Choose ' +
                        'between "BLEU" and "ROUGE".')
    parser.add_argument('-no_copy', action='store_true', default=False,
                        help='If used, the BLEU or ROUGE without copy will ' +
                        'be used to determine the best epoch. Defaults to "False"')
    args = parser.parse_args()
    
    
    select_best_model(args.train_log_path, args.model_path, 
                      args.save_path, args.metric, args.no_copy)
