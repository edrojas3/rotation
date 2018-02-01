alignEvent = 'manosFijasFin';
aligned = selectTrials(e, 'alignEvent', alignEvent);
[mfx, mfy] = rasterplot({aligned.spikes(sorted_trials).(spike_id{1})}, 'xlim', [-0.1, 0.1]);

alignEvent = 'touchIni';
aligned = selectTrials(e, 'alignEvent', alignEvent);
[tix, tiy] = rasterplot({aligned.spikes(sorted_trials).(spike_id{1})}, 'xlim', [-0.2, 0.2]);

alignEvent = 'movIni';
aligned = selectTrials(e, 'alignEvent', alignEvent);
[rix, riy] = rasterplot({aligned.spikes(sorted_trials).(spike_id{1})}, 'xlim', [-0.1, 0.9]);

alignEvent = 'movFin';
aligned = selectTrials(e, 'alignEvent', alignEvent);
[rfx, rfy] = rasterplot({aligned.spikes(sorted_trials).(spike_id{1})}, 'xlim', [-0.2, 0.2]);

alignEvent = 'touchFin';
aligned = selectTrials(e, 'alignEvent', alignEvent);
[tfx, tfy] = rasterplot({aligned.spikes(sorted_trials).(spike_id{1})}, 'xlim', [-0.2, 0.2]);



mfx = mfx + 0.1;
tix = tix + 0.2 + 0.22;

rix = rix + 0.1 + 0.42 ;
rfx = rfx + 0.1 + 1.43;
tfx = tfx + 0.2 + 1.84;
plot([mfx, tix, rix, rfx, tfx], [mfy,tiy, riy, rfy, tfy], '.k')