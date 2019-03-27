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
 
 domeniche = linspace(1,104,104);
 
 figure(3)
 plot(domeniche,consumo_domeniche);
 grid on
 title('consumo domenicale');
 xlabel('domeniche');
 ylabel('consumo');
 
 %prova
 
 figure(4)
 plot(domeniche,consumo_domeniche); 
 
