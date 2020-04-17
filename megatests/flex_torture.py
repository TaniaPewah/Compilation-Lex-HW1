#!/usr/bin/python3

try:
    from tqdm import trange
except ImportError:
    trange = range

import random
import subprocess
import os
from pathlib import Path
import pickle
import glob

import argparse


def chunk_lines(lst, n):
    text = ''
    for i in range(0, len(lst), n):
        text += ' '.join(lst[i:i + n]) + '\n'
    return text


def test_validate(testname: str, results1: str, results2: str):
    if (results1 == results2):
        print(f'{testname}: pass')
    else:
        print(f'{testname}: fail')

def log_and_exit(input, o1, o2):
    print('Input:')
    print(input)
    print('Got:')
    print(o1)
    print('Expected:')
    print(o2)
    exit(0)


parser = argparse.ArgumentParser(description='Run the test suite.')

parser.add_argument('-l', '--log', action='store_true', help="Print the first differing file and exit")
args = parser.parse_args()


chk1 = subprocess.check_output(['flex', 'hw1.lex'])
chk2 = subprocess.check_output(['gcc', '-ll', 'lex.yy.c'])
if chk1 != b'' or chk2 != b'':
    print('Compilation Error!')
    print('flex:', chk1)
    print('gcc: ', chk2)
    exit(1)

random.seed(12345)

NTESTS = 100
EXE = './a.out'
NTOKENTESTS = 1000
NTOKENS_IN_TEST = 1000

with open('output_dump.pickle', 'rb') as f:
    outputs_combined, inputs = pickle.load(f)

for filename in glob.glob('*.in'):
    filename = filename.split('.')[0]
    print(f'basing tests off of {filename}')

    with open(f'{filename}.in', 'rb') as f:
        sample = f.read()

    output = subprocess.check_output(EXE, input=sample, shell=True)

    with open(f'{filename}.out', 'rb') as f:
        output_check = f.read()

    test_validate("Basic check", output, output_check)
    if output != output_check:
        if args.log:
            log_and_exit(sample, output, output_check)

    print('Doing batch of line randomization')

    lines = sample.splitlines()

    outputs = outputs_combined[filename]

    passes = 0

    for i in trange(NTESTS):
        random.shuffle(lines)
        test_input = inputs[filename][i]

        output = subprocess.check_output(EXE, input=test_input, shell=True)
        if output != outputs[i]:
            print(f'Failed test: {filename} {i}')

            if args.log:
                log_and_exit(test_input, output, outputs[i])
        
        else:
            passes += 1

    print(f'Passed {passes} out of {NTESTS} tests')


token_outputs = outputs_combined['tokens']

with open('token_shuffle_base.in', 'rb') as f:
    tok_tx = f.read()

tokens = tok_tx.split()
print('Doing Token tests')
passes = 0
for i in trange(NTOKENTESTS):
    test_input = inputs['tokens'][i]

    output = subprocess.check_output(EXE, input=test_input, shell=True)
    if output != token_outputs[i]:
        print(f'Failed token test #{i}')
        if args.log:
            log_and_exit(test_input, output, token_outputs[i])

    else:
        passes += 1

print(f'Passed {passes} out of {NTOKENTESTS} tests')
