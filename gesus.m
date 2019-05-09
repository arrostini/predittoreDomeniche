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
ssr = 0;
for i = 1:1248
    ssr = ssr+(output(i)-consumi2(i))^2;
end

