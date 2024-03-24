from scipy.io import savemat
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
import os
from models.gentask import PainTaskGenerator
from models.genstim import genstim
from models.RNN import LSTM

basedir = os.getcwd()
task_params = {'stimulus_modality': 'Auditory',
               'stimulus_condition': 141,
               'onset_offset_noise': [(5, 1), (15, 1)],
               'stimulus_intensities': [(1, 1), (1, 4), (4, 4), (4, 1), (1, 1)],
               'epoch_onsets':    [0, 5, 11, 15, 21],
               'epoch_durations': [5, 6, 4, 6, 5],
               'trial_length': 26} # 0 - 25 sec

onestim = PainTaskGenerator(task_params).get_task()

input_seq, output_seq = onestim['input_seq'], onestim['output_seq']
# For checking...
# savemat(os.path.join(basedir, 'data', 'inputoutput_seq.mat'), {'input_seq':input_seq, 'output_seq': output_seq})



