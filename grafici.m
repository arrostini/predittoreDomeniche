clc
close all
clear
 
tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');
mat = tab{:,:};
solo_domeniche = mat(mat(:,3)==1,:);
medieGiornaliere= zeros(1,7);
for i = 1:7
    medieGiornaliere(i) = mean(mat(mat(:,3)==i,4))*24;
end
figure(1)
b=bar(medieGiornaliere, 'FaceColor', 'flat');
b.CData(1,:) = [1 0 0]; %mostra la domenica in rosso

medieOrarie = zeros(1,24);
for i=1:24
    medieOrarie(i)= mean(mat(mat(:,2)==i,4));
end
figure(2)
bar(medieOrarie);
hold on
medieOrarieDomeniche = zeros(1,24);
domeniche= mat(mat(:,3)==1,:);
for i=1:24
    medieOrarieDomeniche(i)= mean(domeniche(domeniche(:,2)==i,4));
end
bar(medieOrarieDomeniche);

domenicaInvernale = domeniche(domeniche(:,1)==6,4);
domenicaInvernaleDetrended= domenicaInvernale - mean(domenicaInvernale);
domenicaEstiva = domeniche(domeniche(:,1)==181,4);
domenicaEstivaDetrended = domenicaEstiva - mean(domenicaEstiva);
figure(4)
bar(domenicaEstivaDetrended);
figure(5)
bar(domenicaInvernaleDetrended);
domenicaMediaDetrended= medieOrarieDomeniche -mean(medieOrarieDomeniche);
figure(6)
bar(domenicaMediaDetrended);

