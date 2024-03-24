import torch
from torch.utils.data import Dataset
import numpy as np

class VisualDiscrimination(Dataset):
    def __init__(self, task_dict):
        self.target_dim = task_dict['target_dim'] # Red and Green
        self.color_dim = task_dict['color_dim']
        self.output_dim = task_dict['output_dim'] # Left and Right
        self.target_onset_range = task_dict['target_onset_range']
        self.decision_onset_range = task_dict['decision_onset_range']
        self.coherence_range = task_dict['coherence_range']
        self.trial_length = task_dict['trial_length']
        assert np.max(self.decision_onset_range) < self.trial_length

    def __getitem__(self, idx):
        target_onset = np.random.randint(self.target_onset_range[0], self.target_onset_range[1])
        decision_onset = np.random.randint(self.decision_onset_range[0], self.decision_onset_range[1])
        coherence = np.random.uniform(low=self.coherence_range[0], high=self.coherence_range[1])

        input_seq = np.zeros((self.trial_length, self.target_dim+self.color_dim))
        output_seq = np.zeros((self.trial_length, self.output_dim))
        checkerboard_color = np.sign(np.random.normal())          # -1(Red) or +1(Green)
        target_idx = np.random.randint(0, self.output_dim)      # 0(Red-Green) or 1(Green-Red)

        # Target cue
        input_seq[target_onset:, target_idx] = 1

        # Color checkerboard
        input_seq[:, self.target_dim:] = np.random.normal(loc=0, size=(self.trial_length, self.color_dim))
        input_seq[decision_onset:, self.target_dim:] = np.random.normal(loc=checkerboard_color*coherence,
                                                                       size=(self.trial_length-decision_onset, self.color_dim))

        # Desired output
        color_idx = 1 if checkerboard_color > 0 else 0         # (0: Red, 1: Green)
        output_direction = 0 if color_idx == target_idx else 1  # (0: Left, 1: Right)

        output_seq[decision_onset:, output_direction] = 1

        return {'input_seq': input_seq, 'output_seq': output_seq,
                'checkerboard_color': checkerboard_color, 'coherence': coherence,
                'target_idx': target_idx, 'output_direction': output_direction, 'decision_onset': decision_onset}