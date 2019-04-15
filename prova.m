clc
close all
clear

%tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:); %prendo le righe dove la terza colonna é uguale a 1

consumi = solo_domeniche(:,4);
ore= solo_domeniche(:,2);
n = length(consumi);
giorni = (linspace(1,365,n))';

%MODELLO DI PRIMO ORDINE PER IL TREND ANNUALE
phi1 = [ones(n,1), giorni];
[thetals1, devthetals1] = lscov(phi1, consumi);
epsilon1 = consumi - phi1 * thetals1;
stima_consumi1 = phi1 * thetals1;
ssr1 = epsilon1' * epsilon1;
q1 = length(thetals1);

consumi_nuovi = consumi-stima_consumi1;
figure(1);
scatter(giorni,consumi,'.');
hold on
scatter(giorni,consumi_nuovi,'.');
legend('consumi originali', 'consumi detrendizzati', 'Location','west');
grid on
hold off;

%STIMA FOURIER 2
w = 2 * pi / 365;
phiF2 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore),  cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
[thetalsF2, devthetalsF2] = lscov(phiF2, consumi_nuovi);
epsilonF2 = consumi_nuovi - phiF2 * thetalsF2;
stima_consumiF2 = phiF2 * thetalsF2;
ssrF2 = epsilonF2' * epsilonF2;

giorni_ext = linspace(min(giorni), max(giorni), 100);
ore_ext = linspace(min(ore), max(ore),100);
n1 = length(giorni_ext) * length(ore_ext);
[G, O] = meshgrid(giorni_ext, ore_ext);
qF2 = length(thetalsF2);

phiF2_ext = [cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:)), cos(8*w*O(:)), sin(8*w*O(:))];
stima_consumi_extF2 = phiF2_ext * thetalsF2;
stima_consumi_matF2 = reshape(stima_consumi_extF2, size(G));

figure(2);
mesh(G, O, stima_consumi_matF2);
grid on
hold on
scatter3(giorni, ore, consumi_nuovi, "o");
title("MODELLO DI FOURIER 2");
xlabel("Domeniche dell'anno");
ylabel("Ore");
zlabel("Consumi");

%validazione

tab_val = readtable('caricoDEhour.xlsx', 'Range', 'A8763:D17522');
mat_val = tab_val{:,:};
solo_domeniche_val = mat_val(mat_val(:,3)==1,:);
consumiVal = solo_domeniche_val(:,4);
giorni_val = (linspace(1,365,n))';

%MODELLO DI PRIMO ORDINE PER IL TREND VAL

phi1_val = [ones(n,1), giorni_val];
[thetals1_val, devthetals1_val] = lscov(phi1_val, consumiVal);
epsilon1_val = consumiVal - phi1_val * thetals1_val;
stima_consumi1_val = phi1_val * thetals1_val;
ssr1_val = epsilon1_val' * epsilon1_val;
q1_val = length(thetals1_val);

consumi_nuovi_val = consumiVal - stima_consumi1_val;

%modello f2 val
phiF2Val = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
epsilonF2Val = consumi_nuovi_val - (phiF2Val) * thetalsF2;
stima_consumiF2Val = phiF2Val * thetalsF2;
ssrF2Val = epsilonF2Val' * epsilonF2Val;
qF2Val = length(thetalsF2);

phiF2_ext_val = [cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:)), cos(8*w*O(:)), sin(8*w*O(:))];
stima_consumi_extF2_val = (phiF2_ext_val) * thetalsF2;
stima_consumi_matF2_val = reshape(stima_consumi_extF2_val, size(G));

figure(9);
mesh(G, O, stima_consumi_matF2_val);
grid on
hold on
scatter3(giorni_val, ore, consumi_nuovi_val, "o");
title("MODELLO DI FOURIER 2 VAL");
xlabel("Domeniche dell'anno");
ylabel("Ore");
zlabel("Consumi");

%modelli di f2 con numeri diversi di armoniche.
%4 ARMONICHE
phiF2_4 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore)];
[thetalsF2_4, devthetalsF2_4] = lscov(phiF2_4, consumi_nuovi);
epsilonF2_4 = consumi_nuovi - phiF2_4 * thetalsF2_4;
ssrF2_4 = epsilonF2_4' * epsilonF2_4;

phiF2Val4 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore)];
epsilonF2Val4 = consumi_nuovi_val - (phiF2Val4) * thetalsF2_4;
ssrF2Val4 = epsilonF2Val4' * epsilonF2Val4;

%8 ARMONICHE
phiF2_8 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore)];
[thetalsF2_8, devthetalsF2_8] = lscov(phiF2_8, consumi_nuovi);
epsilonF2_8 = consumi_nuovi - phiF2_8 * thetalsF2_8;
ssrF2_8 = epsilonF2_8' * epsilonF2_8;

phiF2Val8 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore)];
epsilonF2Val8 = consumi_nuovi_val - (phiF2Val8) * thetalsF2_8;
ssrF2Val8 = epsilonF2Val8' * epsilonF2Val8;

%12 ARMONICHE
phiF2_12 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore)];
[thetalsF2_12, devthetalsF2_12] = lscov(phiF2_12, consumi_nuovi);
epsilonF2_12 = consumi_nuovi - phiF2_12 * thetalsF2_12;
ssrF2_12 = epsilonF2_12' * epsilonF2_12;

phiF2Val12 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore)];
epsilonF2Val12 = consumi_nuovi_val - (phiF2Val12) * thetalsF2_12;
ssrF2Val12 = epsilonF2Val12' * epsilonF2Val12;

%16 ARMONICHE
phiF2_16 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore)];
[thetalsF2_16, devthetalsF2_16] = lscov(phiF2_16, consumi_nuovi);
epsilonF2_16 = consumi_nuovi - phiF2_16 * thetalsF2_16;
ssrF2_16 = epsilonF2_16' * epsilonF2_16;

phiF2Val16 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore)];
epsilonF2Val16 = consumi_nuovi_val - (phiF2Val16) * thetalsF2_16;
ssrF2Val16 = epsilonF2Val16' * epsilonF2Val16;

%20 ARMONICHE
phiF2_20 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore)];
[thetalsF2_20, devthetalsF2_20] = lscov(phiF2_20, consumi_nuovi);
epsilonF2_20 = consumi_nuovi - phiF2_20 * thetalsF2_20;
ssrF2_20 = epsilonF2_20' * epsilonF2_20;

phiF2Val20 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore)];
epsilonF2Val20 = consumi_nuovi_val - (phiF2Val20) * thetalsF2_20;
ssrF2Val20 = epsilonF2Val20' * epsilonF2Val20;

%24 ARMONICHE
phiF2_24 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore)];
[thetalsF2_24, devthetalsF2_24] = lscov(phiF2_24, consumi_nuovi);
epsilonF2_24 = consumi_nuovi - phiF2_24 * thetalsF2_24;
ssrF2_24 = epsilonF2_24' * epsilonF2_24;

phiF2Val24 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore)];
epsilonF2Val24 = consumi_nuovi_val - (phiF2Val24) * thetalsF2_24;
ssrF2Val24 = epsilonF2Val24' * epsilonF2Val24;

%28 ARMONICHE
phiF2_28 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore)];
[thetalsF2_28, devthetalsF2_28] = lscov(phiF2_28, consumi_nuovi);
epsilonF2_28 = consumi_nuovi - phiF2_28 * thetalsF2_28;
ssrF2_28 = epsilonF2_28' * epsilonF2_28;

phiF2Val28 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore)];
epsilonF2Val28 = consumi_nuovi_val - (phiF2Val28) * thetalsF2_28;
ssrF2Val28 = epsilonF2Val28' * epsilonF2Val28;

%32 ARMONICHE
phiF2_32 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore)];
[thetalsF2_32, devthetalsF2_32] = lscov(phiF2_32, consumi_nuovi);
epsilonF2_32 = consumi_nuovi - phiF2_32 * thetalsF2_32;
ssrF2_32 = epsilonF2_32' * epsilonF2_32;

phiF2Val32 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore)];
epsilonF2Val32 = consumi_nuovi_val - (phiF2Val32) * thetalsF2_32;
ssrF2Val32 = epsilonF2Val32' * epsilonF2Val32;

%36 ARMONICHE
phiF2_36 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore)];
[thetalsF2_36, devthetalsF2_36] = lscov(phiF2_36, consumi_nuovi);
epsilonF2_36 = consumi_nuovi - phiF2_36 * thetalsF2_36;
ssrF2_36 = epsilonF2_36' * epsilonF2_36;

phiF2Val36 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore)];
epsilonF2Val36 = consumi_nuovi_val - (phiF2Val36) * thetalsF2_36;
ssrF2Val36 = epsilonF2Val36' * epsilonF2Val36;

%40 ARMONICHE
phiF2_40 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore)];
[thetalsF2_40, devthetalsF2_40] = lscov(phiF2_40, consumi_nuovi);
epsilonF2_40 = consumi_nuovi - phiF2_40 * thetalsF2_40;
ssrF2_40 = epsilonF2_40' * epsilonF2_40;

phiF2Val40 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore)];
epsilonF2Val40 = consumi_nuovi_val - (phiF2Val40) * thetalsF2_40;
ssrF2Val40 = epsilonF2Val40' * epsilonF2Val40;


%plot degli ssr
ssrVal = [ssrF2Val4, ssrF2Val8, ssrF2Val12, ssrF2Val16, ssrF2Val20, ssrF2Val24, ssrF2Val28, ssrF2Val32, ssrF2Val36, ssrF2Val40];
ssr = [ssrF2_4, ssrF2_8, ssrF2_12, ssrF2_16, ssrF2_20, ssrF2_24, ssrF2_28, ssrF2_32, ssrF2_36, ssrF2_40];
x = linspace(4,40,10);
figure(3)
plot(x,ssrVal);
grid on
hold on
plot(x,ssr);
legend('modello di validazione','modello di identificazione');
xlabel('armoniche');
ylabel('ssr');