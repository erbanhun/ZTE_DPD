clear
clc
close all

load('LTE100M_PAR7_ZTE_modified.mat');
Fs = 400e6;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = length(sig_o);                     % Length of signal
t = (0:L-1)*T;                % Time vector
t = t.';


x = sig_o;
Px = 10 * log10(fftshift(fft(x)));
f = Fs * (linspace(0, 1, L) - 0.5);
figure()
plot(f, Px)
%% 
x_r = real(x);
x_i = imag(x);

y_r = x_r .* cos(2 * pi * 70e6 * t);
y_i = x_i .* -sin(2 * pi * 70e6 * t);
x_up = y_r + j*y_i;
Px = 10 * log10(fftshift(fft(x_up)));
f = Fs * (linspace(0, 1, L) - 0.5);
figure()
plot(f, Px)
% 
y_r = y_r .* cos(2 * pi * 70e6 * t);
y_i = y_i .* -sin(2 * pi * 70e6 * t);
x_d = y_r + j*y_i;
Px = 10 * log10(fftshift(fft(x_d)));
f = Fs * (linspace(0, 1, L) - 0.5);
figure()
plot(f, Px)
% 
% x_down = x_up .* cos(2 * pi * 300 * t);
% load('LPF_test.mat');
% % x_down = conv(x_down, Num, 'same');
% 
% Px = fftshift(fft(x_down));
% f = Fs * (linspace(0, 1, L) - 0.5);
% figure()
% plot(f, Px)
%%
close all
z =  resample(sig_o, 2, 1);
load('LPF_200250_800M.mat');
z = conv(z, Num, 'same')
Fs_up = Fs * 2;
Px = 10 * log10(fftshift(fft(z)));
f = Fs_up *(linspace(0 , 1, L*2) - 0.5),
figure()
plot(f, Px)
%%
z1 = resample(z, 1, 2);
% z = conv(z, Num, 'same')

Px = 10 * log10(fftshift(fft(z1)));
f = Fs *(linspace(0 , 1, L) - 0.5),
figure()
plot(f, Px)



