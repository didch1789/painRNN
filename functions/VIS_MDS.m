function VIS_MDS(X, int_condidx)
% X
%   n_feat x 9 conditions

color9 = ...
   [0.7333    0.8431    0.9020
    0.3686    0.6784    0.8314
    0.0039    0.4392    0.7020
    1.0000    0.6863    0.5804
    1.0000    0.4235    0.3137
    0.8353    0.1137    0.1451
    0.7333    0.8431    0.9020
    0.3686    0.6784    0.8314
    0.0039    0.4392    0.7020];
mrkrsize = 180;

neurmat     = X(int_condidx, :);
clrmat      = color9(int_condidx, :);

distinfo   = double(squareform(pdist(neurmat, 'euclidean')));
Y          = cmdscale(distinfo, 2);

subplot(1, 2, 1);
for ic = 1:numel(int_condidx)
    if int_condidx(ic) > 6
        ii = int_condidx(ic) - 6;
    else
        ii = int_condidx(ic);
    end
    int_clr = clrmat(ic, :);
    scatter(Y(ic, 1), Y(ic, 2), mrkrsize, 'Marker', 'o', 'LineWidth', 1.5, 'MarkerEdgeColor', int_clr);hold on;
    text(Y(ic, 1), Y(ic, 2), num2str(ii), 'Color', int_clr, 'HorizontalAlignment', 'center', ...
        'FontSize', 9);
end
xlims = get(gca, 'XLim');
xlim([xlims(1) - 0.5 xlims(2) + 0.5])
ylims = get(gca, 'YLim');
ylim([ylims(1) - 0.5 ylims(2) + 0.5])
box off ; set(gca, 'LineWidth', 1.2, 'TickDir', 'out', 'TickLength', [0.02 0.02])
% box off; set(gca, 'LineWidth', 1.5, 'TickDir', 'out', 'FontName', 'Helvetica', ...
%     'xlim',  [-0.3 0.3], 'ylim', [-0.2 0.2], 'FontSize', 9, 'TickLength', [0.02 0.02]);
subplot(1, 2, 2);
imagesc(distinfo);colormap(clr_interpolate([0 0 0], [1 1 1], 64));colorbar% clim([0 2])
set(gca,'XTick', [], 'YTick', [], 'TickDir', 'ou');
set(gcf, 'Position', [0 0 480 180])

end