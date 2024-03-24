import torch
import torch.nn as nn
import torch.optim as optim
from models.gentask import PainTaskGenerator
from models.genstim import genstim
from models.RNN import LSTM


batch_size = 18
num_epochs = 1800
learning_rate = 0.001
trial_length = 26
input_dim  = 3
output_dim  = 3
hidden_dim = 8
device = 'cpu'
model = LSTM(input_dim, hidden_dim, output_dim).to(device)
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=learning_rate)
loss_history = []


for epoch in range(num_epochs):
    inputs = torch.zeros((batch_size, trial_length, input_dim))
    outputs = torch.zeros((batch_size, trial_length, output_dim))
    for i in range(batch_size):
        oneparam = genstim(i)
        task_params = {'stimulus_modality': oneparam['int_modality'],
                    'stimulus_condition': oneparam['int_cond'],
                    'onset_offset_noise': oneparam['int_onoffnoise'],
                    'stimulus_intensities': oneparam['int_intensities'],
                    'epoch_onsets':    [0, 5, 11, 15, 21],
                    'epoch_durations': [5, 6, 4, 6, 5],
                    'trial_length': 26} # 0 - 25 sec
        onestim = PainTaskGenerator(task_params).get_task()
        inputs[i], outputs[i] = torch.tensor(onestim['input_seq'].T), torch.tensor(onestim['output_seq'].T)

    inputs.to(device)
    outputs.to(device)

    optimizer.zero_grad()
    outputs = model(inputs)
    loss = criterion(outputs, outputs)
    loss.backward()
    optimizer.step()
    loss_history.append(loss.item())

    if epoch % 100 == 0:
        print (f'Training epoch ({epoch+1}/{num_epochs}), Loss: {loss.item():3.3f}')
