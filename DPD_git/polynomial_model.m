function [Y] = polynomial_model(x, K)

v = x;
for i = 1 : K
    if i == 1
        Y = x;
    else
        Y = [Y, v];
    end
    v = v .* x;
end

end