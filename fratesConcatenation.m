clearvars -except singleTrials preference
close all

A = [0.1,0.2,0.4];
lenA = length(A);
samples = -.5:.01:1;
sampindex = samples >= .4 & samples <= .6;
normindex = samples <= 0;
p = [1,-1];
subindex = [1,3;2,4];
for pp = 1:length(p)
    pindex = find(preference == p(pp));

    glevel = linspace(0.2,0.9,lenA);
    b = [zeros(lenA,1), glevel', ones(lenA,1)];
    r = [ones(lenA,1), glevel', zeros(lenA,1)];
    g = [zeros(lenA,1), glevel', zeros(lenA,1)];
    
%     subplot(1,2,pp)
%     for ang = 1:lenA
        ang = lenA;
        a = A(1:ang);
        lfrH = [];
        lfrE = [];
        rfrH = [];
        rfrE = [];
        rocL = [];
        rocR = [];
        rocDiff = [];
        for n = 1: length(pindex);
            
            % Normalization of detrended frates
            frD = singleTrials(pindex(n)).fratesDetrend;
            frN = nan(size(frD));
            for f = 1:size(frD,1)
                lbmean = mean(frD(f,normindex));
                lbstd = std(frD(f,normindex));
                frN(f,:) = (frD(f,:) - lbmean) / lbstd ;
            end
            
            % ROC left vs right rotations
            hits = singleTrials(pindex(n)).hits;
            fr = frN(hits==1,:);
            rotations = singleTrials(pindex(n)).rotations(hits==1);
            lrotH = ismember(rotations,a);
            rrotH = ismember(rotations,-a);
            lH = fr(lrotH,:);
            rH = fr(rrotH,:);
            lfrH = [lfrH; lH];
            rfrH = [rfrH; rH];
            
            % ROC left hits vs left errors
            frE = frN(hits==0,:);
            rotationsE = singleTrials(pindex(n)).rotations(hits==0);
            lrotE = ismember(rotationsE,a);
            rrotE = ismember(rotationsE,-a);
            lE = frE(lrotE,:);
            rE = frE(rrotE,:);
            lfrE = [lfrE; lE];
            rfrE = [rfrE; rE];
            
            % ROC right hits vs right erros
            rl = rocindex(lH,lE);
            rocL = [rocL;rl];
            rr = rocindex(rH,rE);
            rocR = [rocR;rr];
            
            % Difference of peak values
            rd = median(rr(sampindex) - rl(sampindex));
            rocDiff = [rocDiff,rd];
        end
       subplot(2,2,subindex(pp,1)) 
       plot(samples,rocL','color',[0.6,0.6,1]); hold on
       plot(samples,rocR','color',[1,0.6,0.6]); hold on
       plot(samples,mean(rocL),'b','linewidth',2)
       plot(samples,mean(rocR),'r','linewidth',2)
       xlabel('Time from stimulus onset')
       ylabel('roc index')
       if p(pp) == 1
           title('Left Preference Neurons');
       else
           title('Right Preference Neurons');
       end
           
       subplot(2,2,(subindex(pp,2)))
       hist(rocDiff)
       xlabel('Difference (red - blue)') 
       ylabel('Number of samples')
%         lroc = rocindex(lfr, lfrE);
%         rroc = rocindex(rfr,rfrE);
%         timeSec = -0.5:0.01:1;
%         plot(timeSec,lroc,'color',b(ang,:))
%         hold on
%         plot(timeSec,rroc,'color',r(ang,:))
%         set(gca,'ylim',[0,1])
%     end
end