%%%%%%%%%%%%%%%%%%%%%%%%%%
% The file is used to DPD预处理
% 1. 去直流
% 2. IQ平衡校正
% 3. 频点对齐
% 4. 时延、幅度、相位对齐
% Design by LY. Date: 2018-Mar
% -------------------------------------------------
clc
clear
close all

load('data.mat');
x = data2(:, 1);
y = data2(:, 2);
% 去直流
x = x - mean(x);
y = y - mean(y);
% x  = x / max(abs(x));
fs = 491.52e6;
NCO = 157.44e6;
% 归一化
x = x / max(abs(x));
y = y / max(abs(y));

%% test
N = 1000
% figure()
% plot(real(x), imag(x), '.')
% hold on
% plot(real(y), imag(y), 'r.')
% figure()
% psd_LY(x, fs, N, 'r')
% hold on 
% psd_LY(y, fs, N)
%% IQ不平衡校正
% 采用 曾绍祥 硕士论文中 方法二得到校准因子
close all
I = real(y);
Q = imag(y);
a = -(I.' * Q) / sqrt(sum(abs(I).^2) * sum(abs(Q).^2) - (I.' * Q)^2);
b = sum(abs(I).^2) / sqrt(sum(abs(I).^2) * sum(abs(Q).^2) - (I.' * Q)^2);
I_out = I;
Q_out = a * I + b * Q;
y_out = I_out+ j*Q_out;
figure()
psd_LY(y, fs, N)
hold on
psd_LY(y_out, fs, N, 'r')
legend('原始反馈信号', 'IQ校正后')
title('IQ校正前后频谱图')
%% 对齐
% 频点对齐、时延对齐、幅度对齐（归一化）、相位对齐
%% 下变频到基带
f0 = 157.44e6;
t = (1 : length(y_out)) * 1/fs;
t = t.';
y_out = y_out .* exp(-j * 2 * pi * f0 * t);
figure()
psd_LY(x, fs, N)
hold on
psd_LY(y_out, fs, N)
legend('输入信号', '频点对齐的信号')
title('频点对齐')
y_out = y_out / max(abs(y_out));

%% ---  时延对齐 ----
%% 粗对齐, 互相关
x = [x(10:end); x(1:9)]; % 测试正确性
% x = [x(end-10 : end); x(1 : end-11)];
% figure
% plot(abs(x))
% hold on
% plot(abs(y_out))
[x, y_out] = align_LY(x, y_out);
[acor, lag] = xcorr(x, y_out);
[~, I] = max(abs(acor));
lagDiff = lag(I)
if lagDiff == 0
    fprintf('粗对齐完成！\n')
end
%% 精确对齐
% 插值滤波器 LPF， fs_alter =  491.52*8M BW = 200M
I = 8
fs_8 = fs * I;
fp = 100e6
fst = 150e6;
a_ripple = 0.1;
ast = 60;
d = fdesign.interpolator(I, 'lowpass', 'Fp,Fst,Ap,Ast', fp*2/(fs*I), fst*2/(fs*I), a_ripple, ast);
hmc_int = design(d);
hfvt = fvtool(hmc_int, 'fs', fs*I)
upsam_f = hmc_int.Numerator;
% --- 插值 8 倍 ----
x_8 = resample(x, 8, 1);
y_8 = resample(y_out, 8, 1);

% figure()
% psd_LY(y_8, fs_8, N*5)
% hold on
% y_8 = conv(y_8, upsam_f, 'same');
% y_8 = y_8 / max(abs(y_8));
% psd_LY(y_8, fs_8, N*5)
% 对齐
[x_8, y_8] = align_LY(x_8, y_8);
% [x_8, y_8] = align_LY(x_8, y_8);
% --- 抽取还原 ----
y_d = resample(y_8, 1, 8);
% figure() % 查看频谱，不需要再滤波
% psd_LY(y_d, fs, N)
% hold on
% psd_LY(y_out, fs, N)
%% 相位对齐
close all
figure()
plot(angle(x ./ y_d) * 180 / pi, '.')
ang_diff = angle(x ./ y_d);
ph_shift = median(ang_diff);
y_ang = y_d .* exp(j * ph_shift);
% x = x.'
% y_d = y_d.';
% phase_corr = findshiftPM(x, y_d);
% ph_shift = median(angle(y_d(1+1000 : 2000)) - angle(x(1+1000 : 2000)));
% y_ang = y_d .* exp(j * -ph_shift);

%% time-zone & PSD figure
close all
figure()
plot(angle(x ./ y_ang) * 180 / pi, '.')
title('相位差（度）')
figure()
plot(abs(x))
hold on
plot(abs(y_ang))
legend('输入信号', '反馈信号')
title('归一化时域幅度')
figure()
psd_LY(x, fs, N)
hold on
psd_LY(y, fs, N)
psd_LY(y_ang, fs, N)
legend('输入信号','反馈信号(原始)', '反馈信号（处理后）')
title('频谱图')
%%
y_all = y_ang;
save('ZTE_DPD.mat', 'x', 'y','y_all')




