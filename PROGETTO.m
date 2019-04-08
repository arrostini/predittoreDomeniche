close all 
clc

tab = readtable('caricoDEhour.xlsx', 'Range','A2:D17522');

figure(1)
plot(tab.giorno_anno,tab.dati);
title('consumo orario');
grid on;
xlabel('ore');
ylabel('consumo');

h = height(tab);
ore = 24;
v = zeros(h/ore,1);

 for i = 24:ore:h
     for c = 1:ore
         v(i/ore) = tab.dati(i+c-24) + v(i/ore);
     end
 end
 
 
 d1 = linspace(1,730,730);
 
 figure(2);
 plot(d1,v);
 grid on;
 xlabel('giorni');
 ylabel('consumo');
 title('consumo giornaliero');
 hold on
 b = ones(365,1)*(1/365);
 v1 = filter(b,1,v);
 
 b = [b;(zeros(size(b)))];
 Br = [1/365 zeros(1,365) ones(1,364)/365];
 B = toeplitz(b,Br);
 y = B*v;
 plot(d1,y);
 
 consumo_domeniche = zeros(104,1);
 k = 1;
 
 for i = 24:ore:h
     if tab.giorno_settimana(i-23) == 1
         for c = 1:ore
            consumo_domeniche(k)= consumo_domeniche(k) + tab.dati(i+c-24);
         end
         k = k +1;
     end
 end
 
 domeniche = linspace(1,104,104)';
 
 figure(3)
 plot(domeniche,consumo_domeniche);
 grid on
 title('consumo domenicale');
 xlabel('domeniche');
 ylabel('consumo');
 hold on
 
 n = length(consumo_domeniche);
 phi3 = [ones(n,1) domeniche domeniche.^2 domeniche.^3 domeniche.^4 domeniche.^5 domeniche.^6];
 thetals3 = phi3\consumo_domeniche;
 %domeniche_ext = [min(domeniche):1:max(domeniche)]';
 plot(domeniche, phi3*thetals3);
 hold on
 
 
