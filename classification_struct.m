frates = dir('C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns\*.png');
fratesdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\frates\frates_3aligns';
% idcell = {};
% category = [];
% include = [];
for f = 1:689%length(frates)
    disp([num2str(f),'/',num2str(length(frates))])
    id = frates(f).name(1:11) ;
    spk = frates(f).name(12:18);
    
%     img = imread([fratesdir, '\', id, spk, '.png']);
%     imshow(img)
%     
%     classif.wait.start(f) = input('Wait start = ');
%     
%     if  classif.wait.start(f) == 99;
%         classif.wait.start(f)          = 0;
%         idcell{f}                      = [id,spk];
%         classif.id                     = idcell;
%     else
%         classif.wait.delay(f)          = input('Wait delay = ');
% %         classif.wait.end(f)            = input('Wait end = ');
% 
% %         classif.contact.preReach(f)    = input('preReach = ');
%         classif.contact.reach(f)       = input('Reach = ');
%         classif.contact.touch(f)       = input('touch = ');
%         classif.contact.adaptation(f)  = input('adaptation = ');
%         classif.contact.delay(f)       = input('delay = ');
% 
%         classif.stimulus.left(f)       = input('left = ');
%         classif.stimulus.leftOnset(f)  = input('left onset = ');
%         classif.stimulus.leftOffset(f) = input('left offset = ');
%         classif.stimulus.right(f)      = input('right = ');
%         classif.stimulus.rightOnset(f) = input('right onset = ');
%         classif.stimulus.rightOffset(f)= input('right offset = ');
%         classif.stimulus.pref(f)       = input('rotation preference = ');
%         classif.stimulus.leftMem(f)    = input('left mem = ');
%         classif.stimulus.rightMem(f)   = input('right mem = ');
%         classif.stimulus.memPref(f)    = input('mem preference = ');
% 
%         classif.response.activity(f)   = input('resp activity = ');
%         classif.response.preference(f) = input('response preference = ');
%         
%         category(f)                    = input('category = ');
%         classif.category               = category;
%         
%         include(f)                     = input('include = ') ;
%         classif.include                = include;
        
        classif.id{f}                      = [id,spk];
%         classif.id                     = idcell;
        
%     end
%             save('C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\classification_struct', 'classif')

%     clf
%     clc
end