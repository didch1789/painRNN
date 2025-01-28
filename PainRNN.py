# Imports
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import numpy as np
import os
import scipy.io as sio
import matplotlib.pyplot as plt


class PainRNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size, alpha, actfunc, device):
        super().__init__()
        self.input_size  = input_size
        self.hidden_size = hidden_size
        self.output_size = output_size
        self.alpha       = alpha # [0, 1] balances the effect of the input and hidden.
                                 # having it as one is just same with vanila RNN
        self.actfunc     = actfunc
        self.i2h         = nn.Linear(input_size, hidden_size)
        self.h2h         = nn.Linear(hidden_size, hidden_size)
        self.h2o         = nn.Linear(hidden_size, output_size)
        self.device      = device
        
    def forward(self, input, init_hidden=None):
        hidden_units  = []
        output_units  = []
        seq_len       = input.size(1) # sequence length
        
        for i in range(seq_len):
             if (i == 0) and (init_hidden is None):
                 # h_t = torch.randn(input.size(0), self.hidden_size)
                 h_t = torch.zeros(input.size(0), self.hidden_size)
             elif (i == 0) and (init_hidden is not None):
                 h_t = init_hidden
             else:
                 h_t = hidden_unit
                 
             h_t           = h_t.to(self.device)    
             x_t           = input[:, i, :]
             if self.actfunc == 'relu':
                hidden_unit   = torch.relu(self.i2h(x_t) + self.h2h(h_t))
             elif self.actfunc == 'tanh':
                hidden_unit   = torch.tanh(self.i2h(x_t) + self.h2h(h_t))
             hidden_unit   = h_t * (1 - self.alpha) + hidden_unit * self.alpha
             output_unit   = self.h2o(hidden_unit)
            
             hidden_units.append(hidden_unit)
             output_units.append(output_unit)
        
        hidden_units = torch.stack(hidden_units, dim = 1)
        output_units = torch.stack(output_units, dim = 1)
        return output_units, hidden_units
    
    def forward_silence_unit(self, input, init_hidden=None, silent_unit=None): # Let's see from here!!
        hidden_units = []
        output_units = []
        seq_len = input.size(1)  # sequence length

        for i in range(seq_len):
            if (i == 0) and (init_hidden is None):
                h_t = torch.zeros(input.size(0), self.hidden_size).to(self.device)
            elif (i == 0) and (init_hidden is not None):
                h_t = init_hidden
            else:
                h_t = hidden_unit

            x_t = input[:, i, :]
            if self.actfunc == 'relu':
                hidden_unit = torch.relu(self.i2h(x_t) + self.h2h(h_t))
            elif self.actfunc == 'tanh':
                hidden_unit = torch.tanh(self.i2h(x_t) + self.h2h(h_t))

            hidden_unit = h_t * (1 - self.alpha) + hidden_unit * self.alpha

            # Silence specific hidden unit
            if silent_unit is not None:
                hidden_unit[:, silent_unit] = 0

            output_unit = self.h2o(hidden_unit)
            hidden_units.append(hidden_unit)
            output_units.append(output_unit)

        hidden_units = torch.stack(hidden_units, dim=1)
        output_units = torch.stack(output_units, dim=1)
        return output_units, hidden_units