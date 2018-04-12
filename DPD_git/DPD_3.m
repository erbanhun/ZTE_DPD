%%%%%%%%%%%%%%%%%%%%%%%%%
% ����������DPD���������棨���ѧϰ��
% writen by: LY  
% date: Mar 2018
% ---------------------------------------------------
clc
clear
close all
load('ZTE_DPD.mat') % ����Ԥ������ź�
fs = 491.52e6;
x = x / max(abs(x));
y = y_all;
y = y / max(abs(y));
%% AM-AM
figure()
plot(abs(x), abs(y_all), '.', 'linewidth' , 2)
title('AM-AM')
figure()
plot(angle(y ./ x) * 180 / pi, '.')
title('AM-PM')
%% �޼������ʽ
K = 5;  % order of polynomial
X = polynomial_model(x, K);
% Least Square alogrithm
X_H = conj(X.');
C = pinv(X_H * X) * X_H * y;

y_poly = X * C;
y_poly = y_poly * max(abs(x)) / max(abs(y_poly));
nmse = NMSE(y, y_poly) ;
fprintf('NMSE = %f \n ', nmse)
figure()
psd_LY(y, fs, 3000);
hold on
psd_LY(y_poly, fs, 3000);
legend('�����ź�', 'ģ�������ź�')
title('�޼������ʽ')

Y = polynomial_model(y, K);
Y_H = conj(Y.');
C = pinv(Y_H * Y) * Y_H * x;
x_pre = X * C; % predistortion signal
figure()
psd_LY(x_pre, fs, 3000);

%% �������ʽ
K = 3;  % order of polynomial 
M = 2; % deep of memory

X = MP_model(x, K, M);
C = pinv(X' * X) * X' * y;
y_MP = X * C;
nmse_MP = NMSE(y, y_MP) ;
figure()
psd_LY(y, fs, 3000);
hold on
psd_LY(y_MP, fs, 3000);

Y = MP_model(y, K, M);
C = pinv(Y' * Y) * Y' * x;
x_pre = X * C; % predistortion signal
x_pre = x_pre * max(abs(x)) / max(abs(x_pre));
figure()
plot(abs(x), abs(x_pre), '.')
figure()
psd_LY(x_pre, fs, 3000);

%%
figure()

psd_LY(y, fs, 2000);
hold on
psd_LY(y_poly, fs, 2000);
psd_LY(y_MP, fs, 2000);
legend('����������PA�����ź�', '�޼������ʽģ�������ź�', 'GMPģ�������ź�')

