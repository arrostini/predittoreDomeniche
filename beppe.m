clc
close all
clear
 
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:);
consumi = solo_domeniche(:, 4);
ore = solo_domeniche(:, 2);
n = length(consumi);
giorni = (linspace(1, 730, n))';
phi = [ones(n, 1), giorni];
[thetals, devthetals] = lscov(phi, consumi);
plot(giorni, consumi);
hold on
giorni = (linspace(1, 1095, n*3/2))';
trend = thetals(1, :) + giorni.*thetals(2,:);
plot(giorni, trend, 'k');
hold on

trend_previsto = trend(104*24+1:156*24,1);

%Primo anno
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:); 
consumi_primo_anno = solo_domeniche(:,4);
giorni1 = solo_domeniche(:,1);
%Detrendizzo primo anno
n1 = length(consumi_primo_anno);
phi1 = [ones(n1, 1), giorni1];
[thetals1, devthetals1] = lscov(phi1, consumi_primo_anno);
epsilon1 = consumi_primo_anno - phi1 * thetals1;
stima_consumi1 = phi1 * thetals1;
ssr1 = epsilon1' * epsilon1;
q1 = length(thetals1);
consumi_nuovi_1 = consumi_primo_anno - stima_consumi1;

%Secondo anno
tab_2 = readtable('caricoDEhour.xlsx', 'Range', 'A8763:D17522');
mat_2 = tab_2{:,:};
solo_domeniche_2= mat_2(mat_2(:,3)==1,:);
consumi_secondo_anno = solo_domeniche_2(:,4);
giorni_2 = solo_domeniche_2(:,1);
%Detrendizzo secondo anno
n2 = length(consumi_secondo_anno);
phi2 = [ones(n2, 1), giorni_2];
[thetals2, devthetals2] = lscov(phi2, consumi_secondo_anno);
epsilon2 = consumi_secondo_anno - phi2 * thetals2;
stima_consumi2 = phi2 * thetals2;
ssr2 = epsilon2' * epsilon2;
q2 = length(thetals2);
consumi_nuovi_2 = consumi_secondo_anno - stima_consumi2;

media_consumi_detrendizzati = (consumi_nuovi_1 + consumi_nuovi_2)./2;
media_consumi = media_consumi_detrendizzati + trend_previsto; 

%Modello
wg = 2 * pi / 365;
wo = 2 * pi / 24;

ore= solo_domeniche(:,2);
phiFourier = [cos(wg*giorni1), sin(wg*giorni1), cos(wo*ore), sin(wo*ore), cos(2*wg*giorni1), sin(2*wg*giorni1), cos(2*wo*ore), sin(2*wo*ore), cos(3*wg*giorni1), sin(3*wg*giorni1), cos(3*wo*ore), sin(3*wo*ore), cos(4*wg*giorni1), sin(4*wg*giorni1), cos(4*wo*ore), sin(4*wo*ore), cos(5*wg*giorni1), sin(5*wg*giorni1), cos(5*wo*ore), sin(5*wo*ore), cos(6*wg*giorni1), sin(6*wg*giorni1), cos(6*wo*ore), sin(6*wo*ore),  cos(7*wg*giorni1), sin(7*wg*giorni1), cos(7*wo*ore), sin(7*wo*ore), cos(8*wo*ore), sin(8*wo*ore)];
[thetalsFourier, devthetalsFourier] = lscov(phiFourier, media_consumi_detrendizzati);
%epsilonFourier = consumi - (phiFourier * thetalsFourier + stima_consumi1);
stima_consumi = phiFourier * thetalsFourier + trend_previsto;
%ssrF2 = epsilonFourier' * epsilonFourier;

giorni = (linspace(731, 1095, n/2))';
plot(giorni, stima_consumi, 'r');

