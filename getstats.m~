
datamat = [[e.trial.anguloInicio]', [e.trial.anguloRotacion]', [e.trial.velocidad]', [e.trial.tiempo]',...
            [e.trial.categoria]', [e.trial.targOff]'-[e.trial.targOn]', [e.trial.respuesta]', [e.trial.correcto]'];

        
ai = unique(datamat(:,1));
ar = unique(datamat(:,2));
v = unique(datamat(:,3));
t = unique(datamat(:,4));
cat = unique(datamat(:,5));
rt = datamat(:,6);
r = unique(datamat(:,7));
cor = unique(datamat(:,8));

RT = zeros(size(ar));
c = zeros(size(ar));
%Probabilidad de contestar izquierda en funcion de
%la rotacion
for i=1:length(ar)
    signoResp = datamat(datamat(:,2) == ar(i),7);
    izqResp = signoResp == 1;
    probIzqRot(i) = mean(izqResp);
    nIzqRot(i) = length(izqResp);
    corrCol = datamat(datamat(:,1)==ar(i),3);
    cIzqRot(i) =sum(corrCol);
    RT(i) = mean(datamat(datamat(:,2) == ar(i), 6));
end
probIzqRot(isnan(probIzqRot)) = 0;

