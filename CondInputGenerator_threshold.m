function CondInputGenerator_threshold(n_timebin)
% _threshold
inoutscan      = 'OutScan';
load(sprintf('%s_behavioral.mat', inoutscan), 'trials', 'x_time');

% ver_is = 'v1'; thr_ratio = 1/2; % simple threshold model. ratio between lvl3 and lvl4
ver_is = 'v2'; thr_ratio = 1/2;   % sensitization model. 

% how should I do with deactivation?

% v1 : simple threshold model.
% v2 : based on amount of heat (temporal summation)
cond_avg = true;
real_int = false; 
addpath(genpath('~/github_primes'))
if real_int
    condsval       = {[41 46.3 41], [41 46.9 41], [41 47.5 41], ...
                      [43 46.3 43], [43 46.9 43], [43 47.5 43], ...
                      [45 46.3 45], [45 46.9 45], [45 47.5 45]};
else
    condsval       = {[1 4 1], [1 5 1], [1 6 1], ...
                      [2 4 2], [2 5 2], [2 6 2], ...
                      [3 4 3], [3 5 3], [3 6 3]};
end
n_conds        = numel(condsval);
%%
Inputs       = zeros(n_conds, n_timebin);
t_epochs     = [2 2 5 10 5 10 5 2 2];
t_epochs     = round(t_epochs ./ sum(t_epochs) * n_timebin);

for cond_i = 1:numel(condsval)
    if real_int
        temperatures = [25 condsval{cond_i}(1:2)];
    else
        temperatures = [0 condsval{cond_i}(1:2)];
    end
    stims        = [];

    for t_i = 1:numel(t_epochs)
        t_epoch = t_epochs(t_i);
        if t_i == 1
            stims = [stims;repmat(temperatures(1), t_epoch + 1, 1)];
        elseif t_i == 2
            stims = [stims(1:end-1);linspace(temperatures(1), temperatures(2), t_epoch + 1)'];
        elseif t_i == 3
            stims = [stims(1:end-1);repmat(temperatures(2), t_epoch + 1, 1)];
        elseif t_i == 4
            stims = [stims(1:end-1);linspace(temperatures(2), temperatures(3), t_epoch + 1)'];
        elseif t_i == 5
            stims = [stims(1:end-1);repmat(temperatures(3), t_epoch + 1, 1)];
        elseif t_i == 6
            stims = [stims(1:end-1);linspace(temperatures(3), temperatures(2), t_epoch + 1)'];
        elseif t_i == 7
            stims = [stims(1:end-1);repmat(temperatures(2), t_epoch + 1, 1)];
        elseif t_i == 8
            stims = [stims(1:end-1);linspace(temperatures(2), temperatures(1), t_epoch + 1)'];
        elseif t_i == 9
            stims = [stims(1:end-1);linspace(temperatures(1), temperatures(1), t_epoch + 1)'];
        end
    end
    Inputs(cond_i, :) = stims;
end

%% Outputs
Outputs  = cell(n_conds, 1);
raw_time = x_time;

for cond_i = 1:n_conds

    intidx = (trials.n_presses == 2) & (trials.conditions == cond_i);

    trial_ratings = [];
    TRIALxTIME = trials.data(:, intidx)';
    n_trials   = size(TRIALxTIME, 1);
    for trial_i = 1:n_trials  
        TIMEx1 = TRIALxTIME(trial_i, :);
        n_time = numel(TIMEx1);
        trial_ratings(trial_i, :) = interp1(raw_time, TIMEx1', linspace(0, max(raw_time), n_timebin), 'linear');
    end

    Outputs{cond_i}(:, :, 1) = trial_ratings;

    switch ver_is
        case 'v1'
            highest_warm = condsval{7}(1);
            lowest_pain  = condsval{7}(2);
            pain_thr     = thr_ratio * highest_warm + (1-thr_ratio) * lowest_pain;
            pain_report  = double(Inputs(cond_i, :) > pain_thr);
            Outputs{cond_i}(:, :, 2) = repmat(double(Inputs(cond_i, :) > pain_thr), n_trials, 1);

        case 'v2'
            highest_warm = condsval{cond_i}(1);
            lowest_pain  = condsval{cond_i}(2);

    end


end

if cond_avg
    Outputs = cellfun(@(x) squeeze(mean(x, 1)), Outputs, 'UniformOutput', false);
    savename ='InOutputs_condavg';
end

save(sprintf('model_%s_%s.mat', ver_is, savename), 'Inputs', 'Outputs');
fprintf('DONE\n')


function painidx = sec2bin_matcher(raw_time, t_sec, t_bin)
painidx = zeros(1, t_bin);
trial_in_bin = linspace(0, max(raw_time), t_bin);
[~, click1_t] = min(abs(trial_in_bin - t_sec(1)));
[~, click2_t] = min(abs(trial_in_bin - t_sec(2)));
painidx(click1_t:click2_t) = 1;
end




end



