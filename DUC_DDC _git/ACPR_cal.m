% ---------------------------------------------------------------------
% ACPR.m
% The function is used to calcualte the ACPR up and down band.
% x: input time signal
% Fs: sampling frequency of signal
% BW: band-width of signal
% N; the point of hanning window
% Writer by LY
% Date: 2018-March-05
% --------------------------------------------------------------------
function [ACPR_up, ACPR_down] = ACPR_cal(x, Fs, BW, N)
% x: 输入信号
% Fs: 采样频率
% BW： 信号带宽
% N： 汉宁窗系数
%% testbench
% close all
% clear
% load ('testbench.mat');
% 
% x = output(:,1);
% Fs = 400e6;
% BW = 100e6;
%%
L = length(x);
N = 5000;
w = hann(N)
Pxx =fftshift(pwelch(x, w, []));
f = Fs * ((0 : length(Pxx)-1) / length(Pxx) - 0.5);
%% ACPR
Low_c = max(find(f < -BW/2)) 
High_c = min(find(f > BW/2))

Low_up = max(find(f < -BW/2 + BW)) 
High_up = min(find(f > BW/2 + BW))

Low_down = max(find(f < -BW/2 - BW)) 
High_down = min(find(f > BW/2 - BW))

Power_c = 10 * log10(sum(Pxx(Low_c : High_c)))
Power_up = 10 * log10(sum(Pxx(Low_up : High_up)))
Power_down = 10 * log10(sum(Pxx(Low_down : High_down)))

ACPR_up = Power_c - Power_up;
ACPR_down = Power_c - Power_down;

%% two side PSD 
Pxx = 10 * log10(Pxx);
figure()
plot(f, Pxx)
grid on

end
