function outs = i2o(inputs, i2h, h2h, h2o, varargin)

actfunc = @tanh;
alpha   = 1; 

for i = 1:numel(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case 'actfunc'
                % e.g.
                % should be like @func
                actfunc = varargin{i+1};
            case 'alpha'
                alpha = varargin{i+1};
        end
    end
end

[n_inputs, n_time, n_features] = size(inputs);

for time_i = 1:n_time
    if time_i == 1
        h_curr = 
    else
        h_curr
    end

    i_curr
    h_curr = h2h * h_prev 
    o_curr = 

        
    h2h * 
    
        
        o1 = h1 * h2o';
    end

end




end