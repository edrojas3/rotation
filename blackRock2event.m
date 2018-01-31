function e = blackRock2event(nevFile, ns1File)
% Crea una estructura en donde viene toda la informacion de la corrida por
% cada ensayo. La informacion se saca del los archivos.nev.
%
% Uso: e = blackRock2event(nevData, nsfile)
%
% Argumentos de entrada:
    %   nevData: archivo.nev en donde viene la información digital de la
    %   sesión.
    %   nsFile: archivo ns en donde viene la informacion analógica del brazo
    %   unit: unidad clasificada del registro.
    %   saveName: nombre con el que quieres guardar la estructura de salida.
%
% Argumentos de salida:
    % e: es una estructura con los campos
        %       Fecha: fecha de la corrida.
        %       FechaRaw: fecha transformada en numeros.
        %       ArchivoNEV: archivo.nev de donde se saco la informacion.
        %       DatosCrudos: Toda la informacion de las entradas digitales tal
        %                 cual la da BlackRock.
        %       ResTemp: resolucion temporal.
        %       matResuls: intento de emular la matriz results que guarda
        %       matlab durante la tarea. No ha salido muy bien.
        %       trial: subestructura con toda la informacion de cada ensayo.
        %       spikes: subcampo con la actividad neuronal. Cada campo
        %       tiene la actividad neuronal de una neurona aislada; el
        %       nombre del campo tiene codificado el canal y la unidad.
        %       Ejemplo: en e.spikes.spike15 est� la actividad de la unidad
        %       5 registrada con el canal 1.

%% Cargar el archivo NEV (eventos digitales y spikes)
disp('Loading files...')
NEV = openNEV (nevFile, 'nosave');

% Informacion de la corrida
disp('Session metadata...')
fecha = NEV.MetaTags.DateTime;
fechaR = NEV.MetaTags.DateTimeRaw;
archivoNEV = [NEV.MetaTags.Filename,NEV.MetaTags.FileExt];
resTemp = NEV.MetaTags.TimeRes;

% Senal digital separada por las fuentes: MATLAB, sensores, y expo.
disp('Separating digital signals by sources...')
event = dec2bin(NEV.Data.SerialDigitalIO.UnparsedData);
matVal = bin2dec(event(:,1:8));
expoVal = bin2dec(event(:,13:15));
sensorVal = bin2dec(event(:,10:12));
times = NEV.Data.SerialDigitalIO.TimeStampSec;
tics = NEV.Data.SerialDigitalIO.TimeStamp;
timek = double(times(1))/(double(tics(1)));
raw_tstamp = NEV.Data.SerialDigitalIO.TimeStamp;
bin_sensorVal = dec2bin(sensorVal);
izq_sensor = str2num(bin_sensorVal(:,3));
der_sensor = str2num(bin_sensorVal(:,2));
obj_sensor = str2num(bin_sensorVal(:,1));
data = [times', matVal, izq_sensor, der_sensor, obj_sensor, expoVal];
fromBlackRock = struct('timeStampsSec', {times},...
            'timeStamp', tics,...
            'binData', {NEV.Data.SerialDigitalIO.UnparsedData});
        
% Spikes

disp ('Getting spike events...')
spike_timeStamp = double(NEV.Data.Spikes.TimeStamp);
electrodes = double(NEV.Data.Spikes.Electrode);
electrodecount = unique(electrodes);
units = double(NEV.Data.Spikes.Unit);
unitcount = unique(units);
unitcount(unitcount == 0) = []; % no clasificadas
unitcount(unitcount == 255) = []; % ruido

%% Cargar archivo NS con la informaci�n del brazo
NS1 = openNSx(ns1File);
if isstruct(NS1)
    goodRob = 1;
    movRob = NS1.Data;
    if size(movRob,1) > 1;
       movRob = movRob(2,:) ;
    end
    srateRob = NS1.MetaTags.SamplingFreq;
    srate2msecs = 1000/srateRob;
    timeRobSecs = (1:length(movRob))/srateRob;
    
else
    goodRob = 0;
end

%% Ensayo completado (253 en matVal)
if ~(isempty(unitcount)) && goodRob == 1;
disp('Identifying start and end time stamps of each trial...')

seq = [253;255;253;254]; % secuencia que indica el final de un ensayo
c = 1;
for m = 1:length(matVal)-4; %buscar la secuencia en la se�al de matlab y guardar indice
    if matVal(m:m+3) == seq;
        completado(c) = m;
        c = c+1;
    end
end

posIniIndx = zeros(size(completado)); % Buscar los posibles inicios del ensayo (matVal == 251) desde el fin del ensayo hacia atr�s
pini = 0;
for i = 1:length(completado);
    noIni = 1;
    resta = 1;
    while noIni
        if completado(i) - resta == 0;
            completado(i) = nan;
            noIni = 0;
        elseif matVal(completado(i)-resta) ~= 251;
           resta = resta + 1;
        elseif sum(matVal(completado(i)-resta : completado(i)) == 252) < 1;
            resta = resta + 1;
        else
            noIni = 0;
            pini = 1 ; 
        end
    end
   
    while pini
        if completado(i) - resta <= 0;
            pini = 0;
        elseif matVal(completado(i) - resta) == 251;
            resta = resta +1;
        else
            pini = 0;
        end
    end
    posIniIndx(i) = completado(i) - resta+1;
end

completado(isnan(completado)) = [];
posIniIndx(isnan(posIniIndx)) = [];

% buscar abortos entre inicios y finales

% for i = 1:length(completado)
%    aborto = sum(expoVal(posIniIndx(i):completado(i)) == 7);
%    if aborto > 0
%        noAbort = 1;
%        suma = 1;
%       while noAbort
%          if expoVal(posIniIndx(i) + suma) ~=7;
%              suma = suma +1;
%          else
%              noAbort = 0;
%              abortIndx = posIniIndx(i+ suma);
%          end
%       end
%       
%       noIni = 1;
%       suma = 1;
%       while noIni
%          if expoVal(abortIndx + suma) ~= 0;
%              suma = suma +1;
%          else
%              noIni = 0;
%          end
%       end
%       posIniIndx(i) = abortIndx + suma;
%    end
% end


%% Separar por ensayo y extraer estampas de tiempo (inicio y final de cada evento conductual y clave visual)
matresults = zeros(length(posIniIndx), 10);
disp('Event time stamps...')



for i = 1:length(posIniIndx)
    
    ensayo = data(posIniIndx(i):completado(i),:);
    touch_interval = ensayo(:,4) == 1;
    cmdStim = ensayo(:,2) == 252;
    logic_cmdStim = touch_interval .* cmdStim;
    if sum(logic_cmdStim == 1) == 0;
        logic_cmdStim = find(cmdStim == 1);
        cmdStimRot = ensayo(logic_cmdStim(1),1);
        cmdStimIndx = find(times == cmdStimRot);
    else
        cmdStimRot = ensayo(logic_cmdStim == 1);
        cmdStimRot = cmdStimRot(1);
        cmdStimIndx = find(times == cmdStimRot);
    end
    
    %% Primer Evento: interensayo

    % SENSORES (manos en sensores hasta que alza mano derecha )
  
   if i == 1;
        manosFijasIni = data(posIniIndx(i),1);
        manosFijasIniIndx = posIniIndx(1);
   else
        resta = 1;
        nofix = 1;
        while nofix 
            if data(cmdStimIndx-resta,3) == 0 &&...
                    data(cmdStimIndx-resta,4) == 0 &&...
                    data(cmdStimIndx-resta,5) == 0 &&...
                    data(cmdStimIndx-resta,6) == 0;
               nofix = 0;
                
            else
                resta = resta + 1; 
                
            end
        end
        
        fix = 1;
        while fix
           if data(cmdStimIndx-resta,3) == 0 &&...
                   data(cmdStimIndx-resta,4) == 0 &&...
                   data(cmdStimIndx-resta,5) == 0 &&...
                   data(cmdStimIndx-resta,6) == 0;
               resta = resta+1;
           else
               fix = 0;
           end
        end
        manosFijasIni = data(cmdStimIndx-(resta-1),1);
        manosFijasIniIndx = cmdStimIndx-(resta-1);
        
    end   

    suma = 1;
    fixFin = 1;
    while fixFin 
        if data(manosFijasIniIndx + suma,4) ~= 1;
           suma = suma + 1; 
        else
            fixFin = 0;
        end
    end
    manosFijasFin = data(manosFijasIniIndx + suma,1);
    manosFijasFinIndx = manosFijasIniIndx + suma;
    
    % PANTALLA (clave visual de espera hasta clave visual de toca el objeto)
    
    % Inicio de pantalla morada
    if i == 1;
        waitCueIni = data(posIniIndx(1),1);
        waitCueIniIndx = posIniIndx(1);
    else
        resta = 1;
        wait = 1;
        while wait 
            if data(manosFijasIniIndx-resta,6) == 0;
               resta = resta + 1; 
            else
                wait = 0;
            end
        end
        waitCueIni = data(manosFijasIniIndx-(resta-1));
        waitCueIniIndx = manosFijasIniIndx-(resta-1);
    end

    % Fin de pantalla morada (clave visual de espera)
    suma = 1;
    waitFin = 1;
    while waitFin 
        if data(waitCueIniIndx + suma,6) ~= 1;
           suma = suma + 1; 
        else
            waitFin = 0;
        end
    end
    waitCueFin = data(waitCueIniIndx + suma,1);
    waitCueFinIndx = waitCueIniIndx + suma;

    %% Segundo Evento: Tocar Objeto (desde contacto con objeto hasta que lo suelta)

    % SENSORES (contacto con objeto hasta que lo suelta)
    
    % Toca el objeto
    suma = 1;
    noTouch = 1;
    while noTouch
        if data(manosFijasFinIndx + suma,5) ~= 1;
           suma = suma + 1; 
        else
            noTouch = 0;
        end
    end
    touchIni = data(manosFijasFinIndx + suma,1); 
    touchIniIndx = manosFijasFinIndx + suma;

    % Suelta el objeto
    suma = 1;
    touch = 1;
    while touch
        if sum(data(touchIniIndx + suma:touchIniIndx + suma + 5,5)) >= 1;
           suma = suma + 1; 
        else
            touch = 0;
        end
    end
    touchFin = data(touchIniIndx + suma,1);
    touchFinIndx = touchIniIndx + suma;


    % PANTALLA (inicio pantalla blanca hasta pantalla negra)
    
    touchCueIni = data(waitCueFinIndx,1);
    touchCueIniIndx = waitCueFinIndx;
    
    % Fin de la pantalla blanca
    suma = 1;
    blanca = 1;
    while blanca
        if data(touchCueIniIndx + suma,6) ~= 3;
           suma = suma + 1; 
        else
            blanca = 0;
        end
    end
    touchCueFin = data(touchCueIniIndx + suma,1);
    touchCueFinIndx = touchCueIniIndx + suma;
    

    %% Tercer Evento: respuesta 

    % Sensores (desde que regresa la mano derecha al sensor hasta que alza mano izquierda para responder)
   
    % Regresa la mano derecha al punto de inicio
    suma = 1;
    noDer = 1;
    while noDer
        if data(touchCueFinIndx + suma,4) == 1;
           suma = suma + 1; 
        else
            noDer = 0;
        end
    end
    waitRespIni = data(touchFinIndx + suma,1);
    waitRespIniIndx = touchFinIndx + suma;

    % Suelta el punto de inicio izquierdo
    suma = 1;
    izq = 1;
    
    while izq
        if data(waitRespIniIndx + suma,3) ~= 1;
           suma = suma + 1; 
        else
           izq = 0;
        end
    end
    waitRespFin = data(waitRespIniIndx + suma,1);
    waitRespFinIndx = waitRespIniIndx + suma;
    
    % Pantalla (Aparicion de los objetivos de respuesta hasta la pantalla de acierto o error)
    
    % Aparicion de los objetivos de respuesta
    suma = 1;
    noTarg = 1;
    while noTarg
        if data(touchCueFinIndx + suma,6) ~= 4;
           suma = suma + 1; 
        else
            noTarg = 0;
        end
    end
    targOn = data(touchCueFinIndx + suma,1);
    targOnIndx = touchCueFinIndx + suma;
    
    % Pantalla de acierto o error
    suma = 1;
    noResp = 1;
    while noResp
        if data(targOnIndx + suma,6) < 5;
           suma = suma + 1; 
        else
            noResp = 0;
        end
    end
    targOff = data(targOnIndx + suma,1);
    targOffIndx = targOnIndx+ suma;
    
    %% Datos de los eventos neuronales por ensayo
   
    logic_timeStamp = spike_timeStamp >= raw_tstamp(manosFijasIniIndx)-100000  & spike_timeStamp <= raw_tstamp(completado(i));

    spike_times = spike_timeStamp(logic_timeStamp == 1);
    spike_timesSec = double(spike_times)*timek; 
    spike_electrode = electrodes(logic_timeStamp == 1);
    spike_unit = units(logic_timeStamp == 1);

    for j = 1:length(electrodecount)
        electrode_num = spike_electrode == electrodecount(j); % Electrodo de interés
        electrode_unit = spike_unit .* electrode_num; % Unidades dentro del electrodo de interés
        for u = 1:length(unitcount)
            spike_events = spike_timesSec(electrode_unit == unitcount(u));
            if ~(isempty(spike_events));
                spike_name = ['spike',num2str(electrodecount(j)),num2str(unitcount(u))];
                spikes(i).(spike_name) = spike_events;
            end

%             spike_var = [spike_name, '= spike_events;'];
%             eval(spike_var)

        end
    end

    
    %% Datos (info que manda matlab al final de cada ensayo)
   % Matriz con todos los datos del ensayo 
    ensayo = data(manosFijasIniIndx:completado(i),:);
    tstamp = tics(manosFijasIniIndx:completado(i))*timek;
     
    cmdIniRot = ensayo(ensayo(:,2) == 251,1);
    if isempty(cmdIniRot)
        cmdIniRot = manosFijasIni;
    end
    cmdIniRot = cmdIniRot(1);
    cmdIniIndx = find(ensayo(:,1) == cmdIniRot);
    cmdStimIndx = find(ensayo(:,1) == cmdStimRot,1);
    movIni = ensayo(cmdStimIndx(1),1) + 0.25;
    m = ensayo(:,2);
    t = ensayo(:,1);
    badInfo = 0;
   
   if goodRob;
       logic_movTime = timeRobSecs >= ensayo(cmdStimIndx(1),1) - 0.5 & timeRobSecs <= ensayo(cmdStimIndx(1),1) + 1.5;
       robSignal = movRob(logic_movTime == 1);
       robTimeSec = timeRobSecs(logic_movTime == 1); 
%        marker = getRobMarkers(robSignal);
%        movIni = marker(1) + ensayo(cmdStimIndx(1),1);
       
   else
       robSignal = 99999999;
       robTimeSec = 99999999;
   end
   
   if isempty(robSignal);
       robSignal = 1:1000;
       robTimeSec = 1:1000;
   end
%    robTimeSec = robTimeSec*srate2msecs;
   
   suma = 1;
   noStimFin= 1;
    while noStimFin
        if length(m) < cmdStimIndx(1) + suma;
            badInfo = 1;
            noStimFin= 0;
            stimFin = 999;
            tiempoMedido = 999;
        elseif m(cmdStimIndx(1) + suma) ~= 0;
            suma = suma + 1; 
        else
            noStimFin = 0;
        end
    end
    if badInfo == 0;
        stimFin = ensayo(cmdStimIndx(1) + suma,1);
        tiempoMedido = (stimFin-0.2) - movIni;
    end
    % ANGULO DE ROTACION
    
    % Inicio de la transmisión
    
    suma = 1;
    noArTransmit = 1;
    while noArTransmit
        if length(m) < cmdIniIndx(1) + suma;
            badInfo = 1;
            noArTransmit = 0;
            ar = 999;
        elseif m(cmdIniIndx(1) + suma) ~= 255;
            suma = suma + 1; 
        else
            noArTransmit = 0;
        end
    end
    
    if badInfo == 0;
        arTransmitIni = cmdIniIndx(1) + suma;

        % Fin de la transmisión

        suma = 1;
        noArTransmitFin = 1;
        while noArTransmitFin
            if m(arTransmitIni + suma) ~= 254;
                suma = suma + 1; 
            else
                noArTransmitFin = 0;
            end
        end
        arTransmitFin = arTransmitIni + suma;

        % Decodificacion de la informacion
        cents = m(arTransmitIni -1);
        dec = m(arTransmitFin-1)/10;
        arStr = [num2str(cents),num2str(dec)];
        ar = str2double(arStr);
        if ar > 300
            ar = ar -360;
        end


        % RESPUESTA

        % Inicio de la transmisión
        suma = 1;
        noRespTransmit = 1;
        while noRespTransmit
            if length(m) < arTransmitFin + suma;
                badInfo = 1;
                noRespTransmit = 0;
                resp = 999;
            elseif m(arTransmitFin + suma) ~= 255;
                suma = suma + 1; 
            else
                noRespTransmit = 0;
            end
        end
        
        if badInfo == 0
            respTransmitIni = arTransmitFin + suma;

            % Fin de la transmisión
            suma = 1;
            noRespTransmitFin = 1;
            while noRespTransmitFin
                if m(respTransmitIni + suma) ~= 254;
                    suma = suma + 1; 
                else
                    noRespTransmitFin = 0;
                end
            end
            respTransmitFin = respTransmitIni + suma;

            % Decodificacion de la informacion
            % en la matriz results 2 = -1; 1 = 1
            resp = m(respTransmitIni-1);
            if resp == 2;
                resp = -1;
            end


            % EVALUACION DE LA RESPUESTA

            % Inicio de la transmisión
            suma = 1;
            noEvalTransmit = 1;
            while noEvalTransmit
                if length(m) < respTransmitFin + suma;
                    badInfo = 1;
                    noEvalTransmit = 0;
                    evalResp = 999;
                elseif m(respTransmitFin + suma) ~= 255;
                    suma = suma + 1; 
                else
                    noEvalTransmit = 0;
                end
            end
            
            if badInfo == 0;
                evalTransmitIni = respTransmitFin + suma;

                % Fin de la transmisión
                suma = 1;
                noEvalTransmitFin = 1;
                while noEvalTransmitFin
                    if m(evalTransmitIni + suma) ~= 254;
                        suma = suma + 1; 
                    else
                        noEvalTransmitFin = 0;
                    end
                end
                evalTransmitFin = evalTransmitIni + suma;

                % Decodificacion de la informacion
                % en la matriz results 1 = 0; 2 = 1
                evalResp = m(evalTransmitIni-1)-1;


                % ANGULO DE INICIO

                % Inicio de la transmisión
                suma = 1;
                noAiTransmit = 1;
                while noAiTransmit
                    if length(m) < evalTransmitFin + suma;
                        badInfo = 1;
                        noAiTransmit = 0;
                        ai = 999;
                    elseif m(evalTransmitFin + suma) ~= 255;
                        suma = suma + 1; 
                    else
                        noAiTransmit = 0;
                    end

                end
                
                if badInfo == 0;
                    aiTransmitIni = evalTransmitFin + suma;

                    % Fin de la transmisión
                    suma = 1;
                    noAiTransmitFin = 1;
                    while noAiTransmitFin
                        if m(aiTransmitIni + suma) ~= 254;
                            suma = suma + 1; 
                        else
                            noAiTransmitFin = 0;
                        end
                    end
                    aiTransmitFin = aiTransmitIni + suma;

                    % Decodificacion de la informacion
                    cents = m(aiTransmitIni -1);
                    dec = m(aiTransmitFin-1)/10;
                    aiStr = [num2str(cents),num2str(dec)];
                    ai = str2double(aiStr);
                    if ai > 300;
                        ai = ai -360;
                    end


                    % ANGULO OBJETIVOS

                    % Inicio de la transmisión
                    suma = 1;
                    noTargTransmit = 1;

                    while noTargTransmit
                        if length(m) < aiTransmitFin + suma 
                            badInfo = 1;
                            noTargTransmit = 0;
                        elseif m(aiTransmitFin + suma) ~= 255;
                            suma = suma + 1;
                        else
                            noTargTransmit = 0;
                        end
                    end

                    if badInfo == 0
                        targTransmitIni = aiTransmitFin + suma;

                        % Fin de la transmisión
                        suma = 1;
                        noTargTransmitFin = 1;

                        while noTargTransmitFin
                            if m(targTransmitIni + suma) ~= 254;
                                suma = suma + 1; 
                            else
                                noTargTransmitFin = 0;
                            end
                        end
                        targTransmitFin = targTransmitIni + suma;

                        % Decodificacion de la informacion
                        cents = m(targTransmitIni -1);
                        dec = m(targTransmitFin-1)/10;
                        targStr = [num2str(cents),num2str(dec)];
                        targ = str2double(targStr);


                        % ESTAMPA DE VOLTAJE

                        % Inicio de la transmisión
                        suma = 1;
                        noVoltTransmit = 1;
                        while noVoltTransmit
                            if length(m) < targTransmitFin + suma;
                                badInfo = 1;
                                noVoltTransmit = 0;
                                voltStamp = 999;
                            elseif m(targTransmitFin + suma) ~= 255;
                                suma = suma + 1; 
                            else
                                noVoltTransmit = 0;
                            end
                        end
                        
                        if badInfo == 0;
                            voltTransmitIni = targTransmitFin + suma;

                            % Fin de la transmisión
                            suma = 1;
                            noVoltTransmitFin = 1;
                            while noVoltTransmitFin
                                if m(voltTransmitIni + suma) ~= 254;
                                    suma = suma + 1; 
                                else
                                    noVoltTransmitFin = 0;
                                end
                            end
                            voltTransmitFin = voltTransmitIni + suma;

                            % Decodificacion de la informacion
                            cents = m(voltTransmitIni -1);
                            dec = m(voltTransmitFin-1)/10;
                            voltStr = [num2str(cents),num2str(dec)];
                            voltStamp = str2double(voltStr);


                            % ESTAMPA DE TIEMPO

                            % Inicio de la transmisión
                            suma = 1;
                            noTimeStampTransmit = 1;
                            while noTimeStampTransmit
                                if length(m) < voltTransmitFin + suma;
                                    badInfo = 1;
                                    noTimeStampTransmit = 0;
                                    timeStamp = 999;
                                elseif m(voltTransmitFin + suma) ~= 255;
                                    suma = suma + 1; 
                                else
                                    noTimeStampTransmit = 0;
                                end
                            end
                            
                            if badInfo == 0
                                timeStampTransmitIni = voltTransmitFin + suma;

                                % Fin de la transmisión
                                suma = 1;
                                noTimeStampTransmitFin = 1;
                                while noTimeStampTransmitFin
                                    if m(timeStampTransmitIni + suma) ~= 254;
                                        suma = suma + 1; 
                                    else
                                        noTimeStampTransmitFin = 0;
                                    end
                                end
                                timeStampTransmitFin = timeStampTransmitIni + suma;

                                % Decodificacion de la informacion
                                cents = m(timeStampTransmitIni -1);
                                dec = m(timeStampTransmitFin-1)/10;
                                timeStampStr = [num2str(cents),num2str(dec)];
                                timeStamp = str2double(timeStampStr);


                                %TIEMPO

                                % Inicio de la transmisión
                                suma = 1;
                                noTimeTransmit = 1;
                                while noTimeTransmit
                                    if length(m) < timeStampTransmitFin + suma;
                                        badInfo = 1;
                                        noTimeTransmit = 0;
                                        time = 999;
                                    elseif m(timeStampTransmitFin + suma) ~= 255;
                                        suma = suma + 1; 
                                    else
                                        noTimeTransmit = 0;
                                    end
                                end
                                
                                if badInfo == 0
                                    timeTransmitIni = timeStampTransmitFin + suma;

                                    % Fin de la transmisión
                                    suma = 1;
                                    noTimeTransmitFin = 1;
                                    while noTimeTransmitFin
                                        if m(timeTransmitIni + suma) ~= 254;
                                            suma = suma + 1; 
                                        else
                                            noTimeTransmitFin = 0;
                                        end
                                    end
                                    timeTransmitFin = timeTransmitIni + suma;

                                    % Decodificacion de la informacion
                                    cents = m(timeTransmitIni -1);
                                    dec = m(timeTransmitFin-1)/10;
                                    timeStr = [num2str(cents),num2str(dec)];
                                    time = str2double(timeStr);

                                    % VELOCIDAD

                                    % Inicio de la transmisión
                                    suma = 1;
                                    noVelTransmit = 1;
                                    while noVelTransmit
                                        if length(m) < timeTransmitFin + suma;
                                            badInfo = 1;
                                            noVelTransmit = 0;
                                            vel = 999;
                                        elseif m(timeTransmitFin + suma) ~= 255;
                                            suma = suma + 1; 
                                        else
                                            noVelTransmit = 0;
                                        end
                                    end
                                    
                                    if badInfo == 0;
                                        velTransmitIni = timeTransmitFin + suma;

                                        % Fin de la transmisión
                                        suma = 1;
                                        noVelTransmitFin = 1;
                                        while noVelTransmitFin
                                            if m(velTransmitIni + suma) ~= 254;
                                                suma = suma + 1; 
                                            else
                                                noVelTransmitFin = 0;
                                            end
                                        end
                                        velTransmitFin = velTransmitIni + suma;

                                        % Decodificacion de la informacion
                                        cents = m(velTransmitIni -1);
                                        dec = m(velTransmitFin-1);
                                        if length(num2str(dec)) == 1;
                                            dec = [num2str(0), num2str(dec)];
                                            velStr = [num2str(cents), dec];
                                        else
                                            velStr = [num2str(cents),num2str(dec)];
                                        end
                                        vel = str2double(velStr);


                                        %% 	CATEGORIA

                                        % Inicio de la transmisión
                                        suma = 1;
                                        noCategTransmit = 1;
                                        while noCategTransmit
                                            if length(m) < velTransmitFin + suma;
                                                badInfo = 1;
                                                noCategTransmit = 0;
                                                categ = 999;
                                            elseif m(velTransmitFin + suma) ~= 255;
                                                suma = suma + 1; 
                                            else
                                                noCategTransmit = 0;
                                            end
                                        end
                                        
                                        if badInfo == 0    
                                            categTransmitIni = velTransmitFin + suma;

                                            % Fin de la transmisión
                                            suma = 1;
                                            noCategTransmitFin = 1;
                                            while noCategTransmitFin
                                                if m(categTransmitIni + suma) ~= 254;
                                                    suma = suma + 1; 
                                                else
                                                    noCategTransmitFin = 0;
                                                end
                                            end
                                            categTransmitFin = categTransmitIni + suma;

                                            % Decodificacion de la informacion
                                            cents = m(categTransmitIni -1);
                                            dec = m(categTransmitFin-1)/10;
                                            categStr = [num2str(cents),num2str(dec)];
                                            categ = str2double(categStr);

                                            matresults(i,:) = [ai, ar, resp, evalResp, vel, categ, targ, voltStamp, timeStamp, time];
                                            movFin = (movIni + tiempoMedido) - 0.15;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    
    if badInfo == 1;
        matresults(i,:) = 999;
        ai = 999;
        ar = 999;
        resp = 999;
        evalResp = 999;
        vel = 999;
        categ = 999;
        targ = 999;
        voltStamp = 999;
        timeStamp = 999;
        time = 999;
        movFin = 999;
        badInfo = 0;
    end
% Guardar toda la informacion del ensayo en la estructura trial



    trial(i) = struct('initialAngle', ai,...
                    'rotationAngle', ar,...
                    'velocity', vel,...
                    'time', time,...
                    'measuredTime', tiempoMedido,...
                    'category', categ,...
                    'targAngle', targ,...
                    'choice', resp,...
                    'correct', evalResp,...
                    'digitalInfo', ensayo,...
                    'timeStamp', tstamp,...
                    'waitCueStart', waitCueIni,...
                    'handFixStart', manosFijasIni,...
                    'waitCueEnd', waitCueFin,...
                    'touchCueStart', touchCueIni,...
                    'handFixEnd', manosFijasFin,...
                    'touchStart', touchIni,...
                    'cmdStim',cmdStimRot(1),...
                    'movStart',movIni,...
                    'movEnd',movFin,...
                    'stimEnd', stimFin,...
                    'touchCueEnd', touchCueFin,...
                    'touchEnd',touchFin,...
                    'waitRespStart', waitRespIni,...
                    'targOn', targOn,...
                    'waitRespEnd', waitRespFin,...
                    'targOff',targOff,...
                    'robSignal', robSignal(1:1000),...
                    'robTimeSec', robTimeSec(1:1000));

end

 disp('Creando estructura...')
    e = struct('Date', fecha,...
            'DateRaw', fechaR,...
            'NEVfile', archivoNEV,...
            'ResTemp', resTemp,...
            'rawData', fromBlackRock,...
            'matResults',matresults,...
            'trial', trial,...
            'spikes',spikes);

% disp('Guardando...')
% save(saveName, 'e');

else
    e = nan;
end
%%


disp('Terminado.')

