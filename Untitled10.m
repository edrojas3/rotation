clf; clc

files = dir('C:\Users\eduardo\Documents\proyectos\rotacion\robSignals\bestrecs\*.png');
% files = dir('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings\*.mat');
matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';
% matfiles = dir([matdir, '\*.mat']);
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\alignTemplate\alignedSignals';
A = [-0.1, 0.1, -0.2, 0.2, -0.4, 0.4, -0.8, 0.8, -1.6, 1.6, -3.2, 3.2];
duraciones = [0.064, 0.064, 0.084, 0.084, 0.102, 0.102, 0.154, 0.154, 0.292, 0.292, 0.546, 0.546]/2;

for f = 54:length(files)
    %%
%     clf
%     disp([num2str(f), '/', num2str(length(matfiles))])
    id = files(f).name(1:end-4);
%     id = 'c1608111342';
    load([matdir, '\',id])
   
%     if isfield(e.trial, 'robMovIni'); continue; end
    disp(id)
    for ang = 1:length(A)
        a = A(ang);
        angulos = round([e.trial.anguloRotacion]*10)/10;
        trials = sum(angulos == a);
        trials_index = find(angulos == a);
        s = [e.trial(angulos == a).robSignal];
        if isempty(s); continue; end
        signal = reshape(double(s), 1000, trials);
        timeSec = reshape( [e.trial(trials_index).robTimeSec], 1000, trials );

        for s = 1:size(signal,2)
           m = mean(signal(1:350,s)) ;
           sd = std(signal(1:350,s));
           if sd == 0; sd = 1;end
           signal(:,s) = (signal(:,s) - m) / sd;  

        end

        % align to first trial
        template = scale01(signal(:,1));
        len = length(template);
        lags = -(len-1):len-1;
        signal_diff = [];%zeros(1000, length(lags));
        for n = 1:size(signal,2);
            signal2 = scale01([nan(999,1); signal(:,n);nan(999,1)]);
            for d = 1:length(lags)
                signal_diff(:,d) = max(abs(template - signal2(d:d+999)));%corr(signal2(d:d+999), template); 
            end
            [~, ind] = min(signal_diff(900:1400));
            lags_sec = lags(900:1400);
            k(n) = lags_sec(ind);
        end

        signal_lag = nan(size(signal));
        for n = 1:size(signal,2)
            indices = [1:1000]-k(n) ;

            if k(n) > 0;
                signal_crop = signal(indices > 0,n);
                signal_lag(1:length(signal_crop), n) = scale01(signal_crop);

            elseif k(n) < 0;
                signal_crop = signal(1:1000-abs(k(n)),n);
                signal_lag(abs(k(n))+1:end,n) = scale01(signal_crop); 

            elseif k(n) == 0;
                signal_lag(:,n) = scale01(signal(:,n));
            end
        end

        % Get movement template
        signal_mean = nanmean(signal_lag,2);
        signal_mean(isnan(signal_mean) == 1) = [];
        signal_mean = filtsignal(signal_mean);
        try
            markers = getRobMarkers(signal_mean);
        catch err
            continue
        end
        signal_template = scale01(signal_mean(markers(1):markers(2)));

        % Use the template to find the start of the signal.
        start_lag = nan(size(signal));
        len = length(signal_template)-1;
 
        for n = 1:size(signal,2)
            sig = scale01(signal(:,n));
            if all(isnan(sig)); (disp('all nans')); break; end
            for d = 1:length(sig)-length(signal_template)
                section = sig(d:d+len);
                section_diff(d)  = max(abs(signal_template - section));
               
            end
             
            [~, ind] = min(section_diff(300:800));
            movini = ind+299; %timeSec(ind,n)
            movfin = movini+duraciones(ang)*1e3; %timeSec(ind + len,n);
            if movfin+100 > 1000; disp('movfin too big'); continue; end
            e.trial(trials_index(n)).robMovIni = timeSec(movini,n);
            e.trial(trials_index(n)).robMovFin = timeSec(movfin,n);
            if isempty(e.trial(trials_index(n)).robMovIni);error('no movini'); end
%             plot(section_diff); hold on
%             plot(sig, 'r')
%             plot(signal_template, 'k')
%                 pause 
%                 clf

        end
        save([matdir, '\', id], 'e')
    end
    
 
end
 
%%
clf
aligned = selectTrials(e, 'alignEvent', 'robMovIni');
signals = double(reshape([aligned.events(trials_index).robSignal], 1000, length(aligned.events(trials_index))));
ts_aligned = double(reshape([aligned.events(trials_index).robTimeSec], 1000, length(aligned.events(trials_index))));
plot(ts_aligned, signals)
hold on

% signals = double(reshape([e.trial(trials_index).robSignal], 1000, length(e.trial(trials_index))));
% plot(signals, 'color', [0.5,0.5,0.5])


    

    
    
    
    
    
    
 %%   
    
    clf
    plot(signal_norm(:,n)); hold on
    plot([start_I, end_I], [signal_norm(start_I,n),signal_norm(end_I,n) ], '*r')
    pause
    clf
signal1 = scale01(signal(:,1));
s = 3;
% for s = 1:size(signal,2)
    signal2 = scale01(signal(:,s));
    [coef, lags] = xcorr(signal2, signal1);
    [~, index] = max(coef);
    L(s) = lags(index);
    plot(lags, scale01(coef), 'g'); hold on
    plot(1:1000,signal1, 'b')
    plot(1:1000,signal2,'r')
    
% end

%%
ini = [e.trial(angulos == a).robMarkIni];
fin = [e.trial(angulos == a).robMarkfin];
% aligned = selectTrials(e,'alignEvent',iniEvent);
% angulos = round([aligned.events.anguloRotacion]*10)/10;
% trials = sum(angulos == a);
% s = [aligned.events(angulos == a).robSignal];
% signal = reshape(double(s), 1000, trials);
% timeSec = reshape( [aligned.events(angulos == a).robTimeSec], 1000, trials );
% ini = [aligned.events.robMarkIni];
% fin = [aligned.events.robMarkfin];

for i = 1:trials;
    markers = getRobMarkers(signal(:,i));
    markers = [timeSec(markers(1),i), timeSec(markers(2),i)];
    
    signal_filt = filtsignal(signal(:,i), 15, 70);
    subplot(2,1,1)
    plot(timeSec(:,i), scale01(signal(:,i))); hold on
    plot(timeSec(:,i), scale01(signal_filt), 'r')
%     line([ini(i), fin(i); ini(i), fin(i)], [min(signal(:,i)), min(signal(:,i)); max(signal(:,i)), max(signal(:,i))], 'color', 'r')
%     line([markers; markers], [min(signal(:,i)), min(signal(:,i)); max(signal(:,i)), max(signal(:,i))], 'color', 'k')
    set(gca, 'xlim', [min(timeSec(:,i)), max(timeSec(:,i))])
    
    subplot(2,1,2)
    getRobMarkers(signal(:,1));
    pause
    clf
end

% i = 1;
% signal_min = min(signal(:,i));
% signal_max = max(signal(:,i));
% signal_range = signal_max - signal_min;
% signal_scale = (signal(:,i) - signal_min) ./ signal_range;
% plot(signal_scale, 'r');hold on
% shg