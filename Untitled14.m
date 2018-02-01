clf; clc

matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\recordings';
matfiles = dir([matdir, '\*.mat']);
savedir = 'C:\Users\eduardo\Documents\proyectos\rotacion\alignTemplate\alignedSignals';
for f = 1:length(matfiles)
    %%
    clf
    disp([num2str(f), '/', num2str(length(matfiles))])
    id = matfiles(f).name;
    id = 'c1606071543';
    load([matdir, '\',id])
    A = [-0.1, 0.1, -0.2, 0.2, -0.4, 0.4, -0.8, 0.8, -1.6, 1.6, -3.2, 3.2];
    signal_template = nan(1000, length(A));
    
    for ang = 1:length(A)
        
        a = A(ang);
        angulos = round([e.trial.anguloRotacion]*10)/10;
        trials = sum(angulos == a);
        trials_index = find(angulos == a);
        s = [e.trial(angulos == a).robSignal];
        
        if isempty(s); continue; end
        signal = double(reshape(double(s), 1000, trials));
        timeSec = reshape( [e.trial(angulos == a).robTimeSec], 1000, trials );

        for s = 1:size(signal,2)
           m = mean(signal(1:350,s)) ;
           sd = std(signal(1:350,s));
           signal(:,s) = scale01((signal(:,s) - m) / sd);  
        end

        % align to first trial
        template = signal(:,1);
        k = [];        
        for d = 1:size(signal,2)
            k(d) = alignSignal(template, signal(:,d));
        end
        
        signal_lag = nan(size(signal));
        for n = 1:size(signal,2)
            indices = [1:1000]-k(n) ;
            if k(n) > 0;
                signal_crop = signal(indices > 0,n);
                signal_lag(1:length(signal_crop), n) = signal_crop;

            elseif k(n) < 0;
                signal_crop = signal(1:1000-abs(k(n)),n);
                signal_lag(abs(k(n))+1:end,n) = signal_crop; 

            elseif k(n) == 0;
                signal_lag(:,n) = signal(:,n);
            end
        end
        
        % Get movement template
        if sign(A(ang)) == 1
            signal_mean = scale01(nanmean(signal_lag,2));
        else
            signal_mean = scale01(-1*(nanmean(signal_lag,2)));
        end
        
        try
            markers = getRobMarkers(signal_mean);
        catch err
            continue
        end
        len_sigmean = length(signal_mean);
        len_markers = length([markers(1):markers(2)]);
        
        signal_template(1:len_markers, ang) = signal_mean(markers(1):markers(2));
        signal_template(1:100, ang) = scale01(signal_template(1:100, ang));
    end
    clf
    plot(signal_template(1:100,:))
        %%
        start_lag = nan(size(signal));
        len = length(signal_template)-1;

        for n = 1:size(signal,2)
            sig = scale01(signal(:,n));
            if all(isnan(sig)); continue; end
            
            for d = 1:length(sig)-length(signal_template)
                section = sig(d:d+len);
                section_diff(d)  = max(abs(signal_template - section));
            end

            [~, ind] = min(section_diff(300:800));
            movini = ind+299; %timeSec(ind,n);
            movfin = movini+len; %timeSec(ind + len,n);
            duracion(n) = movfin - movini;
            ts = [movini-100:movfin+100] - movini;
            if movfin+100 > 1000; continue; end
            subplot(6,2,ang)
            plot(ts,sig(movini-100:movfin+100), 'color', [0.7,0.7,0.7]); hold on
            plot([0, 0 + len], [sig(movini), sig(movfin)], '*'); 
        end
        
%         plot([markers(1):markers(2)] - markers(1), signal_template, 'r', 'linewidth', 1)
        set(gca, 'xlim', [-50,400], 'ylim', [-0.1, 1.1], 'box', 'off')
        title(num2str(A(ang)))
    end
%     savename = [savedir, '\', id(1:end-4), '.png'];
%     saveas(gcf, savename)
%     clf
end
     
 
    
 