results(:,9) = results(:,9).* sign(results(:,2))
vels = unique(results(:,9));
%%
h = zeros(size(vels));
trials = hits;
for i = 1:length(vels)
    h(i) = sum(results(results(:,9) == vels(i),2) == 1);
    trials(i) = length(results(results(:,9) == vels(i),2));
end

f = zeros(size(vels));

proportion = hits./trials;
plot(proportion, 'ob')

[logitCoef, dev] = glmfit(vels, [hits, trials], 'binomial', 'link','probit');
logitFit = glmval(logitCoef, vels, 'probit', 'size', trials);
plot(vels, proportion, 'bs', vels, logitFit, 'r-');
xlabel('vels'); ylabel('Proportion')
%%
posV = vels(vels > 0);
hits = zeros(size(posV));
trials = hits;
for i = 1:length(posV)
    hits(i) = sum(results(results(:,9) == posV(i),3));
    trials(i) = length(results(results(:,9) == posV(i),3));
end

hitRate = hits./trials;

negV = vels(vels < 0);
negV = sort(negV,'descend')
false = zeros(size(posV));
falseTrials = false;
for i = 1:length(negV)
    false(i) = sum(results(results(:,9) == negV(i),3) == 0);
    falseTrials(i) = length(results(results(:,9) == negV(i),3));
end

falseRate = false./falseTrials

%%
[b, dev, stats] = glmfit(stimLevels, [izqResp, n], 'binomial', 'link', 'probit');
yfit = glmval(b,stimLevels, 'probit', 'size', n);
plot(stimLevels, izqResp./n, 'ok',stimLevels, yfit./n)