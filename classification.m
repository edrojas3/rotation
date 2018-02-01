load C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\classification
frates = dir('C:\Users\eduardo\Documents\proyectos\rotacion\frates\*.png');
fratesdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\frates';
% classif = cell(1,12);


for f = 946:length(frates)
    load C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\bestrecs\classification
    
    classif
    disp([num2str(f),'/',num2str(length(frates))])
    
    frate = imread([fratesdir, '\', frates(f).name]);
    imshow(frate)
    
    id = frates(f).name(1:11);
    spk = frates(f).name(12:18);
    
    classif{f, 1} = id;
    classif{f,2} = spk;

    baseline = input('Baseline: ');
    if isempty(baseline);
       cue      = [0,0] ;
       reach    = [0,0, 0] ;
       touch    = [0,0] ;
       stim     = [0,0] ;
       delay    = [0,0] ;
       back     = [0,0,0] ;
       resp     = [0,0] ;
       stimpref = 0;
       resppref = 0;

    else

        cue     = input('Cue: ');
        reach   = input('Reach: ');
        touch   = input('Touch: ');
        stim    = input('Stim: ');
        delay   = input('Delay: ');
        back    = input('Back: ');
        resp    = input('Resp: ');
        stimpref = input('stimpref: ');
        resppref = input('resppref: ');
    end

    classif{f,3}  = baseline;
    classif{f,4}  = cue;
    classif{f,5}  = reach;
    classif{f,6}  = touch;
    classif{f,7}  = stim;
    classif{f,8}  = delay;
    classif{f,9}  = back;
    classif{f,10} = resp;
    classif{f,11} = stimpref;
    classif{f,12} = resppref;

    save('classification', 'classif')
    clf
    
end


