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

%MODELLO DI PRIMO ORDINE PER IL TREND

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
grid on
hold off;

%STIMA FOURIER 2
w = 2 * pi / 365;
phiF2 = [ones(n,1), cos(w*giorni), sin(w*giorni), cos(w*ore), sin(w*ore), cos(2*w*giorni), sin(2*w*giorni), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni), sin(3*w*giorni), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni), sin(4*w*giorni), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni), sin(5*w*giorni), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni), sin(6*w*giorni), cos(6*w*ore), sin(6*w*ore),  cos(7*w*giorni), sin(7*w*giorni), cos(7*w*ore), sin(7*w*ore)];
[thetalsF2, devthetalsF2] = lscov(phiF2, consumi_nuovi);
epsilonF2 = consumi_nuovi - phiF2 * thetalsF2;
stima_consumiF2 = phiF2 * thetalsF2;
ssrF2 = epsilonF2' * epsilonF2;

giorni_ext = linspace(min(giorni), max(giorni), 100);
ore_ext = linspace(min(ore), max(ore),100);
n1 = length(giorni_ext) * length(ore_ext);
[G, O] = meshgrid(giorni_ext, ore_ext);
qF2 = length(thetalsF2);

phiF2_ext = [ones(n1,1), cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:))];
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
phiF2Val = [ones(n,1), cos(w*giorni_val), sin(w*giorni_val), cos(w*ore), sin(w*ore), cos(2*w*giorni_val), sin(2*w*giorni_val), cos(2*w*ore), sin(2*w*ore), cos(3*w*giorni_val), sin(3*w*giorni_val), cos(3*w*ore), sin(3*w*ore), cos(4*w*giorni_val), sin(4*w*giorni_val), cos(4*w*ore), sin(4*w*ore), cos(5*w*giorni_val), sin(5*w*giorni_val), cos(5*w*ore), sin(5*w*ore), cos(6*w*giorni_val), sin(6*w*giorni_val), cos(6*w*ore), sin(6*w*ore), cos(7*w*giorni_val), sin(7*w*giorni_val), cos(7*w*ore), sin(7*w*ore)];
epsilonF2Val = consumi_nuovi_val - (phiF2Val) * thetalsF2;
stima_consumiF2Val = phiF2Val * thetalsF2;
ssrF2Val = epsilonF2Val' * epsilonF2Val;
qF2Val = length(thetalsF2);

phiF2_ext_val = [ones(n1,1), cos(w*G(:)), sin(w*G(:)), cos(w*O(:)), sin(w*O(:)), cos(2*w*G(:)), sin(2*w*G(:)), cos(2*w*O(:)), sin(2*w*O(:)), cos(3*w*G(:)), sin(3*w*G(:)), cos(3*w*O(:)), sin(3*w*O(:)), cos(4*w*G(:)), sin(4*w*G(:)), cos(4*w*O(:)), sin(4*w*O(:)), cos(5*w*G(:)), sin(5*w*G(:)), cos(5*w*O(:)), sin(5*w*O(:)), cos(6*w*G(:)), sin(6*w*G(:)), cos(6*w*O(:)), sin(6*w*O(:)), cos(7*w*G(:)), sin(7*w*G(:)), cos(7*w*O(:)), sin(7*w*O(:))];
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