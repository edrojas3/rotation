function [] = psylogfit(files, matdir,varargin)

color = getArgumentValue('color','k',varargin{:});
anglist = [];
resplist = [];
for f = 1:length(files)
    load([matdir,filesep,files(f).name])
    session_angs = [e.trial.anguloRotacion];
    session_angs = round(session_angs*10) / 10;
    respuesta = [e.trial.respuesta]';
    
    anglist = [anglist; session_angs'];
    resplist = [resplist; respuesta];
    
end

results = [anglist, resplist];
PF = @PAL_Logistic;

A = [0.1,0.2,0.4,0.8,1.6,3.2];
A = sort([-A,A]);
stimLevels = A;
numResp = zeros(size(stimLevels));
n = numResp;
for i = 1:length(stimLevels)
   resp = results(results(:,1) == stimLevels(i), 2);
   numResp(i) = sum(resp == 1);
   n(i) = length(resp);
end

searchGrid.alpha = [-0.5:.01:0.5];    %structure defining grid to
searchGrid.beta = 10.^[-1:.01:2]; %search for initial values
searchGrid.gamma = [0:.01:.06];
searchGrid.lambda = [0:.01:.06];

paramsFree = [1 1 1 1]; 
loglevels = [-log(abs(A(1:6)))+5,log(A(7:end))+10];

[paramsValues,LL,exitflag] = PAL_PFML_Fit(loglevels, numResp, n, ...
searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
[0 1]);

stimLevelsLine = loglevels(1):0.1:loglevels(end);
outcomes = PAL_Logistic(paramsValues,stimLevelsLine);

plot(loglevels,numResp./n, 'o', 'Color', color, 'MarkerFaceColor', color, 'LineWidth', 2, 'MarkerSize',5);
hold on
plot(stimLevelsLine,outcomes, '-', 'Color', color, 'MarkerFaceColor', color, 'LineWidth',2, 'MarkerSize', 5);

ylabel('Probabilidad de contestar izquierda')
% set(gca, 'ylim', [-0.05,1.05])