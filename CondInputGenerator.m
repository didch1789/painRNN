function CondInputGenerator(n_timebin)
% trials for 
inoutscan      = 'OutScan';
condavg        = true;
make_into_prob = true; 
real_int       = false;

addpath(genpath('~/github_primes'))
% basedir = '/Users/jungwookim/Library/CloudStorage/GoogleDrive-didch1789@gmail.com/내 드라이브/radyo_URP';
% basedir = '/Users/jungwookim/nas02/projects/Radyo/';
% savedir = fullfile(basedir, 'results', sprintf('radyo_240504_%s_compile_behavior', inoutscan));
load(sprintf('%s_behavioral.mat', inoutscan), 'trials', 'x_time');


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
    for trial_i = 1:size(TRIALxTIME, 1)
        TIMEx1 = TRIALxTIME(trial_i, :);
        n_time = numel(TIMEx1);
        trial_ratings(trial_i, :) = interp1(raw_time, TIMEx1', linspace(0, max(raw_time), n_timebin), 'linear');
    end

    Outputs{cond_i}(:, :, 1) = trial_ratings;
    Outputs{cond_i}(:, :, 2) = cell2mat(cellfun(@(x) sec2bin_matcher(raw_time, x, n_timebin), trials.t_presses(intidx), 'UniformOutput', false)');
    
    
    % Outputs{cond_i}(:, :, 1) = bin_raster_ycgosu(trials.data(:, intidx)', floor(numel(x_time)/n_timebin)); % Stim Rating
    % Outputs{cond_i}(:, :, 2) = cell2mat(cellfun(@(x) sec2bin_matcher(raw_time, x, n_timebin), trials.t_presses(intidx), 'UniformOutput', false)');

    % Outputs{cond_i}(:, :, 1) = trial_ratings;
    % Outputs{cond_i}(:, :, 1) = cell2mat(cellfun(@(x) sec2bin_matcher(raw_time, x, n_timebin), trials.t_presses(intidx), 'UniformOutput', false)');

    % Outputs{cond_i}(:, :, 3) = repmat(~(Inputs(cond_i, :) == 0), sum(intidx), 1); % stim idx
end

if condavg & ~make_into_prob
    Outputs = cellfun(@(x) squeeze(mean(x, 1)), Outputs, 'UniformOutput', false);
    for cond_i = 1:n_conds
        Outputs{cond_i}(:, 2) = double(Outputs{cond_i}(:, 2) > .5);
    end
    savename ='InOutputs_condavg';

elseif condavg & make_into_prob
    for cond_i = 1:n_conds
        Outputs2{cond_i, 1}(:, 1) = mean(Outputs{cond_i}(:, :, 1), 1);
        [~, clk1] = find(diff(Outputs{cond_i}(:, :, 2), 1, 2) == 1);
        [mean1, sig1] = normfit(clk1);
        [~, clk2] = find(diff(Outputs{cond_i}(:, :, 2), 1, 2) == -1);
        [mean2, sig2] = normfit(clk2);
        Outputs2{cond_i, 2} = [mean1 sig1 mean2 sig2];
    end
    Outputs = Outputs2;
    savename ='InOutputs_condavg_prob';
else
    savename ='InOutputs';
end

save(sprintf('%s.mat', savename), 'Inputs', 'Outputs');
fprintf('DONE\n')


% for i = 1:9
%     figure(i)
%     for j = 1:size(Outputs{1}, 3)
%         subplot(1, 3, j)
%         imagesc(Outputs{i}(:, :, j))
%     end
% end
% figure(i+1);
% plot(Inputs')


function painidx = sec2bin_matcher(raw_time, t_sec, t_bin)
painidx = zeros(1, t_bin);
trial_in_bin = linspace(0, max(raw_time), t_bin);
[~, click1_t] = min(abs(trial_in_bin - t_sec(1)));
[~, click2_t] = min(abs(trial_in_bin - t_sec(2)));
painidx(click1_t:click2_t) = 1;
end




end




%% Inputs (same functionality but less good)
% Inputs         = zeros(n_conds, n_timebin);
% for cond_i = 1:numel(condsval)
%     for time_i = 1:numel(time_sum)
% 
%         if time_i == 1
%             tidx = 1:time_sum(time_i);
%             InputVals = zeros(1, numel(tidx));
% 
%         elseif time_i == 2
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = linspace(0, condsval{cond_i}(1), numel(tidx)+1);
%             InputVals = InputVals(2:end);
% 
%         elseif time_i == 3
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = repmat(condsval{cond_i}(1), 1, numel(tidx));
% 
%         elseif time_i == 4
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = linspace(condsval{cond_i}(1), condsval{cond_i}(2), numel(tidx)+1);
%             InputVals = InputVals(2:end);
% 
%         elseif time_i == 5
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = repmat(condsval{cond_i}(2), 1, numel(tidx));
% 
%         elseif time_i == 6
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = linspace(condsval{cond_i}(2), condsval{cond_i}(3), numel(tidx)+1);
%             InputVals = InputVals(2:end);
% 
%         elseif time_i == 7
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = repmat(condsval{cond_i}(3), 1, numel(tidx));
% 
%         elseif time_i == 8
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = linspace(condsval{cond_i}(3), 0, numel(tidx)+1);
%             InputVals = InputVals(1:end-1);
% 
%         elseif time_i == 9
%             tidx = (time_sum(time_i-1)+1):time_sum(time_i);
%             InputVals = zeros(1, numel(tidx));
%         end
%         Inputs(cond_i, tidx) = InputVals;
%     end
% end

