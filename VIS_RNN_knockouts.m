addpath(genpath('~/github_primes'))

basedir   = '/Users/jungwookim/github/painRNN';
addpath(genpath(fullfile(basedir, 'functions')))
folder_is = 'results_hdsz16_nepch5000';
param_is  = 'condition_prob_act-tanh_label-Actions';
model_is  =  'pain_rnn_tau_0.0010_silenced';
unit_or_cluster = 'cluster';
loaded    = load(fullfile(basedir, folder_is, param_is, model_is, ...
    sprintf('silenced_outputs_each_%s.mat', unit_or_cluster)));
figoutdir = fullfile(basedir, 'figures/VIS_RNN_knockouts', folder_is, param_is, model_is, unit_or_cluster);
if ~exist(figoutdir, 'dir'), mkdir(figoutdir); end

orig      = loaded.outputs_original;
silenced  = loaded.outputs_silenced;
hiddens   = loaded.hidden_units;
[n_conds, n_times, n_units] = size(loaded.hidden_units);

%% Vis units
close all
warm_clrs = cbrewer2('Blues', 4); warm_clrs = warm_clrs(2:end, :);
pain_clrs = cbrewer2('Reds', 4);  pain_clrs = pain_clrs(2:end, :);

warm_clrs = [repmat(warm_clrs(1, :), 3, 1); repmat(warm_clrs(2, :), 3, 1); repmat(warm_clrs(3, :), 3, 1)];
pain_clrs = [pain_clrs;pain_clrs;pain_clrs];

% color by pain conds
figure(1);
for unit_i = 1:n_units
    subplot(4, 4, unit_i)
    single_unit = squeeze(hiddens(:, :, unit_i));
    for cond_i = 1:n_conds
        plot(single_unit(cond_i, :), 'Color', pain_clrs(cond_i, :)); box off
        hold on;
    end
end
set(gcf, 'Position', [0 0 800 500])
exportgraphics(gcf, fullfile(figoutdir, 'hidden_units_by_pain_conds.pdf')); close all;

% color by warm conds
figure(2);
for unit_i = 1:n_units
    subplot(4, 4, unit_i)
    single_unit = squeeze(hiddens(:, :, unit_i));
    for cond_i = 1:n_conds
        plot(single_unit(cond_i, :), 'Color', warm_clrs(cond_i, :)); box off
        hold on;
    end
end
set(gcf, 'Position', [0 0 800 500])
exportgraphics(gcf, fullfile(figoutdir, 'hidden_units_by_warm_conds.pdf')); close all;

%% Vis outputs
warm_clrs = cbrewer2('Blues', 4); warm_clrs = warm_clrs(2:end, :);
pain_clrs = cbrewer2('Reds', 4);  pain_clrs = pain_clrs(2:end, :);
warm_clrs = [repmat(warm_clrs(1, :), 3, 1); repmat(warm_clrs(2, :), 3, 1); repmat(warm_clrs(3, :), 3, 1)];
pain_clrs = [pain_clrs;pain_clrs;pain_clrs];

% Ratings
warm_idces = {[1 2 3], [4 5 6], [7 8 9]};
pain_idces = {[1 4 7], [2 5 8], [3 6 9]};

for cond_i = 1:n_conds 
    out_orig = squeeze(orig(cond_i, :, :));
    subplot(2, 3, 1);
    plot(out_orig(:, 1), 'Color', warm_clrs(cond_i, :)); hold on; box off
    subplot(2, 3, 2);
    plot(out_orig(:, 1), 'Color', pain_clrs(cond_i, :)); hold on; box off
end

for cond_ii = 1:3
    subplot(2, 3, 4);
    plot(squeeze(mean(orig(warm_idces{cond_ii}, :, 1), 1)), 'Color', warm_clrs(warm_idces{cond_ii}(1), :));
    hold on; box off;
    subplot(2, 3, 5);
    plot(squeeze(mean(orig(pain_idces{cond_ii}, :, 1), 1)), 'Color', pain_clrs(pain_idces{cond_ii}(1), :));
    hold on; box off;
end

% Clicks
x_vals = [0.9 1 1.1]; x_vals = [x_vals, x_vals + 1, x_vals + 2];
ptsz   = 50;
for cond_i = 1:n_conds 
    out_orig    = squeeze(orig(cond_i, :, :));
    in_pain_idx = (out_orig(:, 2) - out_orig(:, 3)) < 0;
    pain_str = min(find(in_pain_idx)) ./ 10 - 2;
    pain_end = max(find(in_pain_idx)) ./ 10 - 2;
    
    subplot(2, 3, 3);
    scatter(x_vals(cond_i), pain_str, ptsz, 'filled', ...
        'MarkerFaceColor', pain_clrs(cond_i, :), ...
        'MarkerEdgeColor', [0 0 0]); hold on;

    subplot(2, 3, 6);
    scatter(x_vals(cond_i), pain_end, ptsz, 'filled', ...
        'MarkerFaceColor', pain_clrs(cond_i, :), ...
        'MarkerEdgeColor', [0 0 0]); hold on;
end

set(gcf, 'Position', [0 0 800 500])
exportgraphics(gcf, fullfile(figoutdir, 'outputs_from_model.pdf'));
close all;

%% Vis outputs from silenced
warm_clrs = cbrewer2('Blues', 4); warm_clrs = warm_clrs(2:end, :);
pain_clrs = cbrewer2('Reds', 4);  pain_clrs = pain_clrs(2:end, :);
warm_clrs = [repmat(warm_clrs(1, :), 3, 1); repmat(warm_clrs(2, :), 3, 1); repmat(warm_clrs(3, :), 3, 1)];
pain_clrs = [pain_clrs;pain_clrs;pain_clrs];

% Ratings
warm_idces = {[1 2 3], [4 5 6], [7 8 9]};
pain_idces = {[1 4 7], [2 5 8], [3 6 9]};

for unit_i = 1:n_units
    silence_out = silenced(:, :, :, unit_i);

    for cond_i = 1:n_conds 
        out_orig = squeeze(silence_out(cond_i, :, :));
        subplot(2, 3, 1);
        plot(out_orig(:, 1), 'Color', warm_clrs(cond_i, :)); hold on; box off
        subplot(2, 3, 2);
        plot(out_orig(:, 1), 'Color', pain_clrs(cond_i, :)); hold on; box off
    end
    
    for cond_ii = 1:3
        subplot(2, 3, 4);
        plot(squeeze(mean(silence_out(warm_idces{cond_ii}, :, 1), 1)), 'Color', warm_clrs(warm_idces{cond_ii}(1), :));
        hold on; box off;
        subplot(2, 3, 5);
        plot(squeeze(mean(silence_out(pain_idces{cond_ii}, :, 1), 1)), 'Color', pain_clrs(pain_idces{cond_ii}(1), :));
        hold on; box off;
    end
    
    % Clicks
    x_vals = [0.9 1 1.1]; x_vals = [x_vals, x_vals + 1, x_vals + 2];
    ptsz   = 50;
    for cond_i = 1:n_conds 
        out_orig    = squeeze(silence_out(cond_i, :, :));
        in_pain_idx = (out_orig(:, 2) - out_orig(:, 3)) < 0;
        pain_str = min(find(in_pain_idx)) ./ 10 - 2;
        pain_end = max(find(in_pain_idx)) ./ 10 - 2;
        
        subplot(2, 3, 3);
        scatter(x_vals(cond_i), pain_str, ptsz, 'filled', ...
            'MarkerFaceColor', pain_clrs(cond_i, :), ...
            'MarkerEdgeColor', [0 0 0]); hold on;
    
        subplot(2, 3, 6);
        scatter(x_vals(cond_i), pain_end, ptsz, 'filled', ...
            'MarkerFaceColor', pain_clrs(cond_i, :), ...
            'MarkerEdgeColor', [0 0 0]); hold on;
    end
    
    set(gcf, 'Position', [0 0 800 500])
    exportgraphics(gcf, fullfile(figoutdir, sprintf('outputs_from_model_wo_unit%02d.pdf', unit_i)));
    close all;
end

    
