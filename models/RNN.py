import torch
import torch.nn as nn
import torch.optim as optim
device = 'cpu'

class LSTM(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(LSTM, self).__init__()
        self.hidden_dim = hidden_dim
        self.lstm_layer = nn.LSTM(input_dim, hidden_dim, batch_first=True)
        self.fc_layer = nn.Linear(hidden_dim, output_dim)

    def forward(self, x):
        h0 = torch.zeros(1, x.size(0), self.hidden_dim).to(device)
        c0 = torch.zeros(1, x.size(0), self.hidden_dim).to(device)

        output, _ = self.lstm_layer(x, (h0, c0))
        output = self.fc_layer(output)
        return output
