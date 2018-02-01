addpath(genpath('C:\Users\eduardo\Dropbox\rotacion'))
%% Datos iniciales
id = 'd1603311120';
%id = 'd1603301122';

nevData = ['C:\Users\eduardo\Google Drive\Exp mono\',id,'.nev'];
ns1File = ['C:\Users\eduardo\Google Drive\Exp mono\', id, '.ns1'];

% nevData = ['/home/eduardo/Dropbox/rotacion/nevfiles/', id, '.nev'];
% ns1File = ['/home/eduardo/Dropbox/rotacion/nsfiles/', id, '.ns2'];

% nevData = ['/home/eduardo/Documents/proyectos/rotacion/nevfiles/', id, '.nev'];
% ns1File = ['/home/eduardo/Documents/proyectos/rotacion/nsfiles/', id, '.ns2'];

% obtener los datos de cada ensayo a partir del archivo nev
e = blackRock2event(nevData,ns1File);
%save(['/home/eduardo/Documents/proyectos/rotacion/matfiles/results_dewey/registro/', id],'e');

%% Exclude trials
t = [1:50,145:length(e.trial)];
e.trial(t) = [];
e.spikes(t) = [];
% Seleccionar y alinear eventos
%close all
% tini = 1;
% tend = 110;
% e.trial = e.trial(tini:tend);
% e.spikes = e.spikes(tini:tend);

%% Raster data settings
% Excluir ensayos incorrectos
% ntrials =]
ntrials = 1:length(e.trial);
correctos = [e.trial.correcto]';
ntrials(correctos == 0) = []; % eliminar ensayos incorrectos

% Ordenar ensayos dependiendo del �ngulo de rotaci�n (en el raster las rotaciones a la derecha aparecen abajo)

arot = [[e.trial(ntrials).anguloRotacion]', ([e.trial(ntrials).anguloRotacion]' < 0)*-1, ntrials'];
arot(arot(:,2) == 0, 2) = 1;
ar_sort = sortrows(arot,1);
[ar_abs_sort, index] = sortrows(abs(ar_sort(:,1)));
sortmatrix = [ar_abs_sort, ar_sort(index,2), ar_sort(index,3)];
topright = sortrows(sortmatrix,2);
sorted_trials = topright(:,3);



%   trialLims = find(sorted_trials > 180 & sorted_trials < 300);
%  sorted_trials = sorted_trials(trialLims);
% % % 
% % sorted_trials = 1:150;
sorted_trials = [1:length(e. trial)]';

spike_names = fieldnames(e.spikes)
%
%%
close all
spike_id = {spike_names{1}};
xlim = [-4,4];
figure 

subplot(231)
alignEvent = 'manosFijasFin';
myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
title([id ' ' spike_id{1} ' ' alignEvent ' n=' num2str(length(sorted_trials))])

subplot(232)
alignEvent = 'touchIni';
myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
title(alignEvent);

subplot(233)
alignEvent = 'movIni';
myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
title(alignEvent);

% subplot(234)
% alignEvent = 'movFin';
% myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
% title(alignEvent);

subplot(235)
alignEvent = 'touchFin';
myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
title(alignEvent);
% 
% subplot(236)
% alignEvent = 'targOn';
% myrasterplot(e,spike_id,alignEvent,sorted_trials,xlim)
% title(alignEvent);

%     subplot(236)
%     alignEvent = 'targOff';
%     myrasterplot(e,spike_id,alignEvent,sorted_trials)
%     title(alignEvent);
   
   
    %%

    % Tasa de disparo dependiendo del angulo de inicio
 ylim = [0,10];
    figure
    ainicial = [-4,0,4];
   
        sortbyinicial = sortrows([[e.trial(sorted_trials).anguloInicio]', sorted_trials],1);
        selected = selectTrials(e,'alignEvent','touchIni');

        ai_izq = sortbyinicial(sortbyinicial(:,1) < 0,2);
        fr_ai_izq = firingrate({selected.spikes(ai_izq).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
        fr_ai_izq_mean = nanmean(fr_ai_izq);

        ai_der = sortbyinicial(sortbyinicial(:,1) > 0,2);
        fr_ai_der = firingrate({selected.spikes(ai_der).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
        fr_ai_der_mean = nanmean(fr_ai_der);

        ai_z = sortbyinicial(sortbyinicial(:,1) == 0,2);
        fr_ai_z = firingrate({selected.spikes(ai_z).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
        fr_ai_z_mean = nanmean(fr_ai_z);

        subplot(141)
        plot(samples, fr_ai_izq_mean, 'color', azul); hold on
        plot(samples, fr_ai_der_mean, 'color', amarillo)
        plot(samples, fr_ai_z_mean, 'color', 'k')
        legend('ai4','ai-4', 'ai0', 'location', 'northwest')
        set(gca, 'xlim', [-0.5, 0.5], 'ylim', ylim,'box',box, 'colororder',colororder)
        title([id, ' ', spike_id{1}, ' ', 'touchIni'])
%         axis('square')
   

    % Tasa de disparo dependiendo de la magnitud y direcci�n de la rotacion
    sortbyrot = sortrows([[e.trial(sorted_trials).anguloRotacion]', sorted_trials],1);
    arotacion = [e.trial.anguloRotacion];
    arotacion = unique(arotacion(arotacion < 20))*-1;

    colormat = zeros(length(arotacion),3);
    colormat(1:size(colormat,1)/2,3) = 1;
    colormat((size(colormat,1)/2)+1:end,1) = 1;
    greenspec = linspace(0,1,size(colormat,1)/2);
    greenmat = [greenspec(length(greenspec):-1:1),greenspec]';
    colormat(:,2) = greenmat;

    subplot(142)
    selected = selectTrials(e,'alignEvent','movIni');
    for k = 1:length(arotacion);
        arx = sortbyrot(sortbyrot(:,1) == arotacion(k),2);
        fr_arx = firingrate({selected.spikes(arx).(spike_id{1})},samples,...
                            'FilterType','exponential',...
                            'TimeConstant',0.1);
        fr_arx_mean = nanmean(fr_arx);

    %     plot(arotacion(k),'o', 'markerfacecolor', colormat(k,:), 'markeredgecolor',colormat(k,:)); hold on
        plot(samples, fr_arx_mean,'color',colormat(k,:)); hold on
        set(gca, 'xlim', [-0.5, 0.5], 'ylim', ylim,'box',box, 'color','w')
%         axis('square')
        title('movIni')
    end

    subplot(143)
    selected = selectTrials(e,'alignEvent','movFin');
    for k = 1:length(arotacion);
        
        arx = sortbyrot(sortbyrot(:,1) == arotacion(k),2);
        fr_arx = firingrate({selected.spikes(arx).(spike_id{1})},samples,...
                            'FilterType','exponential',...
                            'TimeConstant',0.1);
        fr_arx_mean = nanmean(fr_arx);

    %     plot(arotacion(k),'o', 'markerfacecolor', colormat(k,:), 'markeredgecolor',colormat(k,:)); hold on
        plot(samples, fr_arx_mean,'color',colormat(k,:)); hold on
    end
    set(gca, 'xlim', [-0.5, 0.5], 'ylim', ylim,'box',box, 'color','w')
%     axis('square')
    title('movFin')
    
    subplot(144)
    selected = selectTrials(e,'alignEvent','targOn');
    for k = 1:length(arotacion);
        arx = sortbyrot(sortbyrot(:,1) == arotacion(k),2);
        fr_arx = firingrate({selected.spikes(arx).(spike_id{1})},samples,...
                            'FilterType','exponential',...
                            'TimeConstant',0.1);
        fr_arx_mean = nanmean(fr_arx);

    %     plot(arotacion(k),'o', 'markerfacecolor', colormat(k,:), 'markeredgecolor',colormat(k,:)); hold on
        plot(samples, fr_arx_mean,'color',colormat(k,:)); hold on
        set(gca, 'xlim', [-0.5, 0.01], 'ylim', ylim,'box',box, 'color','w')
%         axis('square')
        title('targOn')
    end

%% Rob Signal
arot = unique([e.trial.anguloRotacion]');

selected_ar = selectTrials(e, 'alignEvent','touchIni','anguloRotacion', -3);
signal = zeros(length(selected_ar.events),1000);

for i = 1:length(selected_ar.events)
   signal(i,:) = selected_ar.events(i).robSignal;
end

template = mean(signal);
s = selected_ar.events(1).robSignal;



%% OLD CODE

% Seprar ensayos por direcci�n y magnitud y ordenarlos
rightTrials = selectTrials(e,'alignEvent', alignEvent, 'rotDir',-1);
leftTrials = selectTrials(e,'alignEvent', alignEvent, 'rotDir',1);
    % Ordenar los ensayos por parámetros del estímulo
right = [rightTrials.events.anguloRotacion]';
left =  [leftTrials.events.anguloRotacion]';
[right sorted_right] = sortrows(abs(right),-1);
[left sorted_left] = sortrows(left,-1);
aligned = struct('events',rightTrials.events(sorted_right),...
                  'spikes',rightTrials.spikes(sorted_right));
aligned.events(end+1:end+length(sorted_left)) = leftTrials.events(sorted_left);
aligned.spikes(end+1:end+length(sorted_left)) = leftTrials.spikes(sorted_left);

% rasterplot
for j = 1:length(aligned.spikes);
   spike_times = aligned.spikes(j).(spike_names{s});
   if length(spike_times) > 1;
       spikes = ones(size(spike_times));
       spikes(spikes == 0) = nan;
       plot(spike_times,spikes*j,'ok','markerfacecolor','g','markersize',4)
   end
end

%% Alineaciones por características del estímulo
alignEvent = 'movIni';
%spike = 'spike12';
% rotaciones a la izquierda
selected = selectTrials(e,'alignEvent',alignEvent,...
                        'aciertos',1,...
                        'rotDir',1);
samples = -5:0.1:5;
fr = firingrate({selected.spikes.(spike)},samples,'FilterType','exponential','TimeConstant',0.1);
fr_mean = nanmean(fr);

figure

subplot(121)
plot(samples,fr_mean)
set(gca, 'xlim', [-0.5, 1], 'ylim', ylim)
title([alignEvent, ' rotacion izq'])

selected = selectTrials(e,'alignEvent',alignEvent,...
                        'aciertos',1,...
                        'rotDir',-1);
samples = -5:0.1:5;
fr = firingrate({selected.spikes.(spike)},samples,'FilterType','exponential','TimeConstant',0.1);
fr_mean = nanmean(fr);

subplot(122)
plot(samples,fr_mean)
set(gca, 'xlim', [-0.5, 1], 'ylim', ylim)
title([alignEvent, ' rotacion der'])


%% Borradores

[xm, ym] = getmarkers(aligned.events,sorted_trials,...
                                           'manosFijasIni',...  1
                                           'manosFijasFin',...  2
                                           'waitCueIni',...     3
                                           'waitCueFin',...     4
                                           'touchIni',...       5
                                           'movIni',...         6
                                           'movFin',...         7
                                           'touchFin',...       8
                                           'touchCueIni',...    9
                                           'touchCueFin',...    10
                                           'waitRespIni',...    11
                                           'waitRespFin',...    12
                                           'targOn',...         13
                                           'targOff');          %14

                                       
%%
alignEvent = 'touchIni';
aligned = selectTrials(e,'alignEvent',alignEvent);
rasterplot({aligned.spikes.spike52});


%% %% Firing Rate
    %close all
    %spike_id = {'spike31'};

    left_trials = sortmatrix(sortmatrix(:,2) == 1, 3);
    right_trials = sortmatrix(sortmatrix(:,2) == -1, 3);
    samples = -5:0.01:5;

    ylim = [0,85];
    
    box = 'off';
    ycolor = [0.8,0.8,0.8];
    azul = [0,0.05,1];
    amarillo = [1,0.5,0];
    colororder = [azul;amarillo];
    lw = 2;

    % Alineaciones por evento

     figure
    % Alineación al inicio del ensayo

    left_trials = sort(left_trials);
    alignEvent = 'manosFijasIni';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,...
                        'FilterType','exponential',...
                        'TimeConstant',0.1);
                        
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);

    subplot(241)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    legend('izq','der'); xlabel('Tiempo (s)'); ylabel('spk/s'); 
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title([id, ' ', spike_id{1}, ' ', alignEvent])

    % Alineación al movimiento de alcance
    alignEvent = 'manosFijasFin';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);


    subplot(242)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim',ylim,'box',box)
    title(alignEvent)

    % Alineación al contacto con el objeto
    alignEvent = 'touchIni';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);

    subplot(243)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title(alignEvent)

    % Alineación al contacto con inicio del movimiento del objeto
    alignEvent = 'movIni';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,...
                         'FilterType','exponential',...
                         'TimeConstant',0.1,...
                         'Attrit',[[selected.events(left_trials).touchIni]', [selected.events(left_trials).movFin]']);
    fr_leftmean = nanmean(fr_left);
    
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,...
                        'FilterType','exponential',...
                        'TimeConstant',0.1,...
                        'Attrit',[[selected.events(right_trials).touchIni]', [selected.events(right_trials).movFin]']);
    fr_rightmean = nanmean(fr_right);

    subplot(244)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.2, 1], 'ylim', ylim,'box',box)
    title(alignEvent)

    % Alineación al contacto con el final del movimiento del objeto
    alignEvent = 'movFin';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,...
                         'FilterType','exponential',...
                         'TimeConstant',0.1,...
                         'Attrit',[[selected.events(left_trials).movIni]', [selected.events(left_trials).touchFin]']);
    fr_leftmean = nanmean(fr_left);
    
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,...
                        'FilterType','exponential',...
                        'TimeConstant',0.1,...
                        'Attrit',[[selected.events(right_trials).movIni]', [selected.events(right_trials).touchFin]']);
    fr_rightmean = nanmean(fr_right);
    
    subplot(245)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title(alignEvent)

    % Alineación al final del contacto con el objeto
    alignEvent = 'touchFin';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);

    subplot(246)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title(alignEvent)

    % Alineación al contacto con la aparición de los objetivos
    alignEvent = 'targOn';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);

    subplot(247)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title(alignEvent)

    % Alineación a la respuesta
    alignEvent = 'targOff';
    selected = selectTrials(e,'alignEvent',alignEvent);
    fr_left = firingrate({selected.spikes(left_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_leftmean = nanmean(fr_left);
    fr_right = firingrate({selected.spikes(right_trials).(spike_id{1})},samples,'FilterType','exponential','TimeConstant',0.1);
    fr_rightmean = nanmean(fr_right);

    subplot(248)
    plot(samples,fr_leftmean,'color',azul,'linewidth',lw)
    hold on
    plot(samples,fr_rightmean,'color',amarillo,'linewidth',lw)
    set(gca, 'xlim', [-0.5, 1], 'ylim', ylim,'box',box)
    title(alignEvent)