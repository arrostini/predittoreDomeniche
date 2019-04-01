clc
close all

tab = readtable('caricoDEhour.xlsx', 'Range','A2:D8762');

mat = tab{:,:};

solo_domeniche = mat(mat(:,3)==1,:); %prendo le righe dove la terza colonna é uguale a 1

consumi= solo_domeniche(:,4);
giorni= solo_domeniche(:,1);
ore= solo_domeniche(:,2);

figure(1);
plot3(giorni,ore,consumi,"o");
grid on;


n = length(consumi);
phi4= [ones(n,1) giorni ore giorni.^2 ore.^2 giorni.*ore giorni.^3 ore.^3 (giorni.^2).*ore (ore.^2).*giorni];
[thetals4, devthetals4]= lscov(phi4, consumi);
epsilon4 = consumi - phi4*thetals4;
stima_consumi4 = phi4*thetals4;

giorni_ext = linspace(min(giorni),max(giorni),100);
ore_ext = linspace(min(ore),max(ore),100);
n1=length(giorni_ext)*length(ore_ext);

[G, O] = meshgrid(giorni_ext,ore_ext);

phi4_ext = [ones(n1,1),G(:),O(:),G(:).^2,O(:).^2,G(:).*O(:),G(:).^3,O(:).^3,(G(:).^2).*O(:),(O(:).^2).*G(:)];
stima_consumi_ext = phi4_ext*thetals4;
stima_consumi_mat = reshape(stima_consumi_ext,size(G));

figure(3);
mesh(G,O, stima_consumi_mat);
grid on
hold on
scatter3(giorni,ore,consumi,"o");
