function [] = raster2(e, spike_id, alignEvent,sorted_trials)
lcolor = [0.4,0.4,0.4];
figure('units','normalized','outerposition',[0 0 1 1])
switch alignEvent
    case 'noOrder'
        aligned = selectTrials(e,'alignEvent','movIni');
        rasterplot({aligned.spikes.(spike_id)});
        set(gca, 'ylim',[1, length(aligned.spikes)]);
    case 'manosFijasFin';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
                'xlim',xlim,...
                'color','k');
               
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3)
        title (alignEvent)

        subplot(122)
        getfrs(e,spike_id,'alcance', 'samples', samples);
        set(gca,'xlim',xlim)
    %%
    case 'touchIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
                'xlim',xlim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3)
        title (alignEvent)

        subplot(122)
        getfrs(e,spike_id,'anguloInicio', 'samples', samples);
        set(gca,'xlim',xlim)

    %%
    case 'movIni';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
                'xlim',xlim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        [xm, ym] = getmarkers(aligned.events,sorted_trials,'movFin');
        line(xm, ym,'linestyle','none','linewidth',3,'color','r','marker','.','markersize',6);

        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3)
        title (alignEvent)

        subplot(122)
        getfrs(e,spike_id,'anguloRotacion', 'samples', samples);
        set(gca,'xlim',xlim)
    %%
    case 'targOn';
        aligned = selectTrials(e,'alignEvent',alignEvent);
        xlim = [-1,1];
        samples = xlim(1):.01:xlim(2);
        subplot(121)
        rasterplot({aligned.spikes(sorted_trials).(spike_id)},...
                'xlim',xlim,...
                'color','k');
        set(gca,'xlim',xlim, 'ylim', [1,length(sorted_trials)])
        line ([0,0], [1,length(sorted_trials)], 'color', lcolor, 'linewidth', 3)
        title (alignEvent)
        
        subplot(122)
        getfrs(e,spike_id,'targOn', 'samples', samples);
        set(gca,'xlim',xlim)
end