function [Y] = MP_model(x, K, M)
% Generalized Memory Polynomial
x = [x(end - M +1 : end); x];

for k = 0:K-1
    for m = 1:M
        if ( m == 1)
            H = abs(x(1 + M -m : end-m)).^k .* x(1+M : end);
        else
            H = [H, abs(x(1+M-m : end -m)) .* x(1+M : end)];
        end
    end
    if k == 0
        Y = H;
    else
        Y = [Y, H];
    end
end

end