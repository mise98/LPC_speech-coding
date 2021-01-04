%
% Puheenkoodaus lineaariprediktion avulla
%
%

% Mikko Seppi
% 24.10.2020

clear all

%%  Tulopuskuri ja esikorostussuodatin
%Luetaan aalto_yliopisto.wav matlabiin
[s,fs] = audioread('aalto_yliopisto.wav');

%Esikorostussuodatimen teko
b = [1 ,-0.97]; %FIR kertoimet
s2 = filter(b, 1 , s);

%kuvaajat spektreist‰
figure(1)
plotFFT(s,fs, 'log')
title('Alkuper‰inen signaali')
figure(2)
plotFFT(s2,fs, 'log')
title('Esikorostussuodatettu signaali')

ikkunan_koko = 0.03;
%signaalin jako 30 ms ikkunoihin
buf = buffer(s2, ikkunan_koko*fs);


%% LP-parametrien estimointi ja analyysisuodatin

%lpc asteluku
p = 15;

%t‰nne tallennetaan lp kertoimet
lpc_coefs = zeros(p+1,length(buf(1,:)));


val_S = zeros(length(buf(:,1)),length(buf(1,:)));

%Otetaan,joka ikkunasta lp kertoimet lpc komennolla, tallenetaan ne
%matriisiin lpc_coefs ja suoritetaan joka ikkunalle filtterointi lp
%keroimien avulla

for i = 1:length(buf(1,:))
 lp = lpc(buf(:,i),p);
 lpc_coefs(:,i)=lp;
val_S(:,i) = filter(lp,1,buf(:,i));
end


%%  Kvantisointi

%Skaalataan saatu signaali v‰lille -1 ja 1
Xeq = val_S./max(abs(val_S));

%kvanttisoinnin bittisyvyys
b = 16;

%kvanttisoidaan signaali
Xq = floor(2^(b-1)*Xeq)/(2^(b-1));



%% Synteesisuodatin & esikorostuksen k‰‰nteissuodatin

x_pal = zeros(length(buf(:,1)),length(buf(1,:)));

%Kvanttisoidut ikkunat filtteroidaan k‰ytt‰m‰ll‰ aikaisemmin tallennettuja
%lp-kertoimia IIR muodossa eli k‰ytt‰en lp-kertoimia filtterin a:n kertoimina.
for i = 1:length(buf(1,:))
 x_pal(:,i) = filter(1,lpc_coefs(:,i),Xq(:,i));
end

%Filtteroin ikkunat viel‰ aikaisemmin k‰ytetyll‰ FIR-esikorostussuodattimen
%k‰‰nteissuodattimella

x = filter(1,[1 ,-0.97],x_pal);

%Ikkunat yhdistet‰‰n yhdeksi signaaliksi
x = x(:);

%kuvaaja saadun signaalin spektrist‰
figure(3)
plotFFT(x,fs, 'log')
title('Rekonstruktuoitu tulosignaali')


%Lopputuloksen kuuntelu
soundsc(x,fs)


%luetaan tulos tiedostoon
%audiowrite('tulos.wav',x./max(abs(x)),fs)









