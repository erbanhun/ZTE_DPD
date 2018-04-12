function [nmse] = NMSE(x, y)
    d_e = sum((real(x) - real(y)).^2 + (imag(x) - imag(y)).^2);
    d_m = sum(real(x).^2 + imag(x).^2);
    
    nmse = 10 * log10(d_e / d_m);
    
end