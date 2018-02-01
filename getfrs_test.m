
% tasa de disparo dependiendo del angulo inicial

A = [e.trial.anguloInicio]';
A(A < 0) = round(A(A<0)*10)/10;
index_der = find(A == -angulo);
index_izq = find(A == angulo);
index_hor = find(A == 0);

samples = [-1:0.01:1];

alignEvent = 'touchIni';
aligned = selectTrials(e,'alignEvent',alignEvent);

fr_der = firingrate({aligned.spikes(index_der).spike11}, samples, 'filtertype','exponential');
fr_izq = firingrate({aligned.spikes(index_izq).spike11}, samples, 'filtertype','exponential');
fr_hor = firingrate({aligned.spikes(index_hor).spike11}, samples, 'filtertype','exponential');

plot(samples, mean(fr_der), 'r'); hold on
plot(samples, mean(fr_izq), 'b');
plot(samples, mean(fr_hor), 'k');


%% tasa de disparo dependiendo del movimiento de rotacion

A = [e.trial.anguloRotacion]';
A(A < 0) = round(A(A<0)*10)/10;
angulo = max(A);
index_der = find(A == -angulo);
index_izq = find(A == angulo);

samples = -1:0.01:1;

alignEvent = 'movIni';
aligned = selectTrials(e,'alignEvent',alignEvent);

fr_der = firingrate({aligned.spikes(index_der).spike11}, samples, 'filtertype','exponential');
fr_izq = firingrate({aligned.spikes(index_izq).spike11}, samples, 'filtertype','exponential');

plot(samples, mean(fr_der), 'r'); hold on
plot(samples, mean(fr_izq), 'b');

%% tasa de disparo dependiedo de la posicion final

F = [e.trial.anguloInicio]' + [e.trial.anguloRotacion]';
F(F < 0) = round(F(F<0)*10)/10;
Fmin = min(abs(F));
Fmax = max(abs(F));

Fhor = find(abs(F) == Fmin);
Fder = find(F == -Fmax);
Fizq = find(F == Fmax);
