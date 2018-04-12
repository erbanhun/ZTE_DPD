%%%%%%%%%%%%%%%%%%%%%%%%%%
% The file is used to DPDԤ����
% 1. ȥֱ��
% 2. IQƽ��У��
% 3. Ƶ�����
% 4. ʱ�ӡ����ȡ���λ����
% Design by LY. Date: 2018-Mar
% -------------------------------------------------
clc
clear
close all

load('data.mat');
x = data2(:, 1);
y = data2(:, 2);
% ȥֱ��
x = x - mean(x);
y = y - mean(y);
% x  = x / max(abs(x));
fs = 491.52e6;
NCO = 157.44e6;
% ��һ��
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
%% IQ��ƽ��У��
% ���� ������ ˶ʿ������ �������õ�У׼����
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
legend('ԭʼ�����ź�', 'IQУ����')
title('IQУ��ǰ��Ƶ��ͼ')
%% ����
% Ƶ����롢ʱ�Ӷ��롢���ȶ��루��һ��������λ����
%% �±�Ƶ������
f0 = 157.44e6;
t = (1 : length(y_out)) * 1/fs;
t = t.';
y_out = y_out .* exp(-j * 2 * pi * f0 * t);
figure()
psd_LY(x, fs, N)
hold on
psd_LY(y_out, fs, N)
legend('�����ź�', 'Ƶ�������ź�')
title('Ƶ�����')
y_out = y_out / max(abs(y_out));

%% ---  ʱ�Ӷ��� ----
%% �ֶ���, �����
x = [x(10:end); x(1:9)]; % ������ȷ��
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
    fprintf('�ֶ�����ɣ�\n')
end
%% ��ȷ����
% ��ֵ�˲��� LPF�� fs_alter =  491.52*8M BW = 200M
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
% --- ��ֵ 8 �� ----
x_8 = resample(x, 8, 1);
y_8 = resample(y_out, 8, 1);

% figure()
% psd_LY(y_8, fs_8, N*5)
% hold on
% y_8 = conv(y_8, upsam_f, 'same');
% y_8 = y_8 / max(abs(y_8));
% psd_LY(y_8, fs_8, N*5)
% ����
[x_8, y_8] = align_LY(x_8, y_8);
% [x_8, y_8] = align_LY(x_8, y_8);
% --- ��ȡ��ԭ ----
y_d = resample(y_8, 1, 8);
% figure() % �鿴Ƶ�ף�����Ҫ���˲�
% psd_LY(y_d, fs, N)
% hold on
% psd_LY(y_out, fs, N)
%% ��λ����
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
title('��λ��ȣ�')
figure()
plot(abs(x))
hold on
plot(abs(y_ang))
legend('�����ź�', '�����ź�')
title('��һ��ʱ�����')
figure()
psd_LY(x, fs, N)
hold on
psd_LY(y, fs, N)
psd_LY(y_ang, fs, N)
legend('�����ź�','�����ź�(ԭʼ)', '�����źţ������')
title('Ƶ��ͼ')
%%
y_all = y_ang;
save('ZTE_DPD.mat', 'x', 'y','y_all')




