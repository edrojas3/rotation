function c = colormat(angulos, n)

n_der = n(angulos < 0);
n_der = flipdim(n_der,1);
cumder = [0;cumsum(n_der)];
yellow = linspace(0,1,length(n_der));

cder= zeros(sum(n_der),3);

for k = 1: length(n_der);
    index = cumder(k)+1:cumder(k+1);
    l = length(index);
    cder(index,:) = [ones(l,1),yellow(k)*ones(l,1),zeros(l,1)];
end

n_izq = n(angulos > 0);
cumizq = [0;cumsum(n_izq)];
blue = linspace(0,1,length(n_izq));

cizq = zeros(sum(n_izq),3);

for k = 1:length(n_izq);
   index = cumizq(k)+1:cumizq(k+1);
   l = length(index);
   cizq(index,:) = [zeros(l,1),blue(k)*ones(l,1),ones(l,1)];
end

c = [cder;cizq];
