clc
close all
clear

%tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:); %prendo le righe dove la terza colonna é uguale a 1

consumi = solo_domeniche(:, 4);
ore= solo_domeniche(:, 2);
n = length(consumi);
giorni = (linspace(1, 365, n))';

%MODELLO DI PRIMO ORDINE PER IL TREND ANNUALE
phi1 = [ones(n, 1), giorni];
[thetals1, devthetals1] = lscov(phi1, consumi);
epsilon1 = consumi - phi1 * thetals1;
stima_consumi1 = phi1 * thetals1;
ssr1 = epsilon1' * epsilon1;
q1 = length(thetals1);

consumi_nuovi = consumi - stima_consumi1;
figure(1);
scatter(giorni, consumi, '.');
hold on
scatter(giorni, consumi_nuovi, '.');
legend('consumi originali', 'consumi detrendizzati');
xlabel("Giorni dell' anno", 'FontSize', 14);
ylabel('Consumi in MWatt', 'FontSize', 14);
grid on
hold off;

%STIMA FOURIER 2
w = 2 * pi / 365;
phiF2 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore),  cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
[thetalsF2, devthetalsF2] = lscov(phiF2, consumi_nuovi);
epsilonF2 = consumi - (phiF2 * thetalsF2 + stima_consumi1);
stima_consumiF2 = phiF2 * thetalsF2 + stima_consumi1;
ssrF2 = epsilonF2' * epsilonF2;

giorni_ext = linspace(min(giorni), max(giorni), 100);
ore_ext = linspace(min(ore), max(ore),100);
n1 = length(giorni_ext) * length(ore_ext);
[G, O] = meshgrid(giorni_ext, ore_ext);
qF2 = length(thetalsF2);

phiF2_ext = [cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:)), cos(8*w*O(:)), sin(8*w*O(:))];
phi1_ext = [ones(length(G)*length(G), 1) , G(:)];
stima_consumi_trend = phi1_ext * thetals1;

stima_consumi_extF2 = phiF2_ext * thetalsF2 + stima_consumi_trend;
stima_consumi_matF2 = reshape(stima_consumi_extF2, size(G));

figure(2);
mesh(G, O, stima_consumi_matF2);
grid on
hold on
scatter3(giorni, ore, consumi, "o");
title("MODELLO DI FOURIER 2", 'FontSize', 15);
xlabel("Domeniche dell'anno", 'FontSize', 13);
ylabel("Ore", 'FontSize', 13);
zlabel("Consumi", 'FontSize', 13);

%VALIDAZIONE

tab_val = readtable('caricoDEhour.xlsx', 'Range', 'A8763:D17522');
mat_val = tab_val{:,:};
solo_domeniche_val = mat_val(mat_val(:,3)==1,:);
consumiVal = solo_domeniche_val(:,4);
giorni_val = (linspace(1, 365, n))';

%MODELLO DI PRIMO ORDINE PER IL TREND VAL

phi1_val = [ones(n, 1), giorni_val];
[thetals1_val, devthetals1_val] = lscov(phi1_val, consumiVal);
epsilon1_val = consumiVal - phi1_val * thetals1_val;
stima_consumi1_val = phi1_val * thetals1_val;
ssr1_val = epsilon1_val' * epsilon1_val;
q1_val = length(thetals1_val);

consumi_nuovi_val = consumiVal - stima_consumi1_val;

%MODELLO F2 VAL
phiF2Val = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
epsilonF2Val = consumiVal - ((phiF2Val) * thetalsF2 + stima_consumi1_val);
stima_consumiF2Val = phiF2Val * thetalsF2 + stima_consumi1_val;
ssrF2Val = epsilonF2Val' * epsilonF2Val;
qF2Val = length(thetalsF2);

phiF2_ext_val = [cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:)), cos(8*w*O(:)), sin(8*w*O(:))];
phi1_ext_val = [ones(length(G)*length(G), 1) , G(:)];
stima_consumi_trend = phi1_ext_val * thetals1_val;
stima_consumi_extF2_val = (phiF2_ext_val) * thetalsF2 + stima_consumi_trend;
stima_consumi_matF2_val = reshape(stima_consumi_extF2_val, size(G));

figure(9);
mesh(G, O, stima_consumi_matF2_val);
grid on
hold on
scatter3(giorni_val, ore, consumiVal, "o");
title("MODELLO DI FOURIER 2 VAL", 'FontSize', 15);
xlabel("Domeniche dell'anno", 'FontSize', 13);
ylabel("Ore", 'FontSize', 13);
zlabel("Consumi", 'FontSize', 13);

%MODELLI DI F2 CON NUMERI DIVERSI DI ARMONICHE.
%4 ARMONICHE
phiF2_4 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore)];
[thetalsF2_4, devthetalsF2_4] = lscov(phiF2_4, consumi_nuovi);
epsilonF2_4 = consumi_nuovi - phiF2_4 * thetalsF2_4;
ssrF2_4 = epsilonF2_4' * epsilonF2_4;
qF2_4 = length(thetalsF2_4);

phiF2Val4 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore)];
epsilonF2Val4 = consumi_nuovi_val - (phiF2Val4) * thetalsF2_4;
ssrF2Val4 = epsilonF2Val4' * epsilonF2Val4;

%6 ARMONICHE
phiF2_6 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*ore), sin(2*w*ore)];
[thetalsF2_6, devthetalsF2_6] = lscov(phiF2_6, consumi_nuovi);
epsilonF2_6 = consumi_nuovi - phiF2_6 * thetalsF2_6;
ssrF2_6 = epsilonF2_6' * epsilonF2_6;
qF2_6 = length(thetalsF2_6);

phiF2Val6 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*ore), sin(2*w*ore)];
epsilonF2Val6 = consumi_nuovi_val - (phiF2Val6) * thetalsF2_6;
ssrF2Val6 = epsilonF2Val6' * epsilonF2Val6;

%8 ARMONICHE
phiF2_8 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore)];
[thetalsF2_8, devthetalsF2_8] = lscov(phiF2_8, consumi_nuovi);
epsilonF2_8 = consumi_nuovi - phiF2_8 * thetalsF2_8;
ssrF2_8 = epsilonF2_8' * epsilonF2_8;
qF2_8 = length(thetalsF2_8);

phiF2Val8 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore)];
epsilonF2Val8 = consumi_nuovi_val - (phiF2Val8) * thetalsF2_8;
ssrF2Val8 = epsilonF2Val8' * epsilonF2Val8;


%10 ARMONICHE
phiF2_10 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*ore), sin(3*w*ore)];
[thetalsF2_10, devthetalsF2_10] = lscov(phiF2_10, consumi_nuovi);
epsilonF2_10 = consumi_nuovi - phiF2_10 * thetalsF2_10;
ssrF2_10 = epsilonF2_10' * epsilonF2_10;
qF2_10 = length(thetalsF2_10);

phiF2Val10 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*ore), sin(3*w*ore)];
epsilonF2Val10 = consumi_nuovi_val - (phiF2Val10) * thetalsF2_10;
ssrF2Val10 = epsilonF2Val10' * epsilonF2Val10;

%12 ARMONICHE
phiF2_12 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore)];
[thetalsF2_12, devthetalsF2_12] = lscov(phiF2_12, consumi_nuovi);
epsilonF2_12 = consumi_nuovi - phiF2_12 * thetalsF2_12;
ssrF2_12 = epsilonF2_12' * epsilonF2_12;
qF2_12 = length(thetalsF2_12);

phiF2Val12 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore)];
epsilonF2Val12 = consumi_nuovi_val - (phiF2Val12) * thetalsF2_12;
ssrF2Val12 = epsilonF2Val12' * epsilonF2Val12;

%14 ARMONICHE
phiF2_14 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*ore), sin(4*w*ore)];
[thetalsF2_14, devthetalsF2_14] = lscov(phiF2_14, consumi_nuovi);
epsilonF2_14 = consumi_nuovi - phiF2_14 * thetalsF2_14;
ssrF2_14 = epsilonF2_14' * epsilonF2_14;
qF2_14 = length(thetalsF2_14);

phiF2Val14 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*ore), sin(4*w*ore)];
epsilonF2Val14 = consumi_nuovi_val - (phiF2Val14) * thetalsF2_14;
ssrF2Val14 = epsilonF2Val14' * epsilonF2Val14;

%16 ARMONICHE
phiF2_16 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore)];
[thetalsF2_16, devthetalsF2_16] = lscov(phiF2_16, consumi_nuovi);
epsilonF2_16 = consumi_nuovi - phiF2_16 * thetalsF2_16;
ssrF2_16 = epsilonF2_16' * epsilonF2_16;
qF2_16 = length(thetalsF2_16);

phiF2Val16 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore)];
epsilonF2Val16 = consumi_nuovi_val - (phiF2Val16) * thetalsF2_16;
ssrF2Val16 = epsilonF2Val16' * epsilonF2Val16;

%18 ARMONICHE
phiF2_18 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*ore), sin(5*w*ore)];
[thetalsF2_18, devthetalsF2_18] = lscov(phiF2_18, consumi_nuovi);
epsilonF2_18 = consumi_nuovi - phiF2_18 * thetalsF2_18;
ssrF2_18 = epsilonF2_18' * epsilonF2_18;
qF2_18 = length(thetalsF2_18);

phiF2Val18 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*ore), sin(5*w*ore)];
epsilonF2Val18 = consumi_nuovi_val - (phiF2Val18) * thetalsF2_18;
ssrF2Val18 = epsilonF2Val18' * epsilonF2Val18;

%20 ARMONICHE
phiF2_20 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore)];
[thetalsF2_20, devthetalsF2_20] = lscov(phiF2_20, consumi_nuovi);
epsilonF2_20 = consumi_nuovi - phiF2_20 * thetalsF2_20;
ssrF2_20 = epsilonF2_20' * epsilonF2_20;
qF2_20 = length(thetalsF2_20);

phiF2Val20 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore)];
epsilonF2Val20 = consumi_nuovi_val - (phiF2Val20) * thetalsF2_20;
ssrF2Val20 = epsilonF2Val20' * epsilonF2Val20;

%22 ARMONICHE
phiF2_22 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*ore), sin(6*w*ore)];
[thetalsF2_22, devthetalsF2_22] = lscov(phiF2_22, consumi_nuovi);
epsilonF2_22 = consumi_nuovi - phiF2_22 * thetalsF2_22;
ssrF2_22 = epsilonF2_22' * epsilonF2_22;
qF2_22 = length(thetalsF2_22);

phiF2Val22 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*ore), sin(6*w*ore)];
epsilonF2Val22 = consumi_nuovi_val - (phiF2Val22) * thetalsF2_22;
ssrF2Val22 = epsilonF2Val22' * epsilonF2Val22;

%24 ARMONICHE
phiF2_24 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore)];
[thetalsF2_24, devthetalsF2_24] = lscov(phiF2_24, consumi_nuovi);
epsilonF2_24 = consumi_nuovi - phiF2_24 * thetalsF2_24;
ssrF2_24 = epsilonF2_24' * epsilonF2_24;
qF2_24 = length(thetalsF2_24);

phiF2Val24 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore),cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore)];
epsilonF2Val24 = consumi_nuovi_val - (phiF2Val24) * thetalsF2_24;
ssrF2Val24 = epsilonF2Val24' * epsilonF2Val24;

%26 ARMONICHE
phiF2_26 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*ore), sin(7*w*ore)];
[thetalsF2_26, devthetalsF2_26] = lscov(phiF2_26, consumi_nuovi);
epsilonF2_26 = consumi_nuovi - phiF2_26 * thetalsF2_26;
ssrF2_26 = epsilonF2_26' * epsilonF2_26;
qF2_26 = length(thetalsF2_26);

phiF2Val26 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*ore), sin(7*w*ore)];
epsilonF2Val26 = consumi_nuovi_val - (phiF2Val26) * thetalsF2_26;
ssrF2Val26 = epsilonF2Val26' * epsilonF2Val26;

%28 ARMONICHE
phiF2_28 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore)];
[thetalsF2_28, devthetalsF2_28] = lscov(phiF2_28, consumi_nuovi);
epsilonF2_28 = consumi_nuovi - phiF2_28 * thetalsF2_28;
ssrF2_28 = epsilonF2_28' * epsilonF2_28;
qF2_28 = length(thetalsF2_28);

phiF2Val28 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore)];
epsilonF2Val28 = consumi_nuovi_val - (phiF2Val28) * thetalsF2_28;
ssrF2Val28 = epsilonF2Val28' * epsilonF2Val28;

%30 ARMONICHE
phiF2_30 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
[thetalsF2_30, devthetalsF2_30] = lscov(phiF2_30, consumi_nuovi);
epsilonF2_30 = consumi_nuovi - phiF2_30 * thetalsF2_30;
ssrF2_30 = epsilonF2_30' * epsilonF2_30;
qF2_30 = length(thetalsF2_30);

phiF2Val30 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*ore), sin(8*w*ore)];
epsilonF2Val30 = consumi_nuovi_val - (phiF2Val30) * thetalsF2_30;
ssrF2Val30 = epsilonF2Val30' * epsilonF2Val30;

%32 ARMONICHE
phiF2_32 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore)];
[thetalsF2_32, devthetalsF2_32] = lscov(phiF2_32, consumi_nuovi);
epsilonF2_32 = consumi_nuovi - phiF2_32 * thetalsF2_32;
ssrF2_32 = epsilonF2_32' * epsilonF2_32;
qF2_32 = length(thetalsF2_32);

phiF2Val32 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore)];
epsilonF2Val32 = consumi_nuovi_val - (phiF2Val32) * thetalsF2_32;
ssrF2Val32 = epsilonF2Val32' * epsilonF2Val32;

%34 ARMONICHE
phiF2_34 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*ore), sin(9*w*ore)];
[thetalsF2_34, devthetalsF2_34] = lscov(phiF2_34, consumi_nuovi);
epsilonF2_34 = consumi_nuovi - phiF2_34 * thetalsF2_34;
ssrF2_34 = epsilonF2_34' * epsilonF2_34;
qF2_34 = length(thetalsF2_34);

phiF2Val34 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*ore), sin(9*w*ore)];
epsilonF2Val34 = consumi_nuovi_val - (phiF2Val34) * thetalsF2_34;
ssrF2Val34 = epsilonF2Val34' * epsilonF2Val34;

%36 ARMONICHE
phiF2_36 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore)];
[thetalsF2_36, devthetalsF2_36] = lscov(phiF2_36, consumi_nuovi);
epsilonF2_36 = consumi_nuovi - phiF2_36 * thetalsF2_36;
ssrF2_36 = epsilonF2_36' * epsilonF2_36;
qF2_36 = length(thetalsF2_36);

phiF2Val36 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore)];
epsilonF2Val36 = consumi_nuovi_val - (phiF2Val36) * thetalsF2_36;
ssrF2Val36 = epsilonF2Val36' * epsilonF2Val36;

%38 ARMONICHE
phiF2_38 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*ore), sin(10*w*ore)];
[thetalsF2_38, devthetalsF2_38] = lscov(phiF2_38, consumi_nuovi);
epsilonF2_38 = consumi_nuovi - phiF2_38 * thetalsF2_38;
ssrF2_38 = epsilonF2_38' * epsilonF2_38;
qF2_38 = length(thetalsF2_38);

phiF2Val38 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*ore), sin(10*w*ore)];
epsilonF2Val38 = consumi_nuovi_val - (phiF2Val38) * thetalsF2_38;
ssrF2Val38 = epsilonF2Val38' * epsilonF2Val38;

%40 ARMONICHE
phiF2_40 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore)];
[thetalsF2_40, devthetalsF2_40] = lscov(phiF2_40, consumi_nuovi);
epsilonF2_40 = consumi_nuovi - phiF2_40 * thetalsF2_40;
ssrF2_40 = epsilonF2_40' * epsilonF2_40;
qF2_40 = length(thetalsF2_40);

phiF2Val40 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore)];
epsilonF2Val40 = consumi_nuovi_val - (phiF2Val40) * thetalsF2_40;
ssrF2Val40 = epsilonF2Val40' * epsilonF2Val40;

%42 ARMONICHE
phiF2_42 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*ore), sin(11*w*ore)];
[thetalsF2_42, devthetalsF2_42] = lscov(phiF2_42, consumi_nuovi);
epsilonF2_42 = consumi_nuovi - phiF2_42 * thetalsF2_42;
ssrF2_42 = epsilonF2_42' * epsilonF2_42;
qF2_42 = length(thetalsF2_42);

phiF2Val42 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*ore), sin(11*w*ore)];
epsilonF2Val42 = consumi_nuovi_val - (phiF2Val42) * thetalsF2_42;
ssrF2Val42 = epsilonF2Val42' * epsilonF2Val42;

%44 ARMONICHE
phiF2_44 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore)];
[thetalsF2_44, devthetalsF2_44] = lscov(phiF2_44, consumi_nuovi);
epsilonF2_44 = consumi_nuovi - phiF2_44 * thetalsF2_44;
ssrF2_44 = epsilonF2_44' * epsilonF2_44;
qF2_44 = length(thetalsF2_44);

phiF2Val44 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore)];
epsilonF2Val44 = consumi_nuovi_val - (phiF2Val44) * thetalsF2_44;
ssrF2Val44 = epsilonF2Val44' * epsilonF2Val44;

%46 ARMONICHE
phiF2_46 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*ore), sin(12*w*ore)];
[thetalsF2_46, devthetalsF2_46] = lscov(phiF2_46, consumi_nuovi);
epsilonF2_46 = consumi_nuovi - phiF2_46 * thetalsF2_46;
ssrF2_46 = epsilonF2_46' * epsilonF2_46;
qF2_46 = length(thetalsF2_46);

phiF2Val46 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*ore), sin(12*w*ore)];
epsilonF2Val46 = consumi_nuovi_val - (phiF2Val46) * thetalsF2_46;
ssrF2Val46 = epsilonF2Val46' * epsilonF2Val46;


%48 ARMONICHE
phiF2_48 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore)];
[thetalsF2_48, devthetalsF2_48] = lscov(phiF2_48, consumi_nuovi);
epsilonF2_48 = consumi_nuovi - phiF2_48 * thetalsF2_48;
ssrF2_48 = epsilonF2_48' * epsilonF2_48;
qF2_48 = length(thetalsF2_48);

phiF2Val48 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore)];
epsilonF2Val48 = consumi_nuovi_val - (phiF2Val48) * thetalsF2_48;
ssrF2Val48 = epsilonF2Val48' * epsilonF2Val48;

%50 ARMONICHE
phiF2_50 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*ore), sin(13*w*ore)];
[thetalsF2_50, devthetalsF2_50] = lscov(phiF2_50, consumi_nuovi);
epsilonF2_50 = consumi_nuovi - phiF2_50 * thetalsF2_50;
ssrF2_50 = epsilonF2_50' * epsilonF2_50;
qF2_50 = length(thetalsF2_50);

phiF2Val50 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*ore), sin(13*w*ore)];
epsilonF2Val50 = consumi_nuovi_val - (phiF2Val50) * thetalsF2_50;
ssrF2Val50 = epsilonF2Val50' * epsilonF2Val50;

%52 ARMONICHE
phiF2_52 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni), sin(13*w*giorni), cos(13*w*ore), sin(13*w*ore)];
[thetalsF2_52, devthetalsF2_52] = lscov(phiF2_52, consumi_nuovi);
epsilonF2_52 = consumi_nuovi - phiF2_52 * thetalsF2_52;
ssrF2_52 = epsilonF2_52' * epsilonF2_52;
qF2_52 = length(thetalsF2_52);

phiF2Val52 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni_val), sin(13*w*giorni_val), cos(13*w*ore), sin(13*w*ore)];
epsilonF2Val52 = consumi_nuovi_val - (phiF2Val52) * thetalsF2_52;
ssrF2Val52 = epsilonF2Val52' * epsilonF2Val52;

%54 ARMONICHE
phiF2_54 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni), sin(13*w*giorni), cos(13*w*ore), sin(13*w*ore), cos(14*w*ore), sin(14*w*ore)];
[thetalsF2_54, devthetalsF2_54] = lscov(phiF2_54, consumi_nuovi);
epsilonF2_54 = consumi_nuovi - phiF2_54 * thetalsF2_54;
ssrF2_54 = epsilonF2_54' * epsilonF2_54;
qF2_54 = length(thetalsF2_54);

phiF2Val54 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni_val), sin(13*w*giorni_val), cos(13*w*ore), sin(13*w*ore), cos(14*w*ore), sin(14*w*ore)];
epsilonF2Val54 = consumi_nuovi_val - (phiF2Val54) * thetalsF2_54;
ssrF2Val54 = epsilonF2Val54' * epsilonF2Val54;

%56 ARMONICHE
phiF2_56 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni), sin(13*w*giorni), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni), sin(14*w*giorni), cos(14*w*ore), sin(14*w*ore)];
[thetalsF2_56, devthetalsF2_56] = lscov(phiF2_56, consumi_nuovi);
epsilonF2_56 = consumi_nuovi - phiF2_56 * thetalsF2_56;
ssrF2_56 = epsilonF2_56' * epsilonF2_56;
qF2_56 = length(thetalsF2_56);

phiF2Val56 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni_val), sin(13*w*giorni_val), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni_val), sin(14*w*giorni_val), cos(14*w*ore), sin(14*w*ore)];
epsilonF2Val56 = consumi_nuovi_val - (phiF2Val56) * thetalsF2_56;
ssrF2Val56 = epsilonF2Val56' * epsilonF2Val56;

%58 ARMONICHE
phiF2_58 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni), sin(13*w*giorni), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni), sin(14*w*giorni), cos(14*w*ore), sin(14*w*ore), cos(15*w*ore), sin(15*w*ore)];
[thetalsF2_58, devthetalsF2_58] = lscov(phiF2_58, consumi_nuovi);
epsilonF2_58 = consumi_nuovi - phiF2_58 * thetalsF2_58;
ssrF2_58 = epsilonF2_58' * epsilonF2_58;
qF2_58 = length(thetalsF2_58);

phiF2Val58 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni_val), sin(13*w*giorni_val), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni_val), sin(14*w*giorni_val), cos(14*w*ore), sin(14*w*ore), cos(15*w*ore), sin(15*w*ore)];
epsilonF2Val58 = consumi_nuovi_val - (phiF2Val58) * thetalsF2_58;
ssrF2Val58 = epsilonF2Val58' * epsilonF2Val58;

%60 ARMONICHE
phiF2_60 = [cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni), sin(8*w*giorni), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni), sin(9*w*giorni), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni), sin(10*w*giorni), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni), sin(11*w*giorni), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni), sin(12*w*giorni), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni), sin(13*w*giorni), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni), sin(14*w*giorni), cos(14*w*ore), sin(14*w*ore), cos(15*w*giorni), sin(15*w*giorni), cos(15*w*ore), sin(15*w*ore)];
[thetalsF2_60, devthetalsF2_60] = lscov(phiF2_60, consumi_nuovi);
epsilonF2_60 = consumi_nuovi - phiF2_60 * thetalsF2_60;
ssrF2_60 = epsilonF2_60' * epsilonF2_60;
qF2_60 = length(thetalsF2_60);

phiF2Val60 = [cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore), cos(8*w*giorni_val), sin(8*w*giorni_val), cos(8*w*ore), sin(8*w*ore), cos(9*w*giorni_val), sin(9*w*giorni_val), cos(9*w*ore), sin(9*w*ore), cos(10*w*giorni_val), sin(10*w*giorni_val), cos(10*w*ore), sin(10*w*ore), cos(11*w*giorni_val), sin(11*w*giorni_val), cos(11*w*ore), sin(11*w*ore), cos(12*w*giorni_val), sin(12*w*giorni_val), cos(12*w*ore), sin(12*w*ore), cos(13*w*giorni_val), sin(13*w*giorni_val), cos(13*w*ore), sin(13*w*ore), cos(14*w*giorni_val), sin(14*w*giorni_val), cos(14*w*ore), sin(14*w*ore), cos(15*w*giorni_val), sin(15*w*giorni_val), cos(15*w*ore), sin(15*w*ore)];
epsilonF2Val60 = consumi_nuovi_val - (phiF2Val60) * thetalsF2_60;
ssrF2Val60 = epsilonF2Val60' * epsilonF2Val60;

%PLOT DEGLI SSR
ssrVal = [ssrF2Val4, ssrF2Val6, ssrF2Val8, ssrF2Val10, ssrF2Val12, ssrF2Val14, ssrF2Val16, ssrF2Val18, ssrF2Val20, ssrF2Val22, ssrF2Val24, ssrF2Val26, ssrF2Val28, ssrF2Val30, ssrF2Val32, ssrF2Val34, ssrF2Val36, ssrF2Val38, ssrF2Val40, ssrF2Val42, ssrF2Val44, ssrF2Val46, ssrF2Val48, ssrF2Val50, ssrF2Val52, ssrF2Val54, ssrF2Val56, ssrF2Val58, ssrF2Val60];
ssr = [ssrF2_4, ssrF2_6, ssrF2_8, ssrF2_10, ssrF2_12, ssrF2_14, ssrF2_16, ssrF2_18, ssrF2_20, ssrF2_22, ssrF2_24, ssrF2_26, ssrF2_28, ssrF2_30, ssrF2_32, ssrF2_34, ssrF2_36, ssrF2_38, ssrF2_40, ssrF2_42, ssrF2_44, ssrF2_46, ssrF2_48, ssrF2_50, ssrF2_52, ssrF2_54, ssrF2_56, ssrF2_58, ssrF2_60];
x = linspace(4, 60, 29);
figure(3)
plot(x, ssr);
grid on
hold on
plot(x, ssrVal);
legend('modello di identificazione','modello di validazione');
legend('boxoff');
xlabel('armoniche', 'FontSize', 15);
ylabel('SSR', 'FontSize', 15);

%TEST AIC
aicF2_4 = (2*qF2_4)/n + log(ssrF2_4);
aicF2_6 = (2*qF2_6)/n + log(ssrF2_6);
aicF2_8 = (2*qF2_8)/n + log(ssrF2_8);
aicF2_10 = (2*qF2_10)/n + log(ssrF2_10);
aicF2_12 = (2*qF2_12)/n + log(ssrF2_12);
aicF2_14 = (2*qF2_14)/n + log(ssrF2_14);
aicF2_16 = (2*qF2_16)/n + log(ssrF2_16);
aicF2_18 = (2*qF2_18)/n + log(ssrF2_18);
aicF2_20 = (2*qF2_20)/n + log(ssrF2_20);
aicF2_22 = (2*qF2_22)/n + log(ssrF2_22);
aicF2_24 = (2*qF2_24)/n + log(ssrF2_24);
aicF2_26 = (2*qF2_26)/n + log(ssrF2_26);
aicF2_28 = (2*qF2_28)/n + log(ssrF2_28);
aicF2_30 = (2*qF2_30)/n + log(ssrF2_30);
aicF2_32 = (2*qF2_32)/n + log(ssrF2_32);
aicF2_34 = (2*qF2_34)/n + log(ssrF2_34);
aicF2_36 = (2*qF2_36)/n + log(ssrF2_36);
aicF2_38 = (2*qF2_38)/n + log(ssrF2_38);
aicF2_40 = (2*qF2_40)/n + log(ssrF2_40);
aicF2_42 = (2*qF2_42)/n + log(ssrF2_42);
aicF2_44 = (2*qF2_44)/n + log(ssrF2_44);
aicF2_46 = (2*qF2_46)/n + log(ssrF2_46);
aicF2_48 = (2*qF2_48)/n + log(ssrF2_48);
aicF2_50 = (2*qF2_50)/n + log(ssrF2_50);
aicF2_52 = (2*qF2_52)/n + log(ssrF2_52);
aicF2_54 = (2*qF2_54)/n + log(ssrF2_54);
aicF2_56 = (2*qF2_56)/n + log(ssrF2_56);
aicF2_58 = (2*qF2_58)/n + log(ssrF2_58);
aicF2_60 = (2*qF2_60)/n + log(ssrF2_60);

%TEST AIC VAL
aicF2Val4 = (2*qF2_4)/n + log(ssrF2Val4);
aicF2Val6 = (2*qF2_6)/n + log(ssrF2Val6);
aicF2Val8 = (2*qF2_8)/n + log(ssrF2Val8);
aicF2Val10 = (2*qF2_10)/n + log(ssrF2Val10);
aicF2Val12 = (2*qF2_12)/n + log(ssrF2Val12);
aicF2Val14 = (2*qF2_14)/n + log(ssrF2Val14);
aicF2Val16 = (2*qF2_16)/n + log(ssrF2Val16);
aicF2Val18 = (2*qF2_18)/n + log(ssrF2Val18);
aicF2Val20 = (2*qF2_20)/n + log(ssrF2Val20);
aicF2Val22 = (2*qF2_22)/n + log(ssrF2Val22);
aicF2Val24 = (2*qF2_24)/n + log(ssrF2Val24);
aicF2Val26 = (2*qF2_26)/n + log(ssrF2Val26);
aicF2Val28 = (2*qF2_28)/n + log(ssrF2Val28);
aicF2Val30 = (2*qF2_30)/n + log(ssrF2Val30);
aicF2Val32 = (2*qF2_32)/n + log(ssrF2Val32);
aicF2Val34 = (2*qF2_34)/n + log(ssrF2Val34);
aicF2Val36 = (2*qF2_36)/n + log(ssrF2Val36);
aicF2Val38 = (2*qF2_38)/n + log(ssrF2Val38);
aicF2Val40 = (2*qF2_40)/n + log(ssrF2Val40);
aicF2Val42 = (2*qF2_42)/n + log(ssrF2Val42);
aicF2Val44 = (2*qF2_44)/n + log(ssrF2Val44);
aicF2Val46 = (2*qF2_46)/n + log(ssrF2Val46);
aicF2Val48 = (2*qF2_48)/n + log(ssrF2Val48);
aicF2Val50 = (2*qF2_50)/n + log(ssrF2Val50);
aicF2Val52 = (2*qF2_52)/n + log(ssrF2Val52);
aicF2Val54 = (2*qF2_54)/n + log(ssrF2Val54);
aicF2Val56 = (2*qF2_56)/n + log(ssrF2Val56);
aicF2Val58 = (2*qF2_58)/n + log(ssrF2Val58);
aicF2Val60 = (2*qF2_60)/n + log(ssrF2Val60);


aic = [aicF2_4, aicF2_6, aicF2_8, aicF2_10, aicF2_12, aicF2_14, aicF2_16, aicF2_18, aicF2_20, aicF2_22, aicF2_24, aicF2_26, aicF2_28, aicF2_30, aicF2_32, aicF2_34, aicF2_36, aicF2_38, aicF2_40, aicF2_42, aicF2_44, aicF2_46, aicF2_48, aicF2_50, aicF2_52, aicF2_54, aicF2_56, aicF2_58, aicF2_60];
aicVal = [aicF2Val4, aicF2Val6, aicF2Val8, aicF2Val10, aicF2Val12, aicF2Val14, aicF2Val16, aicF2Val18, aicF2Val20, aicF2Val22, aicF2Val24, aicF2Val26, aicF2Val28, aicF2Val30, aicF2Val32, aicF2Val34, aicF2Val36, aicF2Val38, aicF2Val40, aicF2Val42, aicF2Val44, aicF2Val46, aicF2Val48, aicF2Val50, aicF2Val52, aicF2Val54, aicF2Val56, aicF2Val58, aicF2Val60];

figure(4)
plot(x, aic);
grid on
hold on
plot(x, aicVal);
title('TEST AIC', 'FontSize', 15);
legend('modello di identificazione','modello di validazione');
legend('boxoff');
xlabel('armoniche');
ylabel('AIC');

