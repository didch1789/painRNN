# 24.11.25
# Searching all possible hyperparam space.

# Imports
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import numpy as np
import os
import scipy.io as sio
import matplotlib.pyplot as plt
import PainRNN as PainRNN

param = dict()
param['level']      = ['condition_prob'] #  'trial', 'condition', 'condition_prob', 'threshold_mdl1'
param['activation'] = ['relu'] 
param['outputs']    = ['Actions', 'Ratings', 'Clicks2'] # 'Actions', 'Clicks', , 'Both_MSE'
param['alphas']     = np.linspace(0, 1, 101)
param['alphas']     = param['alphas'][1:]
n_alphas            = len(param['alphas'])

# Clicks. CE 
# Ratings. MSE
# Both (Ratings + Clicks). MSE + CE or MSE
# Actions (Ratings + Click1 + Click2; Click1 - Click2 for deciding actions indicated as 0 or 1 for pain). MSE + CE or MSE 

# FIXED PARAMS
input_size    = 1   # Input feature size (objective temperature)
hidden_size   = 30  # Number of features in the hidden state
noise_sig     = 1e-1
learning_rate = 1e-3 
n_epochs      = 5000
device        = 'cuda' # mps
results_name  = f'results_hdsz{hidden_size}_nepch{n_epochs}'
# batch_size  = 50 for trial-level 9 for condition-level

# Seed random number generator for reproducibility
torch.manual_seed(0)
np.random.seed(0)

# Training models for every search space
for i_lvl, name_lvl in  enumerate(param['level']):
    for i_act, name_act in enumerate(param['activation']):
        for i_out, name_out in enumerate(param['outputs']):
            
            targfolder  = os.path.join(os.getcwd(), results_name, f'{name_lvl}_act-{name_act}_label-{name_out}')
            if not (os.path.isdir(targfolder)):
                os.makedirs(targfolder)
            
            # Specifying Inputs
            if name_lvl == 'trial':
                inputoutputs = sio.loadmat('InOutputs.mat')
                Inputs   = inputoutputs['Inputs']
                Outputs  = inputoutputs['Outputs']
                Xnp = []
                ynp = []
                for cond_i in range(len(Outputs)):
                    Xnp.append(np.tile(Inputs[cond_i, :], (Outputs[cond_i][0].shape[0], 1)))
                    ynp.append(Outputs[cond_i][0])
                Xnp = np.expand_dims(np.vstack(Xnp), axis=2)
                ynp = np.vstack(ynp)
                X = torch.from_numpy(Xnp).to(torch.float32)
                y = torch.from_numpy(ynp).to(torch.float32)
                batch_size = 50
                
            elif name_lvl == 'condition':
                inputoutputs = sio.loadmat('InOutputs_condavg.mat')
                Inputs   = inputoutputs['Inputs']
                Outputs  = inputoutputs['Outputs']
                Xnp      = np.expand_dims(Inputs, axis = 2)
                ynp      = []
                for cond_i in range(len(Outputs)):
                    ynp.append(Outputs[cond_i][0])
                ynp         = np.stack(ynp, axis = 0)
                X = torch.from_numpy(Xnp).to(torch.float32)
                y = torch.from_numpy(ynp).to(torch.float32)
                batch_size = 9
                
            elif name_lvl == 'threshold_mdl1':
                inputoutputs = sio.loadmat('model_v1_InOutputs_condavg.mat')
                Inputs   = inputoutputs['Inputs']
                Outputs  = inputoutputs['Outputs']
                Xnp      = np.expand_dims(Inputs, axis = 2)
                ynp      = []
                for cond_i in range(len(Outputs)):
                    ynp.append(Outputs[cond_i][0])
                ynp         = np.stack(ynp, axis = 0)
                X = torch.from_numpy(Xnp).to(torch.float32)
                y = torch.from_numpy(ynp).to(torch.float32)
                batch_size = 9
            
            elif name_lvl == 'condition_prob':
                inputoutputs = sio.loadmat('InOutputs_condavg_prob.mat')
                n_condsample = 100
                n_times      = inputoutputs['Inputs'].shape[1]
                Inputs       = inputoutputs['Inputs']
                Outputs      = inputoutputs['Outputs']
                Xnp          = np.empty(shape=(n_condsample * 9, n_times, 1))
                ynp          = np.empty(shape=(n_condsample * 9, n_times, 2))
                
                k = 0
                for cond_i in range(len(Outputs)):
                    input = Inputs[cond_i]
                    for sample_i in range(n_condsample):
                        clicks = np.zeros((n_times))
                        rating = Outputs[cond_i, 0]
                        click1 = round(np.random.normal(loc=Outputs[cond_i, 1][0][0], scale=Outputs[cond_i, 1][0][1]))
                        click2 = round(np.random.normal(loc=Outputs[cond_i, 1][0][2], scale=Outputs[cond_i, 1][0][3]))
                        if click1 > click2:
                            click2 = click1+1
                        if click2 > n_times:
                            click2 = n_times
                        clicks[click1:click2] = 1
                        Xnp[k, :, 0] = input
                        ynp[k, :, 0] = np.squeeze(rating)
                        ynp[k, :, 1] = clicks
                        k = k + 1

                X = torch.from_numpy(Xnp).to(torch.float32)
                y = torch.from_numpy(ynp).to(torch.float32)
                batch_size = 200

            # Combine inputs and outputs into a dataset
            dataset    = TensorDataset(X, y)
            dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
            
            if (name_out == 'Clicks') or (name_out == 'Ratings') :
                output_size = 1
            elif ('Both' in name_out) or (name_out == 'Clicks2'):
                output_size = 2
            elif name_out == 'Actions':
                output_size = 3
            
            # Model instantiation
            for i, alpha in enumerate(param['alphas']):
                addstr      = 'tau_%.4f' % alpha                
                loss_epochs = []
                pain_rnn    = PainRNN.PainRNN(input_size, hidden_size, output_size, alpha, name_act, device).to(device)
                optimizer   = optim.Adam(pain_rnn.parameters(), lr=learning_rate)
                criterion1  = nn.MSELoss()              # For intensity.
                criterion2  = nn.CrossEntropyLoss()     # For clicks. if required
                
                for epoch in range(n_epochs):
                    for inputs, targets in dataloader:
                        
                        add_noise  = np.random.normal(0, noise_sig, inputs.shape)
                        inputs    += torch.from_numpy(add_noise).to(torch.float32)
                        inputs     = inputs.to(device)
                        outputs, _ = pain_rnn(inputs)  
                        targets    = targets.to(device)
                        
                        if name_out == 'Ratings':  
                            targets      = torch.unsqueeze(targets[:, :, 0], dim=2)
                            outputs_flat = outputs.view(-1)
                            targets_flat = targets.view(-1)
                            loss         = criterion1(outputs_flat, targets_flat)
                            loss_name    = 'MSE'
                            
                        elif name_out == 'Clicks':
                            targets      = torch.unsqueeze(targets[:, :, 1], dim=2)
                            outputs_flat = outputs.view(-1)
                            targets_flat = targets.view(-1)
                            loss         = criterion2(outputs_flat, targets_flat)
                            loss_name    = 'CE'
                            
                        elif name_out == 'Clicks2':
                            outputs_flat = outputs.view(-1, 2)
                            targets_flat = targets[:, :, 1].view(-1)
                            loss         = criterion2(outputs_flat, targets_flat.long())
                            loss_name    = 'CE'
                            
                        elif name_out == 'Both_MSE':
                            outputs_flat = outputs.view(-1)
                            targets_flat = targets.view(-1)
                            loss         = criterion1(outputs_flat, targets_flat)
                            loss_name    = 'MSE'
                            
                        elif name_out == 'Both_MSE_CE':
                            outputs_flat = outputs[:, :, 0].view(-1)
                            targets_flat = targets[:, :, 0].view(-1)
                            loss1        = criterion1(outputs_flat, targets_flat)
                            outputs_flat = outputs[:, :, 1].view(-1)
                            targets_flat = targets[:, :, 1].view(-1)
                            loss2        = criterion2(outputs_flat, targets_flat)
                            loss         = loss1 + loss2
                            loss_name    = 'MSE_CE'
                            
                        elif name_out == 'Both_MSE_sigmoidCE':
                            outputs_flat = outputs[:, :, 0].view(-1)
                            targets_flat = targets[:, :, 0].view(-1)
                            loss1        = criterion1(outputs_flat, targets_flat)
                            outputs_flat = torch.sigmoid(outputs[:, :, 1].view(-1))
                            targets_flat = targets[:, :, 1].view(-1)
                            loss2        = criterion2(outputs_flat, targets_flat)
                            loss         = loss1 + loss2
                            loss_name    = 'MSE_sigmoidCE'
                            
                        elif name_out == 'Actions': # Does this also need sigmoid?
                            outputs_flat = outputs[:, :, 0].view(-1)
                            targets_flat = targets[:, :, 0].view(-1)
                            loss1        = criterion1(outputs_flat, targets_flat)
                            outputs_flat = outputs[:, :, 1:].view(-1, 2)
                            targets_flat = targets[:, :, 1].view(-1)
                            loss2        = criterion2(outputs_flat, targets_flat.long())
                            loss         = loss1 + loss2
                            loss_name    = 'Actions'
                            
                        optimizer.zero_grad()
                        loss.backward()
                        optimizer.step()
                        
                    loss_epochs.append(loss.item())
                    if ((epoch+1) % 10) == 0:
                        print(f'Epoch [{epoch+1}/{n_epochs}], Loss: {loss.item():.4f} in {i+1} of {n_alphas}')
            
                out_t, h_t = pain_rnn(torch.from_numpy(np.expand_dims(Inputs, axis = 2)).to(torch.float32))
                out_t      = out_t.detach().numpy()
                h_t        = h_t.detach().numpy()

                
                plt.rcParams.update({
                    'font.family': 'sans-serif',  # Use sans-serif fonts
                    'font.sans-serif': 'Helvetica',  # Specifically Helvetica
                    'font.size': 10  # Set font size to 10
                })
                fig, axes = plt.subplots(3, 3, figsize = (9, 9), constrained_layout = True)
                axes[0, 0].plot(Inputs.T)
                axes[0, 0].set_xlabel('time')
                axes[0, 0].set_ylabel('Input')
                axes[0, 0].spines['top'].set_visible(False)
                axes[0, 0].spines['right'].set_visible(False)
                for i in range(targets.shape[2]):
                    axes[0, i+1].plot(targets[:, :, i].T)
                    axes[0, i+1].set_xlabel('time')
                    axes[0, i+1].set_ylabel(f'e.g. Labels {name_out}')
                    axes[0, i+1].spines['top'].set_visible(False)
                    axes[0, i+1].spines['right'].set_visible(False)
                
                for i in range(output_size):
                    axes[1, i].plot(out_t[:, :, i].T)
                    axes[1, i].set_xlabel('time')
                    axes[1, i].set_ylabel('Outputs from the model')
                    axes[1, i].spines['top'].set_visible(False)
                    axes[1, i].spines['right'].set_visible(False)

                axes[2, 0].plot(loss_epochs)
                axes[2, 0].set_xlabel('Epochs')
                axes[2, 0].set_ylabel('Loss')
                axes[2, 0].spines['top'].set_visible(False)
                axes[2, 0].spines['right'].set_visible(False)

                axes[2, 1].plot(np.mean(h_t, 0))
                axes[2, 1].set_xlabel('time')
                axes[2, 1].set_ylabel(f'Hidden Units avg across {name_lvl}')
                axes[2, 1].spines['top'].set_visible(False)
                axes[2, 1].spines['right'].set_visible(False)
                
                    
                sio.savemat(os.path.join(targfolder, ('HiddenLayers_' + addstr + '.mat')), 
                                {'out_t': out_t, 'h_t': h_t, 'loss_epochs': loss_epochs, 
                                'i2h':pain_rnn.i2h.weight.detach().numpy(), 
                                'h2h':pain_rnn.h2h.weight.detach().numpy(), 
                                'h2o':pain_rnn.h2o.weight.detach().numpy(),
                                'Inputs': X, 'Targets': y})
                torch.save(pain_rnn, os.path.join(targfolder, f'pain_rnn_{addstr}.pth'))

                plt.savefig(os.path.join(targfolder, ('HiddenLayers_' + addstr + '.png')))
                print(('HiddenLayers_' + addstr + '.png' + 'saved'))
                plt.close()
    
