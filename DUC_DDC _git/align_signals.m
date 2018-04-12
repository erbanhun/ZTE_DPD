function x_new = align_signals(x, y)
% Generate a new x vector aligned with the y vector.
% - all vectors must be of the same size
% Line them up
disp('Correlation ADC and DAC amplitudes');
Lmax = -findshiftAM(abs(x), abs(y));
xI = sinccircular(x, Lmax, 200);
disp(sprintf('Max amplitude correlation is %1.4f at %1.2f samples', xcorr(abs(xI), abs(y), 0, 'coeff'), Lmax));
Lmax = -findshiftAM(abs(xI), abs(y));
if Lmax ~= 0.0
	xI = sinccircular(xI, Lmax, 200);
	disp(sprintf('Max amplitude correlation is %1.4f at %1.2f samplies', xcorr(abs(xI), abs(y), 0, 'coeff'), Lmax));
end

Lmax = -findshiftAM(abs(xI), abs(y));
disp(sprintf('Lmax is %1.4f', Lmax));

phase_corr = findshiftPM(xI, y);
disp(sprintf('Best phase correlation at %1.2f samples relative to AM correlation', phase_corr));
disp(sprintf('EVM: %1.2f%%', 100 * evm(xI, y)));

ph_shift = median(angle(y(1+1000 : 2000)) - angle(xI(1+1000 : 2000)));
x_new = xI.*exp(1i * ph_shift);

return
