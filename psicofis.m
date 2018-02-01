function [angulos, p] = psicofis(e,campo)


trials = e.trial;
angulosmat = [trials.(campo)];
respuesta = [trials.respuesta];
angulos = unique(angulosmat');

p = zeros(length(angulos),1);

for a = 1:length(angulos)
    r = respuesta(angulosmat == angulos(a));
    respizq = sum(r == 1);
    n = length(r);
    p(a) = respizq/n;
end

if nargout == 0;
    plot(angulos,p, 'ob', 'markerfacecolor','b', 'markersize',2)
end