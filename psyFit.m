function datos = psyFit(results, stimType, varargin)

fitfunc = getArgumentValue('fitfunc', 'logistic', varargin{:});
color = getArgumentValue('c', 'b', varargin{:});
results = round(results.*10)./10;

switch stimType
    case 'ainicial'
        stim = results(:,1);
        r = 4;
        xl = 'Angulo Inicial';
    case 'arotacion'
        stim = results(:,2);
        r = 2;
        xl = 'Angulo de rotacion';
    case 'afinal'
        stim = results(:,1) + results(:,2);
        results(:,end+1) = stim;
        r = size(results,2);
        xl = 'Angulo final';
    case 'velocidad'
        results(:,9) = (results(:,9).*sign(results(:,1)))/92;
        stim = results(:,9);
        r = 9;
        xl = 'Velocidad (°/s)';
    case 'tiempo'
        results(:,8) = results(:,8).*sign(results(:,1));
        stim = results(:,8);
        r = 8;
        xl = 'Tiempo(s)';
end

 fitfunc
r
unique(stim)
%%
switch fitfunc
    case 'weibull'
        PF = @PAL_Weibull;
        stimLevels = unique(stim);
        numResp = zeros(size(stimLevels));
        n = numResp;
        for i = 1:length(stimLevels)
           resp = results(results(:,r) == stimLevels(i), 3);
           numResp(i) = sum(resp == 1);
           n(i) = length(resp);
        end
        difer = zeros(size(stimLevels));
        difer(1) = 1;
        for i = 1:length(stimLevels)-1
           difer(i+1) = difer(i) + abs(stimLevels(i) - stimLevels(i+1));
        end
        stimLevels = difer;

        searchGrid.alpha = length(stimLevels)/2:.01:1+length(stimLevels)/2;    %structure defining grid to
        searchGrid.beta = 10.^[-1:.01:2]; %search for initial values
        searchGrid.gamma = [0:.01:.06];
        searchGrid.lambda = [0:.01:.06];

        paramsFree = [1 1 1 1]; 

        [paramsValues,LL,exitflag] = PAL_PFML_Fit(stimLevels, numResp, n, ...
        searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
        [0 1]);

        stimLevelsLine = stimLevels(1):0.1:stimLevels(end);
        outcomes = PAL_Weibull(paramsValues,stimLevelsLine);

        plot(stimLevels,numResp./n, 'o', 'Color', color, 'MarkerFaceColor', color, 'LineWidth', 2, 'MarkerSize',5);
        hold on
        plot(stimLevelsLine,outcomes, '-', 'Color', color, 'MarkerFaceColor', color, 'LineWidth',2, 'MarkerSize', 5);
        xlabel(xl)
        ylabel('Probabilidad de contestar izquierda')
        set(gca, 'ylim', [-0.05,1.05])
%%

    case 'logistic'
       
        PF = @PAL_Logistic;
        stimLevels = unique(stim);
        numResp = zeros(size(stimLevels));
        n = numResp;
        for i = 1:length(stimLevels)
           resp = results(results(:,r) == stimLevels(i), 3);
           numResp(i) = sum(resp == 1);
           n(i) = length(resp);
        end

        searchGrid.alpha = [-0.5:.01:0.5];    %structure defining grid to
        searchGrid.beta = 10.^[-1:.01:2]; %search for initial values
        searchGrid.gamma = [0:.01:.06];
        searchGrid.lambda = [0:.01:.06];

        paramsFree = [1 1 1 1]; 

        [paramsValues,LL,exitflag] = PAL_PFML_Fit(stimLevels, numResp, n, ...
        searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
        [0 1]);

        stimLevelsLine = stimLevels(1):0.1:stimLevels(end);
        outcomes = PAL_Logistic(paramsValues,stimLevelsLine);

        plot(stimLevels,numResp./n, 'o', 'Color', color, 'MarkerFaceColor', color, 'LineWidth', 2, 'MarkerSize',5);
        hold on
        plot(stimLevelsLine,outcomes, '-', 'Color', color, 'MarkerFaceColor', color, 'LineWidth',2, 'MarkerSize', 5);
        
        xlabel(xl)
        ylabel('Probabilidad de contestar izquierda')
        set(gca, 'ylim', [-0.05,1.05])
end

%%
datos = struct('estimulos', stimLevels,...
            'numResp', numResp,...
            'numEnsayos', n,...
            'pResp', numResp./n,...
            'alpha', paramsValues(1),...
            'beta', paramsValues(2),...
            'fitx', stimLevelsLine,...
            'fity', outcomes);
