function fr = getfrs(e,spikeid, event, varargin)

% delay firing rate
alignEvent = 'manosFijasFin';
delaysamples = -1:0.01:0.01;
aligned = selectTrials(e,'alignEvent',alignEvent);
fr = firingrate({aligned.spikes.(spikeid)},delaysamples);
delayfr = mean(mean(fr));


% firingrate settings
samples = getArgumentValue('samples',[-1:0.01:1], varargin{:}); % time samples
filtertype = getArgumentValue('filterype','exponential', varargin{:}); 
TimeConstant = getArgumentValue('TimeConstant', 0.05, varargin{:}); % Time constant in seconds.
inicialesesperados = getArgumentValue('inicialesEsperados', [-4,4,0], varargin{:});
rotacionesperados = getArgumentValue('rotacionEsperados', [-0.1,-0.2,-0.4,-0.8,-1.6,-3.2,0.1,0.2,0.4,0.8,1.6,3.2],varargin{:});
%% tasa de disparo movimiento de alcance
switch event
    case 'alcance'
        alignEvent = 'manosFijasFin';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        fr = firingrate({aligned.spikes.(spikeid)}, samples, 'filtertype',filtertype);
        
        if nargout == 0;
            plot(samples, mean(fr), 'color','k');
        else
            fr = mean(fr)';
        end

%% tasa de disparo dependiendo del angulo inicial

    case 'anguloInicio'
        A = [e.trial.anguloInicio]';
        A(A < 0) = round(A(A<0)*10)/10;
              
        angulo = inicialesesperados;
        index_der = find(A == angulo(1));
        index_izq = find(A == angulo(2));
        index_hor = find(A == angulo(3));

        alignEvent = 'touchIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);

        fr_der = firingrate({aligned.spikes(index_der).(spikeid)}, samples, 'filtertype',filtertype);
        fr_izq = firingrate({aligned.spikes(index_izq).(spikeid)}, samples, 'filtertype',filtertype);
        fr_hor = firingrate({aligned.spikes(index_hor).(spikeid)}, samples, 'filtertype',filtertype);
        
        if nargout == 0;
            plot(samples, mean(fr_der), 'r'); hold on
            plot(samples, mean(fr_izq), 'b');
            plot(samples, mean(fr_hor), 'k');
        else
            fr = [mean(fr_izq)',mean(fr_der)',mean(fr_hor)'];
        end


%% tasa de disparo dependiendo del movimiento de rotacion
    case 'anguloRotacion'
        A = [e.trial.anguloRotacion]';
        A(A < 0) = round(A(A<0)*10)/10;
%         angulo = max(rotacionesperados);
        angulo = max(A);
        if angulo > 20;
            angulos = unique(A);
            angulo = angulos(end-1);
        end
        index_der = find(A == -angulo);
        index_izq = find(A == angulo);

        alignEvent = 'movIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);

        fr_der = firingrate({aligned.spikes(index_der).(spikeid)}, samples, 'filtertype',filtertype);
        fr_izq = firingrate({aligned.spikes(index_izq).(spikeid)}, samples, 'filtertype',filtertype);

        if nargout == 0;
            plot(samples, mean(fr_der), 'r'); hold on
            plot(samples, mean(fr_izq), 'b');
        else
            fr = [mean(fr_izq)',mean(fr_der)'];

        end
%% tasa de disparo dependiedo de la posicion final
    case 'anguloFinal'
        iniciales =  [e.trial.anguloInicio];
        iniciales(iniciales < 0) = round(iniciales(iniciales<0)*10)/10;
        inicialnoesperado = setdiff(unique(iniciales), inicioesperados);
        index1 = find(iniciales == inicialnoesperado);
        
        rotacion = [e.trial.anguloRotacion];
        rotacion(rotacion< 0) = round(rotacion(rotacion<0)*10)/10;
        rotacionnoesperado = setdiff(unique(rotacion), rotacionesperados);
        index2 = find(rotacion == rotacionnoesperado);
        e.trial([index1,index2]) = [];
        e.spikes([index1,index2]) = [];
        
        F = [e.trial.anguloInicio]'+[e.trial.anguloRotacion]';
        F(F < 0) = round(F(F<0)*10)/10;
        Fmin = min(abs(F));
        Fmax = max(abs(F));

        Fhor = find(abs(F) == Fmin);
        Fder = find(F == -Fmax);
        Fizq = find(F == Fmax);
        
        alignEvent = 'movFin';
        aligned = selectTrials(e, 'alignEvent',alignEvent);
       
        fr_hor = firingrate({aligned.spikes(Fhor).(spikeid)}, samples, 'filtertype',filtertype);
        fr_der= firingrate({aligned.spikes(Fder).(spikeid)}, samples, 'filtertype',filtertype);
        fr_izq = firingrate({aligned.spikes(Fizq).(spikeid)}, samples, 'filtertype',filtertype);
        
        
        if nargout == 0;
            plot(samples, mean(fr_der), 'r'); hold on
            plot(samples, mean(fr_izq), 'b');
            plot(samples, mean(fr_hor), 'k');
        else
            fr = [mean(fr_izq)',mean(fr_der)',mean(fr_hor)'];
        end
 %% tasa de disparo al momento de que aparecen los objetivos de respuesta       
        case 'targOn'
        A = [e.trial.anguloRotacion]';
        A(A < 0) = round(A(A<0)*10)/10;
%         angulo = max(rotacionesperados);
        angulo = max(A);
        if angulo > 20;
            angulos = unique(A);
            angulo = angulos(end-1);
        end
        index_der = find(A == -angulo);
        index_izq = find(A == angulo);

        alignEvent = 'targOn';
        aligned = selectTrials(e,'alignEvent',alignEvent);

        fr_der = firingrate({aligned.spikes(index_der).(spikeid)}, samples, 'filtertype',filtertype);
        fr_izq = firingrate({aligned.spikes(index_izq).(spikeid)}, samples, 'filtertype',filtertype);

        if nargout == 0;
            plot(samples, mean(fr_der), 'r'); hold on
            plot(samples, mean(fr_izq), 'b');
        else
            fr = [mean(fr_izq)',mean(fr_der)'];

        end

        
end