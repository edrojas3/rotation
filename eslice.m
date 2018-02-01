function e = eslice(e, slicing)

e.trial = e.trial(slicing == 1);
e.spikes = e.spikes(slicing == 1);