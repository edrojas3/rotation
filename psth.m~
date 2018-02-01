
aligned = selectTrials(e,'alignEvent', 'touchIni');
edges = -1:0.01:1;
persth = zeros(1,length(edges));

for trial = 1:length(aligned.events)
    persth(trial,:) = histc(aligned.spikes(trial).spike11, edges);
end
plot(edges, persth)

%%
 persth = histc(aligned.spikes(1).spike11, edges);
sd = 0.008;
lims = -1*sd:0.001:1*sd;
kernel = normpdf(lims, 0, sd);
kernel = kernel*0.001;
s = conv(persth,kernel);
center = ceil(length(lims)/2);
plot(s)
