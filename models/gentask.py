import torch
from torch.utils.data import Dataset
import numpy as np

class PainTaskGenerator(Dataset):
    def __init__(self, task_dict):

        # INPUT DIMENSIONS
        self.stimulus_modality = task_dict['stimulus_modality'] # Auditory or Thermal
        self.stimulus_condition = task_dict['stimulus_condition'] 
        self.onset_offset_noise    = task_dict['onset_offset_noise'] # mean and std
        self.stimulus_intensities = task_dict['stimulus_intensities'] 

        # TIME SETTINGS
        self.epoch_onsets = task_dict['epoch_onsets']
        self.epoch_durations = task_dict['epoch_durations']
        self.trial_length = task_dict['trial_length']
        assert len(self.epoch_onsets) == len(self.epoch_durations)

    def get_task(self):
        # ITEMS TO RETURN
        n_epochs  = len(self.epoch_onsets)
        input_seq = np.zeros((3, self.trial_length))
        output_seq = np.zeros((3, self.trial_length))
        stim_modality = self.stimulus_modality
        pain_condition = self.stimulus_condition

        # 1. input_seq
        if self.stimulus_modality == 'Auditory':
            int_dim = 0
        elif self.stimulus_modality == 'Thermal':
            int_dim = 1

        input_seq[int_dim, :] = 1
        for i in range(n_epochs):
            fromm       = self.epoch_onsets[i] 
            tilll       = fromm + self.epoch_durations[i]
            onset_stim  = self.stimulus_intensities[i][0]
            offset_stim = self.stimulus_intensities[i][1]
            input_seq[-1, fromm:tilll] = np.linspace(onset_stim, offset_stim, num=tilll-fromm)

        # 2. output_seq
        output_seq[-1, :] = input_seq[-1, :]
        onsets = self.onset_offset_noise[0]
        offsets = self.onset_offset_noise[1]
        pain_onset = np.rint(np.random.normal(onsets[0], onsets[1], 1)).astype(int)[0]
        pain_offset = np.rint(np.random.normal(offsets[0], offsets[1], 1)).astype(int)[0]

        output_seq[0, :pain_onset] = 1
        output_seq[0, pain_onset:pain_offset] = 0
        output_seq[0, pain_offset:] = 1
        output_seq[1, :] = 1 - output_seq[0, :]


        return {'input_seq': input_seq, 'output_seq': output_seq,
                'stim_modality': stim_modality, 'pain_onoffset': (pain_onset, pain_offset), 'condition': pain_condition}