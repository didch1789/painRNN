function gcf = plot3d_radyo(mat3d, tr_epochs, varargin)
% mat3d  : n_vox by n_tr by n_cond (9)

low_clrs   = [222,235,247
    158,202,225
    49,130,189]./255;
high_clrs   = [254,224,210
    252,146,114
    222,45,38]./255;
smooth_size = 7;

for i = 1:numel(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'smooth_size'}
                smooth_size = varargin{i+1};
        end
    end

end

[~, n_tr, n_cond] = size(mat3d);
mat2d   = reshape(mat3d, size(mat3d, 1), []);
[~, pc2d] =  pca(mat2d', 'NumComponents', 3);
pc3d      = reshape(pc2d, n_tr, n_cond, []);
pc3d      = smoothdata(pc3d, 2, 'gaussian', smooth_size);

low_clr_tmp  = [1 1 1 2 2 2 3 3 3];
high_clr_tmp = [1 2 3 1 2 3 1 2 3];


for cond_i = 1:n_cond
    low_clr  = low_clrs(low_clr_tmp(cond_i), :);
    high_clr = high_clrs(high_clr_tmp(cond_i), :);
    dot1idx  = click1st(cond_i);
    dot2idx  = click2nd(cond_i);

    [~, click_t1] = min(abs(t_secs - dot1idx));
    [~, click_t2] = min(abs(t_secs - dot2idx));

    for tr_i = 1:n_tr

        if tr_i <= tr_epochs(1)
            clr1 = repmat(low_clr, tr_epochs(1), 1);

        elseif tr_epochs(1) < tr_i & tr_i <= sum(tr_epochs(1:2))
            clr2 = clr_interpolate(low_clr, high_clr, tr_epochs(2));

        elseif sum(tr_epochs(1:2)) < tr_i & tr_i <= sum(tr_epochs(1:3))
            clr3 = repmat(high_clr, tr_epochs(3), 1); 

        elseif sum(tr_epochs(1:3)) < tr_i & tr_i <= sum(tr_epochs(1:4))
            clr4 = clr_interpolate(high_clr, low_clr, tr_epochs(4));

        elseif sum(tr_epochs(1:4)) < tr_i 
            clr5 = repmat(low_clr, tr_epochs(5), 1);
        end

    end

    clrs = [clr1;clr2;clr3;clr4;clr5];

    for tr_i = 1:n_tr
        if tr_i == n_tr
            break
        end

        int_tr = tr_i:tr_i + 1;
        x = pc3d(int_tr, cond_i, 1);
        y = pc3d(int_tr, cond_i, 2);
        z = pc3d(int_tr, cond_i, 3);
        plot3(x, y, z, 'LineWidth', 1.2, 'Color',clrs(tr_i, :)); hold on;
        
    end
    scatter3(x(end), y(end), z(end), 30, 'filled', 'MarkerFaceColor', [.1 .1 .1]); hold on;
    scatter3(pc3d(click_t1, cond_i, 1), pc3d(click_t1, cond_i, 2), pc3d(click_t1, cond_i, 3), 30, ...
        'filled', 'diamond', 'MarkerFaceColor', [62 225 123] ./ 255); hold on;
    scatter3(pc3d(click_t2, cond_i, 1), pc3d(click_t2, cond_i, 2), pc3d(click_t2, cond_i, 3), 30, ...
        'filled', 'diamond', 'MarkerFaceColor', [62 225 123] ./ 255); hold on;
end

[~, n_tr, n_cond] = size(mat3d);
mat2d  = reshape(mat3d, size(mat3d, 1), []);
[~, pc2d] =  pca(mat2d', 'NumComponents', 3);
pc3d    = reshape(pc2d, n_tr, n_cond, []);
pc3d    = smoothdata(pc3d, 2, 'gaussian', 7);

low_clr_tmp  = [1 1 1 2 2 2 3 3 3];
high_clr_tmp = [1 2 3 1 2 3 1 2 3];

t_secs    = (1:n_tr) .* .83;
t_epochs  = [7 10 5 10 7];
tr_epochs = round((t_epochs) ./ 0.83);
tr_epochs(end) = tr_epochs(end) + n_trs - sum(tr_epochs);

for cond_i = 1:n_conds
    low_clr  = low_clrs(low_clr_tmp(cond_i), :);
    high_clr = high_clrs(high_clr_tmp(cond_i), :);
    dot1idx  = click1st(cond_i);
    dot2idx  = click2nd(cond_i);

    [~, click_t1] = min(abs(t_secs - dot1idx));
    [~, click_t2] = min(abs(t_secs - dot2idx));

    for tr_i = 1:n_tr

        if tr_i <= tr_epochs(1)
            clr1 = repmat(low_clr, tr_epochs(1), 1);

        elseif tr_epochs(1) < tr_i & tr_i <= sum(tr_epochs(1:2))
            clr2 = clr_interpolate(low_clr, high_clr, tr_epochs(2));

        elseif sum(tr_epochs(1:2)) < tr_i & tr_i <= sum(tr_epochs(1:3))
            clr3 = repmat(high_clr, tr_epochs(3), 1); 

        elseif sum(tr_epochs(1:3)) < tr_i & tr_i <= sum(tr_epochs(1:4))
            clr4 = clr_interpolate(high_clr, low_clr, tr_epochs(4));

        elseif sum(tr_epochs(1:4)) < tr_i 
            clr5 = repmat(low_clr, tr_epochs(5), 1);
        end

    end

    clrs = [clr1;clr2;clr3;clr4;clr5];

    for tr_i = 1:n_tr
        if tr_i == n_tr
            break
        end

        int_tr = tr_i:tr_i + 1;
        x = pc3d(int_tr, cond_i, 1);
        y = pc3d(int_tr, cond_i, 2);
        z = pc3d(int_tr, cond_i, 3);
        plot3(x, y, z, 'LineWidth', 1.2, 'Color',clrs(tr_i, :)); hold on;
        
    end
    scatter3(x(end), y(end), z(end), 30, 'filled', 'MarkerFaceColor', [.1 .1 .1]); hold on;
    scatter3(pc3d(click_t1, cond_i, 1), pc3d(click_t1, cond_i, 2), pc3d(click_t1, cond_i, 3), 30, ...
        'filled', 'diamond', 'MarkerFaceColor', [62 225 123] ./ 255); hold on;
    scatter3(pc3d(click_t2, cond_i, 1), pc3d(click_t2, cond_i, 2), pc3d(click_t2, cond_i, 3), 30, ...
        'filled', 'diamond', 'MarkerFaceColor', [62 225 123] ./ 255); hold on;
end


end