%% Set Iniitial variables and load databases
file = 'C:\Users\eduardo\Documents\proyectos\rotacion\movini.xlsx';
recordings = 'C:\Users\eduardo\Google Drive\Exp mono';
matfiles = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles';

[~,~, selectedid] = xlsread(file);
selectedid = selectedid(2:end,:);
[~,~,ddata] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\dfigs\database.xls');
[~,~,cdata] = xlsread('C:\Users\eduardo\Documents\proyectos\rotacion\cdb.xls');

ddata = ddata(2:end-8,[1:3,5]);
cdata = cdata(2:end,[1:3,5]);

data = [cdata;ddata];

existcounter = 1;
noexistcounter = 1;
left_frates = [];
right_frates = [];
samples = -0.3:0.05:1.3;
timeSec = samples;
tau = 0.3;
%lbsamples = -1:0.5:1;
left_size = [];
right_size = [];
angulos = [];

alignEvent = {'waitCueIni', 'touchCueIni', 'manosFijasFin','touchIni','movIni','movFin','touchCueFin','targOn','targOff'};
%%
 
% This loop gets the mean firing rate of 8 phases of the task and saves it
% into a cell. Each row is an angle starting at -3.2; each column is a
% phase of the task. 
for f = 1:1%size(data,1)
    %%
    id = data{f,1};
    if isnan(str2double(id(end)));
        id = id(1:end-1);
    end
    
    if id(1) == 'c';
        monofiles = [matfiles,'\cesar'];
    else
        monofiles = [matfiles,'\dewey'];
    end
    
    if exist([monofiles,'\',id,'.mat']);
        spikeid = data{f,2};
        totaltrials = data{f,3};
        selection = data{f,4};

        if ~(isnan(selection));
            slicing = getSlicing(totaltrials, selection);
        else
            slicing = ones(1,totaltrials);
        end
        load([monofiles,'\',id])

        angulos_encontrados = unique(round(10*[e.trial.anguloRotacion])/10);
        if length(angulos_encontrados) < 12;
            continue
        end
        e = eslice(e,slicing);
        angulos_esperados = [-3.2,-1.6,-0.8,-0.4,-0.2,-0.1,0.1,0.2,0.4,0.8,1.6,3.2];
        angulos_intersectados = ismember(round(angulos_encontrados*10)/10, angulos_esperados);
        %angulos = [angulos;sum(angulos_intersectados)];
        if sum(angulos_intersectados) == 12;
            angulos = sort(angulos_encontrados(angulos_intersectados == 1));
            frates = cell(12,2);
            %% Get firing rate per angle
            angulos = (round(angulos*10))/10;
            frates = cell(12,8);
            for a = 1:12
                for ae = 1:length(alignEvent)-1
                    trials = selectTrials(e,'alignEvent',alignEvent{ae},'anguloRotacion',angulos(a),'aciertos',1);
                    fr = zeros(length(trials.events),length(samples));
                    for t = 1:length(trials.events)
                        attrit = [trials.events(t).(alignEvent{ae})-0.3, trials.events(t).(alignEvent{ae+1})];
                        fr(t,:) = firingrate({trials.spikes(t).(spikeid)},samples,'attrit',attrit,'FilterType','exponential','TimeConstant',tau); 
                    end
                    frates{a,ae} = nanmean(fr,1);
                end
            end
            save(['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\frates\',data{f,1},spikeid],...
        'frates')

        end
    else
        noexist(noexistcounter) = f;
        noexistcounter = noexistcounter + 1;
    end
    
    

%'baseline_fr','left_mean','right_mean','left_fr_norm', 'right_fr_norm','lat_index','timeSec')           
    
end


%%
% This loop uses selected data (selectedid cell; see initial variables) to obtain the firing rate per side of
% rotation, its normalization, and lateralization index. 
for f = 1:1%size(data)
    %%
    id = data{f,1};
    if isnan(str2double(id(end)));
        id = id(1:end-1);
    end
    
    spikeid = selectedid{f,2};
    spikeid = ['spike',num2str(spikeid)];
    
    if id(1) == 'd';
        data = ddata;
    else
        data = cdata;
    end
    
    % Find data in database for slicing (selecting "good" trials)
   
    selection = data{f,4};
    totaltrials = data{f,3};
    if ~(isnan(selection));
        slicing = getSlicing(totaltrials, selection);
    else
        slicing = ones(1,totaltrials);
    end
    notfound = 0;

    
    % Load data
%     if isnan(str2double(id(end)));
%         nevid = id(1:end-1);
%     else
%         nevid = id;
%     end
    if exist([recordings,'\',id,'.nev'],'file')
        if id(1) == 'c';
            mono = 'cesar';
        else
            mono = 'dewey';
        end

        if isnan(str2double(id(end)));
            load ([matfiles,'\',mono,'\',id(1:end-1)]);
        else
           load ([matfiles,'\',mono,'\',id]);
        end
        e = eslice(e,slicing);
        angulos = unique([e.trial.anguloRotacion]);
        angulos(angulos > 20) = [];
        angulos = [min(angulos), max(angulos)];
        angulos = (round(angulos*10))/10;
        left_trials = selectTrials(e,'alignEvent','movIni','anguloRotacion',angulos(2));
        right_trials = selectTrials(e,'alignEvent','movIni','anguloRotacion',angulos(1));
        baseline = selectTrials(e,'alignEvent','manosFijasIni');
        
        left_fr = firingrate({left_trials.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
        right_fr = firingrate({right_trials.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
        baseline_fr = firingrate({baseline.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
        
%         left_fr_norm = mean(left_fr)./mean(baseline_fr);
%         right_fr_norm = mean(right_fr)./mean(baseline_fr);
        
        % z norm
        baseline_mean = mean(baseline_fr(:));
        baseline_std = std(baseline_fr(:));
        left_fr_norm = mean(left_fr)/baseline_mean;
        right_fr_norm = mean(right_fr)/baseline_mean;
        lat_index = (left_fr_norm - right_fr_norm) ./ (left_fr_norm + right_fr_norm);
%         left_frates = [left_frates;left_fr_norm];
%         right_frates = [right_frates; right_fr_norm];
%         plot(samples, left_fr_norm, 'b'); hold on
%         plot(samples, right_fr_norm, 'r');
            
        savename = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\selectedMovIniFRs\tau300\',id,spikeid];
        if exist(savename,'file');
            savename = ['C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\selectedMovIniFRs\tau300\',idspikeid, 'b'];
        end
        
%         save(savename, 'left_fr','right_fr','baseline_fr','left_fr_norm','right_fr_norm','lat_index','timeSec');
    else
        noexist(noexistcounter) = f;
        noexistcounter = noexistcounter + 1;
    end
    
           
    
end

% save('C:\Users\eduardo\Dropbox\notes\stats_and_maths\selected_frates', 'left_frates', 'right_frates')

%%
% This loop obtains the firing rate per phase perside, its normalization,
% and lateralization index. 
A = [0.1,0.2,0.4,0.8,1.6,3.2];
angulos_esperados = [-A, A];
left_str = 'left';
right_str = 'right';
lstr = 'lat_index';

for f = 1:size(data,1)
   
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
    length(e.trial)

    angulos_encontrados = unique(round(10*[e.trial.anguloRotacion])/10);
    angulos_intersectados = ismember(round(angulos_encontrados*10)/10, angulos_esperados);

    if sum(angulos_intersectados) < 12;
      
        continue
    end

    baseline = selectTrials(e,'alignEvent','manosFijasIni');
    baseline_fr = firingrate({baseline.spikes.(spikeid)},samples,'FilterType','exponential','TimeConstant',tau); 
    baseline_mean = mean(baseline_fr(:));
    baseline_std = std(baseline_fr(:));
    
    
    for ae = 1:length(alignEvent)-1
        left_singleTrials = cell(1,6);
        right_singleTrials = cell(1,6);
        left = [];
        right = [];
        for ang = 1:length(A)
            left_trials = selectTrials(e,'alignEvent',alignEvent{ae},'anguloRotacion',A(ang),'aciertos',1);
            right_trials = selectTrials(e,'alignEvent',alignEvent{ae},'anguloRotacion',-A(ang),'aciertos',1);

            left_attrit = [[left_trials.events.(alignEvent{ae})]'-0.3, [left_trials.events.(alignEvent{ae+1})]'];
            right_attrit = [[right_trials.events.(alignEvent{ae})]'-0.3, [right_trials.events.(alignEvent{ae+1})]'];

            left_fr = firingrate({left_trials.spikes.(spikeid)},samples,'attrit',left_attrit,'FilterType','exponential','TimeConstant',tau); 
            right_fr = firingrate({right_trials.spikes.(spikeid)},samples,'attrit',right_attrit,'FilterType','exponential','TimeConstant',tau); 

            left_singleTrials{1,ang} = left_fr;
            right_singleTrials{1,ang} = right_fr;

            left_mat = [left; left_fr];
            right_mat = [right; right_fr];
        end

        left_mean = nanmean(left_mat);
        left_norm = (left_mean - baseline_mean) / baseline_std;
        right_mean = nanmean(right_mat);
        right_norm = (right_mean - baseline_mean) / baseline_std;
        
        
        lat_index = (left_norm - right_norm) ./ (left_norm + right_norm);

        left = struct('singleTrials', {left_singleTrials},...
                      'mean', left_mean,...
                      'normalized', left_norm);

        right = struct('singleTrials', {right_singleTrials},...
                      'mean', right_mean,...
                      'normalized', right_norm);

        eval([alignEvent{ae}, '= struct(lstr, lat_index,left_str, left, right_str, right);']);
    end
    % z norm
   alignEvent = {'waitCueIni', 'touchCueIni', 'manosFijasFin','touchIni','movIni','movFin','touchCueFin','targOn','targOff'};
   bl = struct('frates', baseline_fr, 'mean', baseline_mean, 'std', baseline_std);

   frates = struct('waitCueIni', waitCueIni,...
                    'touchCueIni', touchCueIni,...
                    'manosFijasFin', manosFijasFin,...
                    'touchIni', touchIni,...
                    'movIni', movIni,...
                    'movFin', movFin,...
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
