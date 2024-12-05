[n_cond, n_time, n_feat] = size(h_t);
ph_t  = permute(h_t, [3 2 1]);
rph_t = reshape(ph_t, size(ph_t, 1), []);
[PCcoeff, PCscr, ~, ~, expls] = pca(rph_t', 'NumComponents', 5);

low_clrs      = [222,235,247
                158,202,225
                49,130,189]./255;
high_clrs     = [254,224,210
                 252,146,114
                 222,45,38]./255;
kk            = 1;

for cond_i = 1:n_cond
    cidx = (n_time * (cond_i - 1) + 1):n_time * cond_i;
    
    tPC1 = PCscr(cidx, 1);
    tPC2 = PCscr(cidx, 2);
    tPC3 = PCscr(cidx, 3);
    
    plot3(tPC1, tPC2, tPC3); hold on;
    scatter3(tPC1(end), tPC2(end), tPC3(end));
end
