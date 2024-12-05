clear;clc
basedir  = '/Users/jungwookim/github/painRNN';
addpath(genpath('~/github_primes'))
load(fullfile(basedir, 'HiddenLayers.mat'));
low_clrs = [222,235,247
            158,202,225
            49,130,189]./255;
high_clrs = [254,224,210
            252,146,114
            222,45,38]./255;
clrs = [low_clrs;high_clrs];
conds = {[1 4 1], [1 5 1], [1 6 1], [2 4 2], [2 5 2], [2 6 2], ...
    [3 4 3], [3 5 3], [3 6 3]};

%% 
matdirs = sort_ycgosu(fullfile(basedir, 'varying_tau/*mat'));
loaded = cellfun(@load, matdirs);
plot(cat(1, loaded.loss_epochs)')

%%
close all;
mat3d = permute(h_t, [3 2 1]);
[n_hidd, n_time, n_cond] = size(mat3d);
mat2d = reshape(mat3d, size(mat3d, 1), []);

[~, PCscr, ~, ~, Expls] = pca(mat2d', 'NumComponents', 3);
time_ratio = [2 2 5 10 5 10 5 2 2];

subplot(2, 2, 1);
plot(loss_epochs);set(gca, 'TickDir', 'out', 'LineWidth', 1.2);box off

subplot(2, 2, 3);
for cond_i = 1:size(mat3d, 3)
    low1_c = clrs(conds{cond_i}(1), :);
    high_c = clrs(conds{cond_i}(2), :);
    low2_c = clrs(conds{cond_i}(3), :);
    tidx   = ((cond_i - 1) * n_time + 1):(cond_i * n_time);

    condPC = PCscr(tidx, 1:3);
    condClr = mkclr_grad(time_ratio, {[low1_c;low1_c], [low1_c;low1_c], [low1_c;low1_c], ...
        [low1_c;high_c], [high_c;high_c], [high_c;low2_c], [low2_c;low2_c], [low2_c;low2_c], [low2_c;low2_c]});

    plot3d_graded(condPC(1:end-1, :), condClr, 'LineWidth', 1.2); hold on;
    scatter3(condPC(1, 1), condPC(1, 2), condPC(1, 3), 20, 'filled', 'green');hold on;
    scatter3(condPC(end, 1), condPC(end, 2), condPC(end, 3), 20, 'filled', 'black');hold on;
end
grid on;

warm1 = squeeze(mean(mat3d(:, (sum(time_ratio(1:2))+1):sum(time_ratio(1:3)), :), 2))';
pain1 = squeeze(mean(mat3d(:, (sum(time_ratio(1:4))+1):sum(time_ratio(1:5)), :), 2))';
warm2 = squeeze(mean(mat3d(:, (sum(time_ratio(1:6))+1):sum(time_ratio(1:7)), :), 2))';

low_conds   = {[1 2 3], [4 5 6], [7 8 9]};
high_conds  = {[1 4 7], [2 5 8], [3 6 9]};

warm1avg = cell2mat(cellfun(@(x) mean(warm1(x, :), 1), low_conds, 'UniformOutput', false)');
warm2avg = cell2mat(cellfun(@(x) mean(warm2(x, :), 1), low_conds, 'UniformOutput', false)');
pain1avg = cell2mat(cellfun(@(x) mean(pain1(x, :), 1), high_conds, 'UniformOutput', false)');
avgmat   = [warm1avg; pain1avg; warm2avg];

int_condidx = 1:6;
int_colors  = [low_clrs;high_clrs;low_clrs];
cond_clr    = int_colors(int_condidx, :);

distinfo = double(squareform(pdist(avgmat(int_condidx, :), 'cosine')));
Y        = cmdscale(distinfo, 2);

subplot(2, 2, 2);
for cond_i = 1:numel(int_condidx)
    scatter(Y(cond_i, 1), Y(cond_i, 2), 300, [.2 .2 .2], 'o', 'MarkerEdgeColor', cond_clr(cond_i, :), ...
        'LineWidth', 1.5); hold on;
    text(Y(int_condidx(cond_i), 1), Y(int_condidx(cond_i), 2), sprintf('%d', cond_i), 'Color', cond_clr(cond_i, :), ...
        'HorizontalAlignment', 'center'); hold on;
end
xlim([-0.9 0.9]); ylim([-0.2 0.2]);
set(gca, 'TickDir', 'out', 'LineWidth', 1.2)

subplot(2, 2, 4);
imagesc(distinfo);colormap(clr_interpolate([0 0 0], [1 1 1], 64));clim([0 1.5]);
set(gca, 'XTick', [], 'YTick', [])

set(gcf, 'Position', [10 10 400 400])
exportgraphics(gcf, 'RNNfig.pdf', 'ContentType', 'vector');



