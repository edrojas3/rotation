file = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification\rightPreference';

load(file)
left_detrend = cell(size(left));
left_err_detrend = cell(size(left_err));
right_detrend = cell(size(right));
right_err_detrend = cell(size(right_err));

for a = 1:6;
    for n = 1:size(left,1)
        lhit = left{n,a} ;
        rhit = right{n,a};

        hits = [lhit; rhit];
        hitsMean = nanmean(hits);
        hitsMean(isnan(hitsMean) == 1) = 0;

%         ldet = lhit - hitsMean;
%         rdet = rhit - hitsMean;
%         
%         subplot(1,2,1)
%         plot(lhit,'color',[0.5,0.5,0.5]); hold on
%         plot(hitsMean,'r')
%         plot(rhit,'--','color',[0.5,0.5,0.5])
%         
%         subplot(1,2,2)
%         plot(ldet,'k'); hold on
%         plot(rdet,'--k')
%         
%         pause
%         clf
       
       left_detrend{n,a} = left{n,a} - hitsMean;
       left_err_detrend{n,a} = left_err{n,a} - hitsMean;
       right_detrend{n,a} = right{n,a} - hitsMean;
       right_err_detrend{n,a} = right_err{n,a} - hitsMean;
       
    end
   
end

save(file, 'left','left_err', 'left_detrend','left_err_detrend','right','right_err','right_detrend', 'right_err_detrend')