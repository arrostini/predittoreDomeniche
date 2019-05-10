clc
close all
clear all


%%  Lettura del file 
tab1 = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
tab2 = readtable('caricoDEhour.xlsx', 'Range','A8763:D17522');
mat1 = tab1{:,:};
mat2 = tab2{:,:};

%% Isolamento dei dati utili
solo_domeniche1 = mat1(mat1(:,3)==1,:); %prendo le righe dove la terza colonna é uguale a 1 => domenica

consumi1= solo_domeniche1(:,4);
giorni1= solo_domeniche1(:,1);
ore1= solo_domeniche1(:,2);

solo_domeniche2 = mat2(mat2(:,3)==1,:);
consumi2= solo_domeniche2(:,4);

%% Detrendizzazione lineare dei due anni di dati
n1 = length(consumi1);
phi1 = [ones(n1, 1), giorni1];
[thetals1, devthetals1] = lscov(phi1, consumi1);
stima_consumi1 = phi1 * thetals1;
consumi1_detrend = consumi1 - stima_consumi1;

n2 = length(consumi2);
phi2 = [ones(n2, 1), giorni1];
[thetals2, devthetals2] = lscov(phi2, consumi2);
stima_consumi2 = phi2 * thetals2;
consumi2 = consumi2 - stima_consumi2;
consumi2_detrend = consumi2';


%% Modello neurale (primo anno come input e secondo anno come target)
input = [consumi1,giorni1,ore1]';


net = feedforwardnet(11);

net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.3;

[net,tr] = train(net,input,consumi2_detrend);
stima_detrended = net(input);
stima_detrended = stima_detrended';

%% Stima del trend di lungo periodo
solo_domeniche = [solo_domeniche1; solo_domeniche2];
consumi = solo_domeniche(:, 4);
ore = solo_domeniche(:, 2);
n = length(consumi);
giorni = (linspace(1, 104, n))';
phi = [ones(n, 1), giorni];
[thetals, devthetals] = lscov(phi, consumi);
giorni_3anni = (linspace(1, 156, n*3/2))';
trend = thetals(1, :) + giorni_3anni.*thetals(2,:);  % retta del trend, y= mx + q: q= thetals(1), m= thetals(2)

%% Previsione finale ottenuta sommando modello detrendizzato a trend previsto
trend_previsto = trend(104*24+1:156*24,1);
stima_finale = trend_previsto + stima_detrended;

%% Plot previsione
figure(1)
plot(giorni, consumi);
hold on

giorni_anno3 = (linspace(104, 156, n/2))';
plot(giorni_anno3, stima_finale, 'r');
hold on

plot(giorni_3anni, trend, 'k');

%% Indicatori di performance
epsilon1 = stima_detrended-consumi1_detrend;
ssr_1anno = epsilon1'*epsilon1;
epsilon2 = stima_detrended-consumi2_detrend';
ssr_2anno = epsilon2'*epsilon2;

mse_training = ssr_1anno /1024;
rmsd_training = sqrt(mse_training);
range_training = (max(consumi1)-min(consumi1));
nrmsd_range_training = (rmsd_training / range_training ) *100;
nrmsd_media_training = (rmsd_training / (mean(consumi1))) *100;
mae_training= mean(abs(epsilon1));

mse_target = ssr_2anno /1024;
rmsd_target = sqrt(mse_target);
range_target = (max(consumi2)-min(consumi2));
nrmsd_range_target = (rmsd_target / range_target ) *100;
nrmsd_media_target = (rmsd_target / (mean(consumi2))) *100;
mae_target= mean(abs(epsilon2));

%% Plot degli indicatori di performance
figure(2)
histogram(epsilon1)
ylabel("Istanze")
xlabel("Errore")
figure(3)
histogram(abs(((epsilon1)/mean(consumi1))*100));
ylabel("Istanze")
xlabel("Errore percentuale rispetto al range")

%% Salvataggio della stima del terzo anno su file
mat_previsione = reshape(stima_finale,[24,52]);
xlswrite('reti_neurali.xlsx',mat_previsione);