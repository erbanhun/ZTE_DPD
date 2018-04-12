function [x, y] = align_LY(x, y)
[acor, lag] = xcorr(x, y);
[~, I] = max(abs(acor));
lagDiff = lag(I);
fprintf('lag = %d', lagDiff);

if lagDiff > 0 
    y = [y(end - (lagDiff - 1) : end); y(1 : end - lagDiff)];
elseif lagDiff <  0
    lagDiff = -lagDiff
    y = [y(lagDiff + 1 : end); y(1 : lagDiff)];
end

end