files = dir('C:\Users\eduardo\Documents\proyectos\rotacion\robSignals\bestrecs\*.png');
matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs';

% alignEvents = {'manosFijasIni', 'touchCueIni', 'manosFijasFin', 'touchIni', 'robMovIni', 'touchFin', 'targOn', 'targOff'};
% endEvents = {{'touchCueIni'}, {'manosFijasFin'}, {'touchIni'}, {'robMovIni'}, {'robMovFin','touchFin'}, {'targOn'}, {'targOff'}};
% labels = {'Wait', 'Cue', 'Reach', 'Contact', 'StimOn', 'Back', 'Resp'};

alignEvents = {'manosFijasIni','touchIni', 'robMovIni'};
endEvents = {{'touchIni'}, {'robMovIni'}, {'robMovFin','targOff'}};
labels = {'Wait', 'Contact', 'Stim On'};

%
close all
pause(0.5)
samples = -1:0.01:1;
samp_index = find(samples >= -0.3 & samples < 0.5)
time_axis = samples(samp_index);
timestep = 1.5;
tau = 0.1;
minrate = [];
% classif = cell(1,12);
% counter = 1;
% f = 18;
for f = 1:1%length(files)
    lastf = f;
    id = files(f).name(1:end-4) ;
    load([matfiles, '\', id])
    spikeids = fieldnames(e.slice);
    
    for s = 1:1%length(spikeids)
        lasts = s;
        disp([files(lastf).name(1:end-4), spikeids{lasts}])
        load([matfiles, '\', id])
        spk = spikeids{s};
        slice = e.slice.(spk);
        e = eslice(e, slice);
        subplot(2,1,1)
        alleventsraster(e, spk, {alignEvents{1:end}}, endEvents, labels);
        

        for ae = 1:length(alignEvents)
            aligned = selectTrials(e, 'alignEvent', alignEvents{ae}, 'delnotfound', 1);
            spks = {aligned.spikes.(spk)};
            
%             samples = min([aligned.events.manosFijasIni]):0.01:max([aligned.events.targOff]);
            
            lefts = [aligned.events.anguloRotacion] > 0;
%             left_attrit = [[aligned.events(lefts == 1).(alignEvents{ae})]'-0.3, [aligned.events(lefts == 1).(alignEvents{ae+1})]'];
            left_frate = firingrate({spks{lefts == 1}}, samples, 'FilterType', 'exponential', 'TimeConstant', tau);
            left_mean = nanmean(left_frate(:,samp_index));
            
%             right_attrit = [[aligned.events(lefts == 0).(alignEvents{ae})]'-0.3, [aligned.events(lefts == 0).(alignEvents{ae+1})]'];
            right_frate = firingrate({spks{lefts == 0}}, samples, 'FilterType', 'exponential',  'TimeConstant', tau);
            right_mean = nanmean(right_frate(:,samp_index));
            
%             event_bl = [left_mean(1:30), right_mean(1:30)];
%             event_mean = mean(event_bl);
%             event_std = std(event_bl);
            
            subplot(2,1,2)
%             if strcmp(alignEvents{ae}, 'manosFijasIni');
%                 bl = [left_mean, right_mean];
%                 bl_mean = mean(bl);
%                 bl_std = std(bl);
%                 
%                 bl_bounds = [-0.29, -bl_std + bl_mean, 6.5+0.3,bl_std*2];
%                 rectangle('position', bl_bounds, 'facecolor', [0.8,0.8,0.8], 'edgecolor', [0.8,0.8,0.8]); hold on
%                 
%                 line([-0.3,6.5], [bl_mean, bl_mean], 'linestyle', '--', 'color', [0.5,0.5,0.5])
%             end
%             
%             event_bl_bounds = [time_axis(1), -event_std + event_mean, time_axis(end) - time_axis(1), event_std*2];
%             if all(event_bl_bounds);
%                 rectangle('position', event_bl_bounds, 'facecolor', [1,1,0.6157], 'edgecolor', [1,1,0.6157])
%             end
            plot(time_axis, left_mean, 'b'); hold on
            plot(time_axis, right_mean, 'r')
            
            time_axis = time_axis + timestep;

            minrate(ae) = min([left_mean,right_mean]);
            maxrate(ae) = max([left_mean,right_mean]);
        end   
        
        
        xlim = [-0.3,  max(time_axis - timestep)];
        ylim = [min(minrate), max(maxrate)];
        set(gca, 'xlim', xlim, 'ylim', ylim, 'box', 'off')
        
        markers = 0:6;
        line([markers; markers]*timestep, repmat(ylim',1,7), 'color', [0.5,0.5,0.5])
   
%         classif{counter, 1} = id;
%         classif{counter,2} = spk;
        
%         baseline = input('Baseline: ');
%         if isempty(baseline);
%            cue      = [0,0] ;
%            reach    = [0,0, 0] ;
%            touch    = [0,0] ;
%            stim     = [0,0] ;
%            delay    = [0,0] ;
%            back     = [0,0,0] ;
%            resp     = [0,0] ;
%            stimpref = 0;
%            resppref = 0;
%            
%         else
%         
%             cue     = input('Cue: ');
%             reach   = input('Reach: ');
%             touch   = input('Touch: ');
%             stim    = input('Stim: ');
%             delay   = input('Delay: ');
%             back    = input('Back: ');
%             resp    = input('Resp: ');
%             stimpref = input('stimpref: ');
%             resppref = input('resppref: ');
%         end
%         classif{counter,3}  = baseline;
%         classif{counter,4}  = cue;
%         classif{counter,5}  = reach;
%         classif{counter,6}  = touch;
%         classif{counter,7}  = stim;
%         classif{counter,8}  = delay;
%         classif{counter,9}  = back;
%         classif{counter,10} = resp;
%         classif{counter,11} = stimpref;
%         classif{counter,12} = resppref;
        
%         save('classification', 'classif')
%         saveas(gcf, ['C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates2\', id, spk, '.png'])
%         counter = counter +1;
%         clf
        
    end
    
    
   
end
