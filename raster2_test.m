function [] = raster2_test(e, spikeid, alignEvent,sorted_trials)
lcolor = [0.4,0.4,0.4];
%figure('units','normalized','outerposition',[0 0 1 1])
ylim = [1,length(sorted_trials)];
switch alignEvent
    case 'noOrder'
        aligned = selectTrials(e,'alignEvent','movIni');
        rasterplot({aligned.spikes.(spikeid)});
        set(gca, 'ylim',[1, length(aligned.spikes)]);
    case 'manosFijasFin';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3); hold on
        rasterplot({aligned.spikes(sorted_trials).(spikeid)},...
                'xlim',xlim,...
                'ylim',ylim,...
                'color','k');
        [xmarkers, ymarkers] = getmarkers(aligned.events, sorted_trials, 'touchIni');
        plot(xmarkers, ymarkers, 'o', 'markerfacecolor', 'r', 'markeredgecolor','r','markersize',5)
%                
%         set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        
        fname = strsplit(e.ArchivoNEV,'.');
        title ([fname{1},spikeid, ' ', alignEvent])

        subplot(122)
        getfrs(e,spikeid,'alcance', 'samples', samples);
        set(gca,'xlim',xlim)
    %%
    case 'touchIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        rasterplot({aligned.spikes(sorted_trials).(spikeid)},...
                'xlim',xlim,...
                'ylim',ylim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3)
        
        fname = strsplit(e.ArchivoNEV,'.');
        title ([fname{1},spikeid, ' ', alignEvent])
        
        subplot(122)
        getfrs(e,spikeid,'anguloInicio', 'samples', samples);
        set(gca,'xlim',xlim)

    %%
    case 'movIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        
        subplot(121)
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3); hold on
        
        rasterplot({aligned.spikes(sorted_trials).(spikeid)},...
                'xlim',xlim,...
                'ylim',ylim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        [xm, ym] = getmarkers(aligned.events,sorted_trials,'movFin');
        line(xm, ym,'linestyle','none','linewidth',3,'color','r','marker','.','markersize',6);

        fname = strsplit(e.ArchivoNEV,'.');
        title ([fname{1},spikeid, ' ', alignEvent])

        subplot(122)
        getfrs(e,spikeid,'anguloRotacion', 'samples', samples);
        set(gca,'xlim',xlim)
    %%
    case 'targOn';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        
        subplot(121)
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3); hold on
        rasterplot({aligned.spikes(sorted_trials).(spikeid)},...
                'xlim',xlim,...
                'ylim',ylim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        
        fname = strsplit(e.ArchivoNEV,'.');
        title ([fname{1},spikeid, ' ', alignEvent])
        
        subplot(122)
        getfrs(e,spikeid,'targOn', 'samples', samples);
        set(gca,'xlim',xlim)
end