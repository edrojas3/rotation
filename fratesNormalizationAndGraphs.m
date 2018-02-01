clearvars -except singleTrials preference
% close all
clc

A = [0.1,0.2,0.4,0.8,1.6,3.2];
% A = [0.1,0.2,0.4];
% A = [0.8,1.6,3.2];
% A = 0.1;
lenA = length(A);

p = [1,-1];
close all
for pp = 1:2
    pindex = find(preference == p(pp));
%     if pp == 1;
%         pindex = find(preference > 0);
%     else
%         pindex = find(preference < 0);
%     end
    timeSec = -0.5:0.001:1;
    timeSec = -0.5:0.01:1;
    normIndex = find(timeSec <= 0);

    lFRN = {};
    rFRN = {};
    lFRNE = {};
    rFRNE = {};

    for ii =1:length(pindex)
        hits = singleTrials(pindex(ii)).hits;
        fr = singleTrials(pindex(ii)).frates(hits==1,:);
        rotations = singleTrials(pindex(ii)).rotations(hits==1);

        frE = singleTrials(pindex(ii)).frates(hits==0,:);
        rotationsE = singleTrials(pindex(ii)).rotations(hits==0);

        for ang = 1:lenA
            % Hits Normalization
            lrot = ismember(rotations,A(ang));
            rrot = ismember(rotations,-A(ang));
            lfr = fr(lrot,:);
            rfr = fr(rrot,:);

            if ~(isempty(lfr))
                if size(lfr,1) == 1;
                    lmean = lfr;
                else
                    lmean = nanmean(lfr);
                end
                lnorm = (lmean - mean(lmean(normIndex))) / std(lmean(normIndex));
                lFRN{ii,ang} = lnorm;
            end

            if ~(isempty(rfr));
                if size(rfr,1) == 1;
                    rmean = rfr;
                else                
                    rmean = nanmean(rfr);
                end
                rnorm = (rmean - mean(rmean(normIndex))) / std(rmean(normIndex));
                rFRN{ii,ang} = rnorm;
            end

            % Error Normalization
            lrot = ismember(rotationsE,A(ang));
            rrot = ismember(rotationsE,-A(ang));
            lfr = frE(lrot,:);
            rfr = frE(rrot,:);
            if ~(isempty(lfr))
                if size(lfr,1) == 1;
                    lmean = lfr;
                else
                    lmean = nanmean(lfr);
                end
                lnorm = (lmean - mean(lmean(normIndex))) / std(lmean(normIndex));
                lFRNE{ii,ang} = lnorm;
            end
            if ~(isempty(rfr));
                if size(rfr,1) == 1;
                    rmean = rfr;
                else                
                    rmean = nanmean(rfr);
                end
                rnorm = (rmean - mean(rmean(normIndex))) / std(rmean(normIndex));
                rFRNE{ii,ang} = rnorm;
            end

        end

    end

    %
    % close all
    % figure
    glevel = linspace(0.2,0.9,lenA);
    b = [zeros(lenA,1), glevel', ones(lenA,1)];
    r = [ones(lenA,1), glevel', zeros(lenA,1)];
    g = [zeros(lenA,1), glevel', zeros(lenA,1)];

    for ang = 1:length(A)
        % Hits matrices
        lmat = cell2mat(lFRN(:,ang));
        fratemax = max(lmat,[],2);
        lmat(fratemax > 50,:) = [];
        lmean = nanmean(lmat);
        rmean = nanmean(cell2mat(rFRN(:,ang)));

        % Error matrices
        lmatE = cell2mat(lFRNE(:,ang));
        lmatE(lmatE==inf) = nan;
%         if A(ang) == 0.4; lmatE(7,:)=[]; end
        lmeanE = nanmean(lmatE);
        rmeanE = nanmean(cell2mat(rFRNE(:,ang)));

        if p(pp) == 1; subplot(1,2,1); title('Left Preference Neurons');
        else subplot(1,2,2); title('Right Preference Neurons');end
        plot(timeSec,mean(lmat),'color',b(ang,:),'linewidth',2); hold on
    %     plot(timeSec,lmeanE,'--','color',g(ang,:))
        
        set(gca,'xlim',[-0.3,1],'ylim',[-4,12],'box','off')

    %     subplot(1,2,2)
        plot(timeSec,rmean,'color',r(ang,:),'linewidth',2); hold on
    %     plot(timeSec,rmeanE,'--','color',g(ang,:))
    %     title('Right Rotations')
        set(gca,'xlim',[-0.3,1],'box','off')
        xlabel('Time from stimulus onset (s)')
        ylabel('Normalized firing rate')
    end
end
legend(num2str(A(1)),num2str(A(2)))
%%
figure
glevel = linspace(0,1,lenA);
b = [zeros(lenA,1), glevel', ones(lenA,1)];
r = [ones(lenA,1), glevel', zeros(lenA,1)];
g = [zeros(lenA,1), glevel', zeros(lenA,1)];

for ang = 1:length(A)
    % Hits matrices
    lmat = cell2mat(lFRN(:,ang));
    if A(ang) == 3.2; lmat(10,:)=[]; end
    if A(ang) == 0.1; lmat(14,:) = []; end
    lmean = nanmean(lmat);
    rmean = nanmean(cell2mat(rFRN(:,ang)));
    
    % Error matrices
    lmatE = cell2mat(lFRNE(:,ang));
    lmatE(lmatE==inf) = nan;
    if A(ang) == 0.4; lmatE(7,:)=[]; end
    lmeanE = nanmean(lmatE);
    rmeanE = nanmean(cell2mat(rFRNE(:,ang)));
    
   
    plot(timeSec,lmat','color',[0.8,0.8,1]); hold on
    plot(timeSec,lmatE','color',[1,0.8,0.8]); 
    plot(timeSec,mean(lmat),'b','linewidth',2)
    plot(timeSec,lmeanE,'r','linewidth',2)
    title('0.1 Hits vs Errors')
    set(gca,'xlim',[-0.3,1],'box','off')
    
%     subplot(1,2,2)
%     plot(timeSec,rmean,'color',g(ang,:)); hold on
%     plot(timeSec,rmeanE,'color',r(ang,:))
%     title('Right Rotations')
%     set(gca,'xlim',[-0.3,1],'box','off')
%     pause
end

