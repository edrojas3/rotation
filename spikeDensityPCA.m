trialNum
aligned = selectTrials(e, 'alignEvent', 'robMovIni');
spikes = aligned.spikes(trialNum).(spikeid);
selectedSpikes = spikes >= -0.3 & spikes <= 0.3;
spiketimes = spikes(selectedSpikes == 1);

spkd = spikeDensity(spiketimes);
