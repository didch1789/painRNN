function clrs = make_temporal_colors(varargin)

low_clrs = [222,235,247
            158,202,225
            49,130,189]./255;
high_clrs = [254,224,210
            252,146,114
            222,45,38]./255;

epochs    = [2+5 10 5 10 5+2];

if isempty(varargin)
    epochs    = cumsum(round(epochs ./ 0.83));
    delay_considered = false;
    n_trs = 56;
else
    n_trs        = varargin{:};
    samplingrate = (n_trs - 1) / (sum(epochs) + 4);
    epochs = cumsum(epochs .* samplingrate);
end

k = 1;
for li = 1:3
    for hi = 1:3
        x       = zeros(n_trs, 3);
        lowclr  = low_clrs(li, :);
        highclr = high_clrs(hi, :);

        for e_i = 1:numel(epochs)
            if (e_i == 1) 
                nc = numel(1:epochs(e_i));
                x(1:epochs(e_i), :) = repmat(lowclr, nc, 1);

            elseif e_i == 5
                nc = numel(epochs(e_i-1)+1:epochs(e_i));
                x(epochs(e_i-1)+1:epochs(e_i), :) = repmat(lowclr, nc, 1);

            elseif e_i == 3
                nc = numel(epochs(e_i-1)+1:epochs(e_i));
                x(epochs(e_i-1)+1:epochs(e_i), :) = repmat(highclr, nc, 1);

            elseif e_i == 2
                nc = numel(epochs(e_i-1)+1:epochs(e_i));
                x(epochs(e_i-1)+1:epochs(e_i), :) = clr_interpolate(lowclr, highclr, nc);

            elseif e_i == 4
                nc = numel(epochs(e_i-1)+1:epochs(e_i));
                x(epochs(e_i-1)+1:epochs(e_i), :) = clr_interpolate(highclr, lowclr, nc);
            end
        end
        x(epochs(e_i)+1:end, :) = repmat(lowclr, n_trs - epochs(end), 1);

        clrs{k} = x;
        k = k + 1;
    end
end

end

