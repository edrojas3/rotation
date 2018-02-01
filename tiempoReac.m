function [trmean, trstd, angulos, n] = tiempoReac(e)

trials = e.trial;

angulos = unique([trials.anguloRotacion]');

trmean = zeros(length(angulos),1);
trstd = trmean;
n = trmean;
for a = 1:length(angulos)
    
   index = [trials.anguloRotacion] == angulos(a);
   targon = [trials(index == 1).targOn]';
   targoff = [trials(index == 1).targOff]';
   trmean(a) = mean(targoff - targon);
   trstd(a) = std(targoff - targon);
   n(a) = length(targon);
end

