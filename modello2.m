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
phiF2 = [ cos(w2*ore), sin(w2*ore), ...
     cos(2*w2*ore), sin(2*w2*ore), ...
     cos(3*w2*ore), sin(3*w2*ore), ...
     cos(4*w2*ore), sin(4*w2*ore), ...
     cos(5*w2*ore), sin(5*w2*ore), ...
     cos(6*w2*ore), sin(6*w2*ore), ...
     cos(7*w2*ore), sin(7*w2*ore), ...
     cos(8*w2*ore), sin(8*w2*ore), ...
     cos(9*w2*ore), sin(9*w2*ore), ...
     cos(10*w2*ore), sin(10*w2*ore)
    ];
[thetalsF2, devthetalsF2] = lscov(phiF2, mediaOrariaDetrended');
consumiOrariModel= phiF2 * thetalsF2;
epsilonF2 = mediaOrariaDetrended' - (phiF2 * thetalsF2);
ssrF2 = epsilonF2' * epsilonF2;
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
w3 = 2 * pi / 52;
phiDetrend = [ones(52,1), domeniche'];
[thetalsDetrend, devthetalsDetrend] = lscov(phiDetrend, consumiDomenicali');
consumiDomenicaliDetrend = consumiDomenicali' - phiDetrend*thetalsDetrend;
figure(2)
bar(consumiDomenicaliDetrend)
hold on
phiFGiorni = [ cos(w3*domeniche'), sin(w3*domeniche'), ...
     cos(2*w3*domeniche'), sin(2*w3*domeniche'), ...
     cos(3*w3*domeniche'), sin(3*w3*domeniche'), ...
     cos(4*w3*domeniche'), sin(4*w3*domeniche'), ...
     cos(5*w3*domeniche'), sin(5*w3*domeniche'), ...
     cos(6*w3*domeniche'), sin(6*w3*domeniche'), ...
     cos(7*w3*domeniche'), sin(7*w3*domeniche'), ...
     cos(8*w3*domeniche'), sin(8*w3*domeniche'), ...
     cos(9*w3*domeniche'), sin(9*w3*domeniche'), ...
     cos(10*w3*domeniche'), sin(10*w3*domeniche')
    ];
[thetalsFGiorni, devthetalsFGiorni] = lscov(phiFGiorni, consumiDomenicaliDetrend);
consumiDomenicaliModel = phiFGiorni * thetalsFGiorni;
plot(1:52, consumiDomenicaliModel);



