len = 76800;
pn9_output = zeros(1, len);
Fs = 3.84e6;
sf_length = 128;
tpc = zeros(15, 2);
slot = zeros(15, 8)
seed = [1 1 zeros(1, 7)];

time=[86 134 52 45 143 112 59 23 1 88 30 18 30 61 128 143 83 25 103 97 56 104....
    51 26 137 65 37 125 149 123 83 5 91 7 32 21 29 59 22 138 31 17 9 69 49 20 57 121....
    127 114 100 76 141 82 64 149 87 98 46 37 87 149 85 69];

code=[2 11 17 23 31 38 47 55 62 69 78 85 94 102 113 119 7 13 20 27 35 41 51....
    58 64 74 82 88 97 108 117 125 4 9 12 14 19 22 26 28 34 36 40 44 49 53 56 61 63....
    66 71 76 80 84 87 91 95 99 105 110 116 118 122 126];

db=[-16 -16 -16 -17 -18 -20 -16 -17 -16 -19 -22 -20 -16 -17 -19 -21 -19 -21....
    -18 -20 -24 -24 -22 -21 -18 -20 -17 -18 -19 -23 -22 -21 -17 -18 -20 -17 -19 -21....
    -19 -23 -22 -19 -24 -23 -22 -19 -22 -21 -18 -19 -22 -21 -19 -21 -19 -21 -20 -25....
    -25 -25 -24 -22 -20 -15];
slot(1,:)=[-1 -1 -1 -1 -1 -1 -1 1];
slot(2,:)=[-1 -1 1 1 -1 -1 -1 1];
slot(3,:)=[-1 -1 1 -1 -1 -1 1 -1];
slot(4,:)=[-1 -1 1 1 -1 -1 1 1];
slot(5,:)=[-1 -1 -1 1 -1 -1 1 -1];
slot(6,:)=[-1 -1 -1 -1 -1 -1 -1 1];
slot(7,:)=[-1 -1 -1 -1 -1 -1 1 1];
slot(8,:)=[-1 -1 -1 1 -1 -1 1 1];
slot(9,:)=[-1 -1 1 -1 -1 -1 -1 1];
slot(10,:)=[-1 -1 -1 -1 -1 -1 -1 -1];
slot(11,:)=[-1 -1 1 -1 -1 -1 1 -1];
slot(12,:)=[-1 -1 -1 1 -1 -1 -1 -1];
slot(13,:)=[-1 -1 -1 1 -1 -1 1 1];
slot(14,:)=[-1 -1 1 1 -1 -1 -1 1];
slot(15,:)=[-1 -1 1 1 -1 -1 -1 1];

%
sf = ovsf(sf_length);

%
scr = scramble(0, 1);

% pn9
for i = 1:2:15
	tpc(i, :) = [1 1];
end
for k = 1:64
	seed_temp1 = dec2bin(code(k));
	temp = zeros(1, length(seed_temp1));
	for i = 1:length(seed_temp1)
		if seed_temp1(i) == '0'
			c = 0;
		else
			c = 1;
		end
		temp(i) = c;
	end
	seed_temp = [zeros(1, 7-length(temp)), temp];
	seed_temp = fliplr(seed_temp);
	seed(1, 3:9) = seed_temp;

	% generate pn9
	reg = seed;
	for i1 = 1:511
		temp5 = reg(1, 5);
		temp1 = reg(1, 9);
		pnt = reg(1, 9);
		for j2 = 8:-1:1
			reg(1, j2+1) = reg(1, j2);
		end
		reg(1, 1) = mod(temp5 + temp1, 2);

		if (pnt == 0)
			pnout(k, i1) = 1;
		else
			pnout(k, i1) = -1;
		end
	end
end

% output pn9_output
for k = 1:64
	for i = 1:15
		pn9_dpch(k,(i-1)*40+1:(i-1)*40+6) = pnout(k,(i-1)*30+1:(i-1)*30+6);
        pn9_dpch(k,(i-1)*40+7:(i-1)*40+8) = tpc(i,:);
        pn9_dpch(k,(i-1)*40+9:(i-1)*40+32) = pnout(k,(i-1)*30+7:(i-1)*30+30);
        pn9_dpch(k,(i-1)*40+33:(i-1)*40+40) = slot(i,:);
    end
	pn9_dpch(k, 601:1200) = pn9_dpch(k, 1:600);
	pn9(k, 1:2*time(k)) = 0;
	pn9(k, 2*time(k)+1:1200) = pn9_dpch(k, 1:1200-2*time(k));
end

% 
for k = 1:64
	pn9real(k, :) = pn9(k, 1:2:1199);
	pn9imag(k, :) = pn9(k, 2:2:1200);
	for i = 1:600
		pn9real_spread(k, (i-1)*sf_length+1 : i*sf_length) = pn9real(k, i);
		pn9imag_spread(k, (i-1)*sf_length+1 : i*sf_length) = pn9imag(k, i);
	end
end

%
for k = 1:64
	for i = 1:600
		pn9real_sf(k, (i-1)*sf_length+1 : i*sf_length) ...
		= pn9real_spread(k, (i-1)*sf_length+1 : i*sf_length) .* sf(code(k), 1:sf_length);
		pn9imag_sf(k, (i-1)*sf_length+1 : i*sf_length)...
		= pn9imag_spread(k, (i-1)*sf_length+1 : i*sf_length) .* sf(code(k), 1:sf_length);
	end
	pn9sf(k, :) = pn9real_sf(k, :) + j*pn9imag_sf(k, :);
	
	scr2(1: 38400) = scr;
	scr2(38401 :76800) = scr;
	pn9_scra(k, :) = pn9sf(k, :) .* scr2;
	per = 10 ^ (db(k)/10);
	pn9_output = pn9_output + per*pn9_scra(k, :);
end

y1 = pn9_output / max(abs(pn9_output)) * 32677;

