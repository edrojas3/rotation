clear all; close all; clc

matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
matfiles = dir([matdir, '\*.mat']);

A = [0.1,0.2,0.4,0.8,1.6,3.2];
angs = [-A,A];
% angs = [-1.6,1.6];
% angs = [0.1,-0.1,0.2,-0.2,0.4,-0.4,0.8,-0.8,1.6,-1.6,3.2,-3.2];

D = [0.064,0.084,0.102,0.154,0.292,0.546];
duraciones = [D,D];
% duraciones = [0.64,0.64,0.084,0.084,0.102,0.102,0.154,0.154,0.292,0.292,0.546,0.546];
% duraciones = [0.292,0.292];
% id = 'c1609191754';
% spk = 'spike12';

for f = 106:length(matfiles)
    disp([num2str(f),'\', num2str(length(matfiles))])
    id = matfiles(f).name(1:end-4);
%     id = 'c1609021640';
%     id = 'c1606011551';
    load([matdir,'\',id])
    
    angulos = round([e.trial.anguloRotacion]*10)/10;
%     angs = unique(angulos);
    for a = 1:length(angs)
       
        % Señal por cada ángulo
        signals = reshape([e.trial(angulos == angs(a)).robSignal],1000, sum(angulos == angs(a))) ;
        signals = submean(scale01(signals)); 
        trial_index = find(angulos == angs(a));
%         plot(signals)
%         pause
%         clf
%         continue

        % Alinear señales a la del primer ensayo
        signals_aligned = zeros(size(signals));
        for ss = 1:size(signals,2)
            signals_aligned(:,ss) = alignSignal(signals(:,2), signals(:,ss), 'scaling', 1);
        end
        
        % Template de la señal filtrada y marcadores del template
        
        signals_mean = mean(signals_aligned,2); 
%         signals_mean = mean(signals,2);
        
%         plot(signals_aligned, 'color', [0.5,0.5,0.5]); hold on
%         plot(signals_mean, 'r', 'linewidth',2); 
%         pause; clf
%         continue
        
        markers = getRobMarkers(filtSant(filtSant(signals_mean)));
        template = signals_mean(markers(1):markers(2));
        lenTemplate = length(template);
        
%         plot(signals_mean, 'k', 'linewidth',2); hold on
%         plot(markers(1):markers(2), template, 'r', 'linewidth',2)
%         pause; clf
%         continue
        
        % Diferencia entre la señal y el template. 
        lenSignal = size(signals,1);
        for ss = 1:size(signals,2)
            
            signal = scale01(signals(:,ss));
            t = zeros(size(template));
            differ = [];
            t = template;
%             t(1:round(lenTemplate/2)) = template(1:round(lenTemplate/2)) + mean(signal(1:300));
%             t(1+round(lenTemplate/2):end) = template(1+round(lenTemplate/2):end) + mean(signal(900:1000));
            for d = 1:lenSignal - lenTemplate
               s = signal(d:d+lenTemplate-1); 
               differ(d) = mean(abs(t - s));
              
%                plot(signal,'k'); hold on
%                plot(d:d+lenTemplate-1,signal(d:d+lenTemplate-1),'r')
%                plot(d:d+lenTemplate-1,t, 'g')
%                plot(d+(lenTemplate/2), differ(d),'ob')
%                title(num2str(differ(d)))
%                pause
%                clf
               
            end

%             Marcadores de inicio y fin a partir de la diferencia
            [markini, ini_indx] = min(differ);
            calcfin_indx = ini_indx + lenTemplate -1;
            fixedfin_indx = ini_indx + ((duraciones(a)*1000)/2);
            calculated_markers = [ini_indx, calcfin_indx];
            fixed_markers = [ini_indx, fixedfin_indx];
            
            % Añadir valor a estructura
            e.trial(trial_index(ss)).robMovIni = e.trial(trial_index(ss)).robTimeSec(ini_indx);
            e.trial(trial_index(ss)).robMovFin = e.trial(trial_index(ss)).robTimeSec(fixedfin_indx);
            
%             e.trial(trial_index(ss)).robMovFin = e.trial(trial_index(ss)).movIni;
%             e.trial(trial_index(ss)).robMovFin = e.trial(trial_index(ss)).movFin;  
            
            % Graficar señal por ensayo con sus respectivos marcadores
%             plot(signal,'k'); hold on
%             plot(calculated_markers, signal(calculated_markers), 'og', 'markerfacecolor', 'g')
%             plot(fixed_markers, signal(fixed_markers), 'ob', 'markerfacecolor', 'b')
%             title([id, ' Stim: ', num2str(angs(a))])
            
        end
%          pause; clf
        
        
        % Guardar estructura
        save([matdir, '\', id], 'e')
    end
end

