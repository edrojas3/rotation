function [rocmean, rocmat] = rocIndexGraphs(rocstruct,rocfield,varargin)
%
% rocIndexGraphs() function that calculates the average of the roc indexes
% for the specified magnitudes. If no output is requested, the function
% plots the roc indexes.
%
% rocIndexGraphs(rocstruct,rocfield)

% set rotation magnitudes
A = getArgumentValue('angles',4:6,varargin{:});
plotType = getArgumentValue('plotType','mean',varargin{:});
color = getArgumentValue('color','k',varargin{:});
lenA = length(A);
timeSec = rocstruct.timeSec;

if strcmp(plotType,'individual')
    datacell = {rocstruct.(rocfield).index};
    glevel = linspace(0.2,0.8,lenA);
    b = [zeros(lenA,1), glevel', ones(lenA,1)];
    r = [ones(lenA,1), glevel', zeros(lenA,1)];
    g = [zeros(lenA,1), glevel', zeros(lenA,1)];
    k = [glevel',glevel',glevel'];
    eval(['color = eval(color);'])
    for a = 1:lenA
        plot(timeSec,nanmean(datacell{A(a)}), 'color', color(a,:),'linewidth',2); hold on
    end
elseif strcmp(plotType, 'mean')
    rocmat = [];
    N = size(rocstruct.(rocfield)(A(1)).index,1);
    for n = 1:N
        rocperneuron = [];
        for a = 1:lenA
           rocperangle = rocstruct.(rocfield)(A(a)).index(n,:);
           rocperneuron = [rocperneuron;rocperangle];
        end
        if lenA > 1;
            rocmat = [rocmat;nanmean(rocperneuron)];
        else
            rocmat = [rocmat;rocperneuron];
        end
    end
    rocmean = nanmean(rocmat);
    
    if nargout == 0;
        if color == 'b';
            lightcolor = [0.5,0.5,1];
        elseif color == 'r';
            lightcolor = [1,0.5,0.5];
        else
            lightcolor = [0.5,0.5,0.5];
        end
        
        plot(timeSec,rocmat,'color',lightcolor)
        hold on
        plot(timeSec,rocmean,'color',color,'linewidth',3)
    end
end
