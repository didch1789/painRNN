def genstim(idx):
    modalities  = ['Auditory', 'Thermal']
    onoff_noise = [[(5, 1), (15, 1)], [(7.5, 1), (17,5, 1)]]
    conditions  = [141, 151, 161, 242, 252, 262, 343, 353, 363]
    stimulus_intensities = [[(1, 1), (1, 4), (4, 4), (4, 1), (1, 1)],
                            [(1, 1), (1, 5), (5, 5), (5, 1), (1, 1)],
                            [(1, 1), (1, 6), (6, 6), (6, 1), (1, 1)],
                            [(2, 2), (2, 4), (4, 4), (4, 2), (2, 2)],
                            [(2, 2), (2, 5), (5, 5), (5, 2), (2, 2)],
                            [(2, 2), (2, 6), (6, 6), (6, 2), (2, 2)],
                            [(3, 3), (3, 4), (4, 4), (4, 3), (3, 3)],
                            [(3, 3), (3, 5), (5, 5), (5, 3), (3, 3)],
                            [(3, 3), (3, 6), (6, 6), (6, 3), (3, 3)]]
    modal_idx = idx % 2
    cond_idx = idx % 9

    int_modality    = modalities[modal_idx]
    int_onoffnoise  = onoff_noise[modal_idx]
    int_cond        = conditions[cond_idx]
    int_intensities = stimulus_intensities[cond_idx]

    return {'int_modality': int_modality, 'int_onoffnoise': int_onoffnoise,
                'int_cond': int_cond, 'int_intensities': int_intensities}







