function [poprates, samples, FR] = populationRates(ids,directory,varargin)
% Uses the files in a directory to get the population firing rates
% USAGE: 
% [poprates, samples] = populationRates(ids,directory)
% populationRates(ids,directory)
% In both cases ids is a cell with a list of names and unit identifiers:
% ex. ids =
% {'d1609010850spike11','d1609010929spike11','d1609011131spike11'}.
% directory is where the recording session matfiles are located.
% Optional input arguments:
%   - alignEvent (touchIni,robMovIni,etc.; default = robMovIni)
%   - angles (default = 0.1,0.2,0.4,0.8,1.6,3.2)
%   - hits (1 = hits, 0 = errors; default = 1)
%   - samples (default = -0.5:0.01:1)
%   - tau (defaul = 0.5)

alignEvent = getArgumentValue('alignEvent','robMovIni',varargin{:});
A = getArgumentValue('angles',[0.1,0.2,0.4,0.8,1.6,3.2],varargin{:});
hits = getArgumentValue('hits',1,varargin{:});
samples = getArgumentValue('samples',-0.5:0.01:1,varargin{:});
tau = getArgumentValue('tau',0.5,varargin{:});

%%
FR = cell(2,length(A));
for f = 1:length(ids)
    disp([num2str(f),'/',num2str(length(ids)),': ' ids{f}])
    load([directory,filesep,ids{f}(1:11)])
    spk = ids{f}(12:end);
    for a = 1:length(A)
       
        FR{1,a} = [FR{1,a};fratenorm(e,spk,'angles',A(a),'bothways',0,'alignEvent',alignEvent,'hits',hits,'samples',samples,'tau',tau)];
        FR{2,a} = [FR{2,a};fratenorm(e,spk,'angles',-A(a),'bothways',0,'alignEvent',alignEvent,'hits',hits,'samples',samples,'tau',tau)];

    end    
end

poprates = cell(2,length(A));
for c = 1:size(FR,2)
   poprates{1,c} = [poprates{1,a};nanmean(cell2mat(FR{1,c}))];
   poprates{2,c} = [poprates{2,a};nanmean(cell2mat(FR{2,c}))];
end
%%
if nargout == 0
    lenA = length(A);
    glevel = linspace(0,1,lenA);
    b = [zeros(lenA,1), glevel', ones(lenA,1)];
    r = [ones(lenA,1), glevel', zeros(lenA,1)];
    g = [zeros(lenA,1), glevel', zeros(lenA,1)];

    for a = 1:length(A)
        plot(samples,poprates{1,a},'linewidth',2,'color',b(a,:)); hold on
        plot(samples,poprates{2,a},'linewidth',2,'color',r(a,:))

    end
    xlabel('Time from align event (s)'); ylabel('Normalized firing rate (z-score)');
    set(gca,'box','off')
    grid on
    legend('left','right')
    hold off

end

