function [pxx, f] = psd_LY(x, fs, N, color)

window = hann(N);
pxx = pwelch(x, window, []);
pxx = 10 * log10(fftshift(pxx));
f = fs * (linspace(0, 1, length(pxx)) - 0.5);
if nargin < 4
    plot(f, pxx)
else
    plot(f, pxx, color)
end
grid on
end