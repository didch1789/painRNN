function [round_out, raw_out] = sec_tr_converter(input, sec2tr_or_tr2sec, consider_delay)
% EVERYTHING STARTS FROM STIMULUS STARTS
% how it calculates
% tr_line = 0:0.83:0.83*39; 39 = sum([2 5 10 5 10 5 2])
% [tr_line;1:40] 
%
%       In Exp      |       In MR
% ----------------------------------------
%        0sec   appears in  5sec  (7th TR)
%        5sec   appears in  10sec (13th TR)
%       10sec   appears in  15sec (19th TR)
%                   ...

if isempty(consider_delay)
    consider_delay = true;
end

if strcmp(sec2tr_or_tr2sec, 'tr2sec')
    if consider_delay
        raw_out   = (input - 1) * 0.83 - 5;  % 1st TR corresponds to 0 second, so -5 sec
    else 
        raw_out   = (input - 1) * 0.83;
    end
elseif strcmp(sec2tr_or_tr2sec, 'sec2tr')
    if consider_delay
        raw_out   = (input + 5) / 0.83 + 1;
    else
        raw_out   = (input) / 0.83 + 1;
    end
end

round_out = round(raw_out);


end