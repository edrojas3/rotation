function colapsed = colapseMagnitudes(e, magnitudes, alignEvent, limits)
%%
alignEvent = 'movIni';
aligned = selectTrials(e, 'alignEvent', alignEvent);
lim1 = alignEvent;
lim2 = 'movFin';

for i = 1:length(aligned.events)
   frate = firingrate(aligned.spikes(i).spike31,samples,...
                            'FilterType','exponential',...
                            'TimeConstant',0.1,...
                             'Attrit', [aligned.events(i).(lim1), aligned.events(i).(lim2)]);
                         plot(samples, frate); hold on
end


