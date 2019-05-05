clc
close all
clear
 
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:);
mediaOraria= zeros(1,24);
for i = 1:24
    mediaOraria(i) = mean(solo_domeniche(solo_domeniche(:,2)==i,4));
end


mediaOrariaDetrended = mediaOraria - mean(mediaOraria);
bar(mediaOrariaDetrended);
hold on

ore=1:1:24;
ore=ore';
w2 = 2 * pi / 24;
phiF = [ cos(w2*ore), sin(w2*ore), ...
     cos(2*w2*ore), sin(2*w2*ore), ...
     cos(3*w2*ore), sin(3*w2*ore), ...
     cos(4*w2*ore), sin(4*w2*ore), ...
     cos(5*w2*ore), sin(5*w2*ore), ...
     cos(6*w2*ore), sin(6*w2*ore), ...
     cos(7*w2*ore), sin(7*w2*ore), ...
     cos(8*w2*ore), sin(8*w2*ore), ...
     cos(9*w2*ore), sin(9*w2*ore)
    ];
[thetalsF, devthetalsF] = lscov(phiF, mediaOrariaDetrended');
consumiOrariModel= phiF * thetalsF;
epsilonF = mediaOrariaDetrended' - (phiF * thetalsF);
ssrF = epsilonF' * epsilonF;
figure(1)
plot(1:1:24, consumiOrariModel);

 
tab = readtable('caricoDEhour.xlsx', 'Range','A8763:D17522');
mat = tab{:,:};
solo_domenicheVal = mat(mat(:,3)==1,:);
mediaOrariaVal= zeros(1,24);
for i = 1:24
    mediaOrariaVal(i) = mean(solo_domenicheVal(solo_domenicheVal(:,2)==i,4));
end

mediaOrariaDetrendedVal = mediaOrariaVal - mean(mediaOrariaVal);
epsilonF2Val = mediaOrariaDetrendedVal' - consumiOrariModel;
ssrF2Val = epsilonF2Val' * epsilonF2Val;

consumiDomenicali = zeros(1,52);
for i= 1:52
    for j=1:24
        consumiDomenicali(i)= consumiDomenicali(i) + solo_domeniche((i-1)*24+j,4);
    end
end

consumiDomenicali = consumiDomenicali/24;

domeniche = 1:1:52;
w3 = 2 * pi / 365;
phiDetrend = [ones(52,1), domeniche'];
[thetalsDetrend, devthetalsDetrend] = lscov(phiDetrend, consumiDomenicali');
consumiDomenicaliDetrend = consumiDomenicali' - phiDetrend*thetalsDetrend;
figure(2)
bar(consumiDomenicaliDetrend)
hold on
phiFGiorni = [ cos(w3*domeniche'), sin(w3*domeniche'),  ...
     cos(2*w3*domeniche'), sin(2*w3*domeniche'), ...
     cos(3*w3*domeniche'), sin(3*w3*domeniche'), ...
     cos(4*w3*domeniche'), sin(4*w3*domeniche'), ...
     cos(5*w3*domeniche'), sin(5*w3*domeniche')
    ];
[thetalsFGiorni, devthetalsFGiorni] = lscov(phiFGiorni, consumiDomenicaliDetrend);
consumiDomenicaliModel = phiFGiorni * thetalsFGiorni;
plot(1:52, consumiDomenicaliModel);

 
consumiDetrendModel = zeros(52*24, 1);
for i= 1:52
    for j= 1:24
        consumiDetrendModel((i-1)*24+j)= consumiDomenicaliModel(i) + consumiOrariModel(j);
    end
end

consumiDomenicaliVal = solo_domenicheVal(:,4);
giorni = solo_domenicheVal(:,1);
phiDetrendVal = [ones(52*24,1), giorni];
[thetalsDetrendVal, devthetalsDetrendVal] = lscov(phiDetrendVal, consumiDomenicaliVal);
trendVal = phiDetrendVal*thetalsDetrendVal;

previsioneVal = consumiDetrendModel + trendVal;
epsilonVal = consumiDomenicaliVal - previsioneVal;
ssrVal= epsilonVal' * epsilonVal;



consumiDomenicaliID = solo_domeniche(:,4);
giorni = solo_domeniche(:,1);
phiDetrendID = [ones(52*24,1), giorni];
[thetalsDetrendID, devthetalsDetrendID] = lscov(phiDetrendID, consumiDomenicaliID);
trendID = phiDetrendID*thetalsDetrendID;

previsioneID = consumiDetrendModel + trendID;
epsilonID = consumiDomenicaliID - previsioneID;
ssrID= epsilonID' * epsilonID;






matConsumiOrari = [ solo_domeniche(:,2) , solo_domeniche(:,4)];
matConsumiInvernali = matConsumiOrari(1:24*8,:);
matConsumiInvernali = [matConsumiInvernali ; matConsumiOrari(24*47+1:24*52,:)];
matConsumiPrimaverili = matConsumiOrari(24*8+1:24*21,:);
matConsumiEstivi = matConsumiOrari(24*21+1:24*34,:);
matConsumiAutunnali = matConsumiOrari(24*34+1:24*52,:);

mediaOrariaInvernale= zeros(1,24);
for i = 1:24
    mediaOrariaInvernale(i) = mean(matConsumiInvernali(matConsumiInvernali(:,1)==i,2));
end

mediaOrariaInvernaleDetrend = mediaOrariaInvernale - mean(mediaOrariaInvernale);


mediaOrariaPrimaverile= zeros(1,24);
for i = 1:24
    mediaOrariaPrimaverile(i) = mean(matConsumiPrimaverili(matConsumiPrimaverili(:,1)==i,2));
end

mediaOrariaPrimaverileDetrend = mediaOrariaPrimaverile - mean(mediaOrariaPrimaverile);


mediaOrariaAutunnale= zeros(1,24);
for i = 1:24
    mediaOrariaAutunnale(i) = mean(matConsumiAutunnali(matConsumiAutunnali(:,1)==i,2));
end

mediaOrariaAutunnaleDetrend = mediaOrariaAutunnale - mean(mediaOrariaAutunnale);





mediaOrariaEstiva= zeros(1,24);
for i = 1:24
    mediaOrariaEstiva(i) = mean(matConsumiEstivi(matConsumiEstivi(:,1)==i,2));
end

mediaOrariaEstivaDetrend = mediaOrariaEstiva - mean(mediaOrariaEstiva);

    
[thetalsFInv, devthetalsFInv] = lscov(phiF, mediaOrariaInvernaleDetrend');
consumiInvernaliModel= phiF * thetalsFInv;
figure(6)
bar(mediaOrariaInvernaleDetrend)
hold on
title("Media oraria invernale")
plot(1:1:24, consumiInvernaliModel);

[thetalsFPrim, devthetalsFPrim] = lscov(phiF, mediaOrariaPrimaverileDetrend');
consumiPrimaveriliModel= phiF * thetalsFPrim;
figure(7)
bar(mediaOrariaPrimaverileDetrend)
hold on
title("Media oraria primaverile")
plot(1:1:24, consumiPrimaveriliModel);

[thetalsFEst, devthetalsFEst] = lscov(phiF, mediaOrariaEstivaDetrend');
consumiEstiviModel= phiF * thetalsFEst;
figure(8)
bar(mediaOrariaEstivaDetrend)
hold on
title("Media oraria estiva")
plot(1:1:24, consumiEstiviModel);

[thetalsFAut, devthetalsFAut] = lscov(phiF, mediaOrariaAutunnaleDetrend');
consumiAutunnaliModel= phiF * thetalsFAut;
figure(9)
bar(mediaOrariaAutunnaleDetrend)
hold on
title("Media oraria autunnale")
plot(1:1:24, consumiAutunnaliModel);


consumiDetrendModelStagionale= zeros(52*24, 1);
for i= 1:8
    for j= 1:24
        consumiDetrendModelStagionale((i-1)*24+j)= consumiDomenicaliModel(i) + consumiInvernaliModel(j);
    end
end
for i= 9:21
    for j= 1:24
        consumiDetrendModelStagionale((i-1)*24+j)= consumiDomenicaliModel(i) + consumiPrimaveriliModel(j);
    end
end
for i= 22:34
    for j= 1:24
        consumiDetrendModelStagionale((i-1)*24+j)= consumiDomenicaliModel(i) + consumiEstiviModel(j);
    end
end
for i= 35:47
    for j= 1:24
        consumiDetrendModelStagionale((i-1)*24+j)= consumiDomenicaliModel(i) + consumiAutunnaliModel(j);
    end
end
for i= 48:52
    for j= 1:24
        consumiDetrendModelStagionale((i-1)*24+j)= consumiDomenicaliModel(i) + consumiInvernaliModel(j);
    end
end
previsioneStagionaleVal = consumiDetrendModelStagionale + trendVal;
epsilonValStagionale = consumiDomenicaliVal - previsioneStagionaleVal;
ssrValStagionale = epsilonValStagionale' * epsilonValStagionale

erroreMedio= mean(abs(epsilonValStagionale))


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
previsione = trend_previsto + consumiDetrendModelStagionale;
giorni = (linspace(104, 156, n/2))';
plot(giorni, previsione, 'r');

mat_previsione = reshape(previsione,[24,52]);
xlswrite('previsioni_consumiStag.xlsx',mat_previsione)
