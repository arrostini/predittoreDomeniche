clc
close all
clear all

tab1 = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
tab2 = readtable('caricoDEhour.xlsx', 'Range','A8763:D17522');
mat1 = tab1{:,:};
mat2 = tab2{:,:};

solo_domeniche1 = mat1(mat1(:,3)==1,:); %prendo le righe dove la terza colonna é uguale a 1

consumi1= solo_domeniche1(:,4);
giorni1= solo_domeniche1(:,1);
ore1= solo_domeniche1(:,2);

solo_domeniche2 = mat2(mat2(:,3)==1,:);
consumi2= solo_domeniche2(:,4);

n1 = length(consumi1);
phi1 = [ones(n1, 1), giorni1];
[thetals1, devthetals1] = lscov(phi1, consumi1);
stima_consumi1 = phi1 * thetals1;
consumi1 = consumi1 - stima_consumi1;

n2 = length(consumi2);
phi2 = [ones(n2, 1), giorni1];
[thetals2, devthetals2] = lscov(phi2, consumi2);
stima_consumi2 = phi2 * thetals2;
consumi2 = consumi2 - stima_consumi2;

consumi2 = consumi2';
input = [consumi1,giorni1,ore1]';

net = feedforwardnet(30);

net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.3;

[net,tr] = train(net,input,consumi2);
output = net(input);
output = output';

figure(1)
plot3(giorni1,ore1,consumi1,"o");
grid on;
hold on;
plot3(giorni1,ore1,consumi2,"o",'Color','g');
hold on;
plot3(giorni1,ore1,output,"o",'Color','r');
legend("dati primo anno","dati secondo anno","dati stimati dalla rete")

epsilon1 = output-consumi1;
ssr_1anno = epsilon1'*epsilon1;
epsilon2 = output-consumi2';
ssr_2anno = epsilon2'*epsilon2;

x = linspace(1,52,1248);
figure(2)
plot(x,consumi1);
figure(3)
plot(x,output);

tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:);
consumi = solo_domeniche(:, 4);
ore = solo_domeniche(:, 2);
n = length(consumi);
giorni = (linspace(1, 104, n))';
phi = [ones(n, 1), giorni];
[thetals, devthetals] = lscov(phi, consumi);
figure(10)
plot(giorni, consumi);
hold on

giorni = (linspace(1, 156, n*3/2))';

trend = thetals(1, :) + giorni.*thetals(2,:);

plot(giorni, trend, 'k');
hold on

trend_previsto = trend(104*24+1:156*24,1);
previsione = trend_previsto + output;
giorni = (linspace(104, 156, n/2))';
plot(giorni, previsione, 'r');

mat_previsione = reshape(previsione,[24,52]);
xlswrite('reti_neurali.xlsx',mat_previsione);
