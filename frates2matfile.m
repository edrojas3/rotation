recordings = 'C:\Users\eduardo\Google Drive\Exp mono';
matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles';
[~,~,ddata] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\dfigs\database.xls');
[~,~,cdata] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\cdb.xls');

ddata = ddata(2:end-8,[1:3,5]);
cdata = cdata(2:end,[1:3,5]);

data = [cdata;ddata];

samples = -0.3:0.05:1.3;
timeSec = samples;
tau = 0.3;

alignEvent = {'waitCueIni', 'touchCueIni', 'manosFijasFin','touchIni','robMarkIni','robMarkfin','touchCueFin','targOn','targOff'};

A = [0.1,0.2,0.4,0.8,1.6,3.2];
angulos_esperados = [-A, A];
left_str = 'left';
right_str = 'right';
lstr = 'lat_index';

for f = 114:size(data,1)
   
    disp([num2str(f),'/',num2str(size(data,1))])
    %%
    id = data{f,1};
    if isnan(str2double(id(end)));
        id = id(1:end-1);
    end
    
    spikeid = data{f,2};
    
    % Select "good" trials
    
    selection = data{f,4};
    totaltrials = data{f,3};
    if ~(isnan(selection));
        slicing = getSlicing(totaltrials, selection);
    else
        slicing = ones(1,totaltrials);
    end
        
    if exist([recordings,'\',id,'.nev'],'file')
        if id(1) == 'c';
            mono = 'cesar';
        else
            mono = 'dewey';
        end
    else
        continue
    end

    if isnan(str2double(id(end)));
        load ([matfiles,'\',mono,'\',id(1:end-1)]);
    else
        load ([matfiles,'\',mono,'\',id]);
    end

    e = eslice(e,slicing);
    angulos_encontrados = unique(round(10*[e.trial.anguloRotacion])/10);
    angulos_intersectados = ismember(round(angulos_encontrados*10)/10, angulos_esperados);
   
    if sum(angulos_intersectados) < 12 || length(e.trial) < 100;
        disp('poor record')
        continue
    end
    
     if ~(isfield(e.trial, 'robMarkIni'));
         for n = 1:length(e.trial);
            signal = double(e.trial(n).robSignal);
            signal = filtsignal(signal, 15, 70);
            ts = e.trial(n).robTimeSec;

            cmdini = e.trial(n).cmdStim;
            cmdfin = e.trial(n).stimFin;
            movini = e.trial(n).movIni;
            movfin = e.trial(n).movFin;

            tsini = cmdini < ts & ts < movini;
            ini = find(tsini == 1);
            if isempty(ini);
                startlim = [1,300];
            else
                startlim  = [ini(1), ini(end)];
            end

            tsend = movfin < ts & ts < cmdfin;
            fin = find(tsend == 1);
            if isempty(fin);
                endlim = [700, 1000];
            else
                endlim = [fin(1), fin(end)];
            end

            try 
                mark = getRobMarkers(signal, 'startlim', startlim, 'endlim', endlim);
            catch err
                e.trial(n).robMarkIni = movini;
                e.trial(n).robMarkfin = movfin;
%                 save([matdir, '\', id], 'e')
                continue
            end

            mark = [ts(mark(1)), ts(mark(2))];
            e.trial(n).robMarkIni = mark(1);
            e.trial(n).robMarkfin = mark(2);

        end
     end
    baseline = selectTrials(e,'alignEvent','manosFijasIni');
    baseline_fr = firingrate({baseline.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
    baseline_mean = mean(baseline_fr(:));
    baseline_std = std(baseline_fr(:));
    
    
    for ae = 1:length(alignEvent)-1
        left_st= cell(1,6);
        left_st_attrit = cell(1,6);
        right_st= cell(1,6);
        right_st_attrit = cell(1,6);
        left = [];
        right = [];
        nextae = 1;
        for ang = 1:length(A)
            left_trials = selectTrials(e,'alignEvent',alignEvent{ae},'anguloRotacion',A(ang),'aciertos',1);
            right_trials = selectTrials(e,'alignEvent',alignEvent{ae},'anguloRotacion',-A(ang),'aciertos',1);
            
            if ae == 5; nextae =2;end
            left_attrit = [[left_trials.events.(alignEvent{ae})]'-0.3, [left_trials.events.(alignEvent{ae+nextae})]'];
            right_attrit = [[right_trials.events.(alignEvent{ae})]'-0.3, [right_trials.events.(alignEvent{ae+nextae})]'];

            left_fr = firingrate({left_trials.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
            left_fr_attrit = firingrate({left_trials.spikes.(spikeid)},samples,'attrit',left_attrit,'FilterType','exponential','TimeConstant',tau); 
            
            right_fr = firingrate({right_trials.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
            right_fr_attrit = firingrate({right_trials.spikes.(spikeid)},samples,'attrit',right_attrit,'FilterType','exponential','TimeConstant',tau); 

            left_st{1,ang} = left_fr;
            left_st_attrit{1,ang} = left_fr_attrit;
            right_st{1,ang} = right_fr;
            right_st_attrit{1,ang} = right_fr_attrit;

            left_mat = [left; left_fr_attrit];
            right_mat = [right; right_fr_attrit];
        end

        left_mean = nanmean(left_mat);
        left_norm2lb = (left_mean - baseline_mean) / baseline_std;
        left_norm = (left_mean - mean(left_mean(1:7))) / std(left_mean(1:7));
        right_mean = nanmean(right_mat);
        right_norm2lb = (right_mean - baseline_mean) / baseline_std;
        right_norm = (right_mean - mean(right_mean(1:7))) / std(right_mean(1:7));

        
        lat_index = (left_mean - right_mean) ./ (left_mean + right_mean);

        left = struct('singleTrials', {left_st},...
                      'singleTrials_attrit', {left_st_attrit},...
                      'mean', left_mean,...
                      'norm2lb', left_norm2lb,...
                      'norm', left_norm);

        right = struct('singleTrials', {right_st},...
                      'singleTrials_attrit', {right_st_attrit},...
                      'mean', right_mean,...
                      'norm2lb', right_norm2lb,...
                      'norm', right_norm);

        eval([alignEvent{ae}, '= struct(lstr, lat_index,left_str, left, right_str, right);']);
    end
    % z norm
   alignEvent = {'waitCueIni', 'touchCueIni', 'manosFijasFin','touchIni','robMarkIni','robMarkfin','touchCueFin','targOn','targOff'};
   bl = struct('frates', baseline_fr, 'mean', baseline_mean, 'std', baseline_std);

   frates = struct('waitCueIni', waitCueIni,...
                    'touchCueIni', touchCueIni,...
                    'manosFijasFin', manosFijasFin,...
                    'touchIni', touchIni,...
                    'movIni', robMarkIni,...
                    'movFin', robMarkfin,...
                    'touchCueFin',touchCueFin,...
                    'targOn', targOn,...
                    'baseline', bl,...
                    'timeSec', timeSec);



    savename = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\frates\',id,spikeid];
    if exist(savename,'file');
        savename = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\frates',idspikeid, 'b'];
    end

    save(savename, 'frates');
end