function [n, angulos] = getNumTrials(e)


trials_arot = [e.trial.anguloRotacion]';
angulos = unique(trials_arot);

n = zeros(size(angulos));

for a = 1:length(angulos);
   n(a)  = sum(trials_arot == angulos(a));
end

