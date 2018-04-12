%%%%%%%%%%%%%%%%%%%%%%%%%%
% The file is used to 
% 1. Upsampling sig from 3.84 to 16*8.34
% 2. Digital up conversion
% 3. Downsampling to 2*3.84
% 4. Digital down conversion
% Design by LY. Date: 2018-Mar
% -------------------------------------------------
clear
clc
close all

%% Load data
load('UMTS.mat');           % 4 carrier wcdma?
UMTS = UMTS(1:3000,:);
[L, M] = size(UMTS);
fs0 = 3.84e6;
I = 16;         % factor of integrator
D = 8;          % factor of decimation
f0 = 20e6; % Up conversion center frequency
delta_f = 3.84e6;
f0_v = [f0 - 2*delta_f, f0 - delta_f, f0 + delta_f, f0 + 2*delta_f]; 
%% test
load('LTE100M_PAR7_ZTE_modified.mat')
figure()
subplot(2, 1, 1)
psd_LY(UMTS(:, 1), fs0, 3000, 'r');
title('UMTS signal(µ•‘ÿ≤®)')
subplot(2, 1, 2)
psd_LY(sig_o, 400e6, 3000, 'r');
title('100M-5‘ÿ≤®-LTE-A–≈∫≈');
%% Design integrator filter (LPF) Fs = 61.44e6
fp = 4e6;
fst = 4.5e6;
% dd = 2
a_ripple = 0.1
ast = 60;
d = fdesign.interpolator(16, 'lowpass', 'Fp,Fst,Ap,Ast', fp*2/(fs0*I), fst*2/(fs0*I), a_ripple, ast);
hmc_int = design(d);
hfvt = fvtool(hmc_int, 'fs', fs0*I)
upsam_f = hmc_int.Numerator;
%%  down conversion filter (LPF) Fs = 7.68e6
fp = 2e6;
fst = 2.2e6;
ap = 0.1;
ast = 60
d = fdesign.lowpass('Fp,Fst,Ap,Ast', fp*2/(fs0*I/D), fst*2/(fs0*I/D), ap, ast);
hd = design(d, 'equiripple');
fvtool(hd, 'fs', fs0*I/D);
down_con_filter = hd.Numerator;
%% Design decimation filter (BPF) 
% center frequency = f0  Fs = 61.44 
fst1 = f0 - 2*2e6 -1e6;
fp1 = f0 - 2*2e6;
fp2 = f0 + 2*2e6;
fst2 = f0 + 2*2e6 +1e6;
fst1 = fst1 * 2/(fs0 * 16);
fst2 = fst2 * 2/(fs0 * 16);
fp1 = fp1 * 2/(fs0 * 16);
fp2 = fp2 * 2/(fs0 * 16);
ast1 = 60
ap = 0.1
ast2 = 60
d = fdesign.decimator(8, 'bandpass', 'fst1,fp1,fp2,fst2,ast1,ap,ast2', fst1, fp1, fp2, fst2, ast1, ap, ast2);
hmc_dec = design(d, 'equiripple');
% fvtool(hmc_dec, 'fs', fs0*I)
downsam_filter = hmc_dec.Numerator;

%% Integrator from 3.84e6 to 61.44e6 , I = 16
for i = 1:M
    UMTS_us(:, i) = resample(UMTS(:, i), I, 1);
    UMTS_us(:, i) = conv(UMTS_us(:, i), upsam_f, 'same');
end
fs_us = fs0 * I;

%% Up conversion 4 carriers signals to f0
t_up = (0 : L*I-1) / fs_us;
t_up = t_up.';
for i = 1:M
    upmixed(:, i) = UMTS_us(:, i) .* sin(2 * pi * f0_v(i) * t_up);
end

%% Decimation from 61.44e6 to 7.68e6, D = 8
for i = 1:M
    upmixed(:, i) = conv(upmixed(:, i), downsam_filter, 'same');
    UMTS_ds(:, i) = resample(upmixed(:, i), 1, D);
end
fs_ds = fs_us / D;

%% Down conversion signals to f0 = 0
t_down = (0 : length(UMTS_ds)-1) / fs_ds;
t_down = t_down.';
for i = 1:M
    downmixed(:, i) = UMTS_ds(:, i) .* sin(2 * pi * f0_v(i) * t_down);
     downmixed(:, i) = conv(downmixed(:, i), down_con_filter, 'same'); % downmixed sig filter a LPF (f0 = 0)
end
fprintf(' ==== Over! =====\n')



        

