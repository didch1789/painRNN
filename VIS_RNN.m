clear;clc; close all
basedir = '/Users/jungwookim/github/painRNN';
addpath(genpath(fullfile(basedir, 'functions')))
addpath(genpath('~/github_primes'))
intcond = 'threshold_mdl1_act-tanh_label-Clicks2';
results_name = 'results_mdl_v1';
intalph      = 'HiddenLayers_tau_0.01';
loaded  = load(fullfile(basedir, results_name, intcond, [intalph, '.mat']));
[n_cond, n_time, n_feat] = size(loaded.h_t);
ph_t    = permute(loaded.h_t, [3 2 1]);
rph_t   = reshape(ph_t, size(ph_t, 1), []);
[PCcoeff, PCscr, ~, ~, Expls] = pca(rph_t', 'NumComponents', 5);
clrs = make_temporal_colors(n_time);
figoutdir = fullfile(basedir, 'figures', [intcond, '_', intalph(end-3:end)]);
if ~exist(figoutdir, 'dir'), mkdir(figoutdir); end

%% Dynamics
for cond_i = 1:n_cond
    cidx = (n_time * (cond_i - 1) + 1):n_time * cond_i;
    clr_is = clrs{cond_i};
    
    tPC1 = PCscr(cidx, 1);
    tPC2 = PCscr(cidx, 2);
    tPC3 = PCscr(cidx, 3);

    plot3d_graded(PCscr(cidx, 1:3), clr_is)
    scatter3(tPC1(end), tPC2(end), tPC3(end), 'black', 'filled');
end
grid on;% xlabel('PC1');ylabel('PC2');zlabel('PC3')
set(gca, 'LineWidth', 1.3, 'FontSize', 9);
set(gcf, 'Position', [10 10 150 150])
exportgraphics(gcf, fullfile(figoutdir, 'PC_Traj.pdf'), 'ContentType', 'vector')

%% 
randclr = abs(randn(5, 3));
randclr = randclr ./ (max(randclr)+1);
sumt_epochs = cumsum(t_epochs);
for ii = 1:numel(sumt_epochs)-1
    if ii == 1
        int_time = 1:sumt_epochs(ii);
    else
        int_time = sumt_epochs(ii):sumt_epochs(ii+1);
    end
    scatter3(tPC1(int_time), tPC2(int_time), tPC3(int_time)); hold on;
end
xlabel('PC1');ylabel('PC4');zlabel('PC5')
%% MDS
close all
time_ratio = [2 2 5 10 5 10 5 2 2];
time_ratio = time_ratio .* ((n_time - 1) ./ sum(time_ratio));

warm1 = squeeze(mean(ph_t(:, (sum(time_ratio(1:2))+1):sum(time_ratio(1:3)), :), 2))';
pain1 = squeeze(mean(ph_t(:, (sum(time_ratio(1:4))+1):sum(time_ratio(1:5)), :), 2))';
warm2 = squeeze(mean(ph_t(:, (sum(time_ratio(1:6))+1):sum(time_ratio(1:7)), :), 2))';

low_conds   = {[1 2 3], [4 5 6], [7 8 9]};
high_conds  = {[1 4 7], [2 5 8], [3 6 9]};

warm1avg = cell2mat(cellfun(@(x) mean(warm1(x, :), 1), low_conds, 'UniformOutput', false)');
warm2avg = cell2mat(cellfun(@(x) mean(warm2(x, :), 1), low_conds, 'UniformOutput', false)');
pain1avg = cell2mat(cellfun(@(x) mean(pain1(x, :), 1), high_conds, 'UniformOutput', false)');
avgmat   = [warm1avg; pain1avg; warm2avg];

intconds = 1:6;
VIS_MDS(avgmat, intconds)
set(gcf, 'Position', [10 10 260 90])
exportgraphics(gcf, fullfile(figoutdir, sprintf('MDS_%d_%d.pdf', intconds(1), intconds(end))), ...
    'ContentType', 'vector')
