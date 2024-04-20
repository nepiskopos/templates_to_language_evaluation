#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
Postprocessing NTG output / generated text for the E2E challenge
"""

from __future__ import unicode_literals
import codecs
from regex import Regex, UNICODE, IGNORECASE
import re
import sys
from argparse import ArgumentParser


class Detokenizer(object):
    """\
    A simple de-tokenizer class.
    """

    def __init__(self):
        """\
        Constructor (pre-compile all needed regexes).
        """
        # compile regexes
        self._currency_or_init_punct = Regex(r' ([\p{Sc}\(\[\{\¿\¡]+) ', flags=UNICODE)
        self._noprespace_punct = Regex(r' ([\,\.\?\!\:\;\\\%\}\]\)]+) ', flags=UNICODE)
        self._contract = Regex(r" (\p{Alpha}+) ' (ll|ve|re|[dsmt])(?= )", flags=UNICODE | IGNORECASE)
        self._dash_fixes = Regex(r" (\p{Alpha}+|£ [0-9]+) - (priced|star|friendly|(?:£ )?[0-9]+) ", flags=UNICODE | IGNORECASE)
        self._dash_fixes2 = Regex(r" (non) - ([\p{Alpha}-]+) ", flags=UNICODE | IGNORECASE)
        self._squotes1 = Regex(r" ` ", flags=UNICODE | IGNORECASE)
        self._squotes2 = Regex(r" ' ", flags=UNICODE | IGNORECASE)
        self._dquotes1 = Regex(r"`` `` ", flags=UNICODE | IGNORECASE)
        self._dquotes2 = Regex(r" '' ''", flags=UNICODE | IGNORECASE)
        self._quotes1 = Regex(r"`` ", flags=UNICODE | IGNORECASE)
        self._quotes2 = Regex(r" ''", flags=UNICODE | IGNORECASE)
        self._dlrb = Regex(r"-lrb- -lrb- ", flags=UNICODE | IGNORECASE)
        self._drrb = Regex(r" -rrb- -rrb-", flags=UNICODE | IGNORECASE)
        self._lrb = Regex(r"-lrb- ", flags=UNICODE | IGNORECASE)
        self._rrb = Regex(r" -rrb-", flags=UNICODE | IGNORECASE)
        self._dashes = Regex(r"--", flags=UNICODE | IGNORECASE)

    def detokenize(self, text):
        """\
        Detokenize the given text.
        """
        text = ' ' + text + ' '
        text = self._dash_fixes.sub(r' \1-\2 ', text)
        text = self._dash_fixes2.sub(r' \1-\2 ', text)
        text = self._currency_or_init_punct.sub(r' \1', text)
        text = self._noprespace_punct.sub(r'\1 ', text)
        text = self._contract.sub(r" \1'\2", text)
        text = self._squotes1.sub(r' "', text)
        text = self._squotes2.sub(r'" ', text)
        text = self._dquotes1.sub(r'"', text)
        text = self._dquotes2.sub(r'"', text)
        text = self._quotes1.sub(r'"', text)
        text = self._quotes2.sub(r'"', text)
        text = self._dlrb.sub(r'(', text)
        text = self._drrb.sub(r')', text)
        text = self._lrb.sub(r'(', text)
        text = self._rrb.sub(r')', text)
        text = self._dashes.sub(r'-', text)
        text = text.strip()
        # capitalize
        if not text:
            return ''
        text = text[0].upper() + text[1:]
        return text


def process_file(input_file_name, output_file_name):
    detok = Detokenizer()
    buf = []
    sep = ' *.\<eos\>\|\|\|*.|\|\|\|'
    
    with codecs.open(input_file_name, 'rb', 'UTF-8') as fh:
        lines = fh.readlines()
    del lines[0:6]
    
    with codecs.open(input_file_name, 'rb', 'UTF-8') as fh:
        for line in lines:
            buf.append(re.split(sep, line, 1)[0].strip())

    with codecs.open(output_file_name, 'wb', 'UTF-8') as fh:
        for line in buf:
            fh.write(detok.detokenize(line) + "\n")       


if __name__ == '__main__':
    parser = ArgumentParser(description='Post-process NTG generated output files for the WikiBio challenge')
    parser.add_argument('input_file', type=str, help='input file (and output file, if in-place)')
    parser.add_argument('output_file', type=str, nargs='?', help='output file (if not in-place)')
    args = parser.parse_args()

    process_file(args.input_file, args.output_file if args.output_file else args.input_file)
