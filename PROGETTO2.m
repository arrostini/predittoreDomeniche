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
phi3= [ones(n,1) giorni ore giorni.^2 ore.^2 giorni.*ore giorni.^3 ore.^3 (giorni.^2).*ore (ore.^2).*giorni];
[thetals3, devthetals3]= lscov(phi3, consumi);
epsilon3 = consumi - phi3*thetals3;
stima_consumi3 = phi3*thetals3;

phi4= [phi3, giorni.^4, ore.^4, giorni.^3.*ore, ore.^3.*giorni, giorni.^2.*ore.^2];
[thetals4, devthetals4]= lscov(phi4, consumi);
epsilon4 = consumi - phi4*thetals4;
stima_consumi4 = phi4*thetals4;

phi5= [phi4, giorni.^5, ore.^5, giorni.^4.*ore, ore.^4.*giorni, giorni.^3.*ore.^2, giorni.^2.*ore.^3];
[thetals5, devthetals5]= lscov(phi5, consumi);
epsilon5 = consumi - phi5*thetals5;
stima_consumi5 = phi5*thetals5;

phi6= [phi5, giorni.^6, ore.^6, giorni.^5.*ore, ore.^5.*giorni, giorni.^4.*ore.^2, giorni.^2.*ore.^4, giorni.^3.*ore.^3];
[thetals6, devthetals6]= lscov(phi6, consumi);
epsilon6 = consumi - phi6*thetals6;
stima_consumi6 = phi6*thetals6;



giorni_ext = linspace(min(giorni),max(giorni),100);
ore_ext = linspace(min(ore),max(ore),100);
n1=length(giorni_ext)*length(ore_ext);

[G, O] = meshgrid(giorni_ext,ore_ext);

phi3_ext = [ones(n1,1),G(:),O(:),G(:).^2,O(:).^2,G(:).*O(:),G(:).^3,O(:).^3,(G(:).^2).*O(:),(O(:).^2).*G(:)];
stima_consumi_ext3 = phi3_ext*thetals3;
stima_consumi_mat3 = reshape(stima_consumi_ext3,size(G));

figure(3);
mesh(G,O, stima_consumi_mat3);
grid on
hold on
scatter3(giorni,ore,consumi,"o");


%quarto grado
% giorni.^4, ore.^4, giorni.^3.*ore, ore.^3.*giorni, giorni.^2.*ore.^2
phi4_ext = [ones(n1,1),G(:),O(:),G(:).^2,O(:).^2,G(:).*O(:),G(:).^3,O(:).^3,(G(:).^2).*O(:),(O(:).^2).*G(:), G(:).^4, O(:).^4, G(:).^3.*O(:), O(:).^3.*G(:), O(:).^2.*G(:).^2];
stima_consumi_ext4 = phi4_ext*thetals4;
stima_consumi_mat4 = reshape(stima_consumi_ext4,size(G));

figure(4);
mesh(G,O, stima_consumi_mat4);
grid on
hold on
scatter3(giorni,ore,consumi,"o");

%quinto grado

phi5_ext = [ones(n1,1),G(:),O(:),G(:).^2,O(:).^2,G(:).*O(:),G(:).^3,O(:).^3,(G(:).^2).*O(:),(O(:).^2).*G(:), G(:).^4, O(:).^4, G(:).^3.*O(:), O(:).^3.*G(:), O(:).^2.*G(:).^2,G(:).^5, O(:).^5, G(:).^4.*O(:), O(:).^4.*G(:), G(:).^3.*O(:).^2, G(:).^2.*O(:).^3];
stima_consumi_ext5 = phi5_ext*thetals5;
stima_consumi_mat5 = reshape(stima_consumi_ext5,size(G));

figure(5);
mesh(G,O, stima_consumi_mat5);
grid on
hold on
scatter3(giorni,ore,consumi,"o");

%sesto grado

phi6_ext = [ones(n1,1),G(:),O(:),G(:).^2,O(:).^2,G(:).*O(:),G(:).^3,O(:).^3,(G(:).^2).*O(:),(O(:).^2).*G(:), G(:).^4, O(:).^4, G(:).^3.*O(:), O(:).^3.*G(:), O(:).^2.*G(:).^2,G(:).^5, O(:).^5, G(:).^4.*O(:), O(:).^4.*G(:), G(:).^3.*O(:).^2, G(:).^2.*O(:).^3, G(:).^6, O(:).^6, G(:).^5.*O(:), G(:).*O(:).^5, G(:).^4.*O(:).^2, G(:).^2.*O(:).^4, G(:).^3.*O(:).^3];
stima_consumi_ext6 = phi6_ext*thetals6;
stima_consumi_mat6 = reshape(stima_consumi_ext6,size(G));

figure(6);
mesh(G,O, stima_consumi_mat6);
grid on
hold on
scatter3(giorni,ore,consumi,"o");

%serie di fourier

giorni_l = giorni;
w = 2*pi/365;
phiF = [ones(n,1) cos(w*giorni_l) sin(w*giorni_l) cos(2*w*giorni_l) sin(2*w*giorni_l) cos(3*w*giorni_l) sin(3*w*giorni_l) cos(4*w*giorni_l) sin(4*w*giorni_l) cos(5*w*giorni_l) sin(5*w*giorni_l) cos(6*w*giorni_l) sin(6*w*giorni_l)];
[thetalsF, devthetalsF]= lscov(phiF, consumi);
epsilonF = consumi - phiF*thetalsF;
stima_consumiF = phiF*thetalsF;

phiF_ext = [ones(n1,1) cos(w*G(:)) sin(w*G(:)) cos(2*w*G(:)) sin(2*w*G(:)) cos(3*w*G(:)) sin(3*w*G(:)) cos(4*w*G(:)) sin(4*w*G(:)) cos(5*w*G(:)) sin(5*w*G(:)) cos(6*w*G(:)) sin(6*w*G(:))];
stima_consumi_extF = phiF_ext*thetalsF;
stima_consumi_matF = reshape(stima_consumi_extF,size(G));

phiFO = [ones(n,1) cos(w*ore) sin(w*ore) cos(2*w*ore) sin(2*w*ore) cos(3*w*ore) sin(3*w*ore) cos(4*w*ore) sin(4*w*ore) cos(5*w*ore) sin(5*w*ore) cos(6*w*ore) sin(6*w*ore)];
[thetalsFO, devthetalsFO]= lscov(phiFO, consumi);
epsilonFO = consumi - phiFO*thetalsFO;
stima_consumiFO = phiFO*thetalsFO;

phiFO_ext = [ones(n1,1) cos(w*O(:)) sin(w*O(:)) cos(2*w*O(:)) sin(2*w*O(:)) cos(3*w*O(:)) sin(3*w*O(:)) cos(4*w*O(:)) sin(4*w*O(:)) cos(5*w*O(:)) sin(5*w*O(:)) cos(6*w*O(:)) sin(6*w*O(:))];
stima_consumi_extFO = phiFO_ext*thetalsFO;
stima_consumi_matFO = reshape(stima_consumi_extFO,size(G));

stima_consumi_matFF = (stima_consumi_matF + stima_consumi_matFO)*(1/2);
figure(7);
mesh(G,O, stima_consumi_matFF);
grid on
hold on
scatter3(giorni,ore,consumi,"o");

