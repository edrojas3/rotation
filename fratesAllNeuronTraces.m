clear all; clc


preference = -1;

matdir = 'C:\Users\eduardo\Documents\proyectos\rotacion\matfiles\classification';

if preference == -1;
    pref = 'right';
elseif preference == 1;
    pref = 'left';
end
load([matdir, '\',pref,'Preference'])

left = left_detrend;
left_err = left_err_detrend;
right = right_detrend;
right_err = right_err_detrend;

close all
figure
hold on

samples = -0.3:0.001:1;

glevel = linspace(0.2,0.9,6);
b = [zeros(6,1), glevel', ones(6,1)];
r = [ones(6,1), glevel', zeros(6,1)];
g = [zeros(6,1), glevel', zeros(6,1)];

indexmat = reshape(1:24,6,4)';

for im = 1:size(indexmat,2)
    subplot(4,6,indexmat(1,im))
    plot(samples, cell2mat(left(:,im))', 'color', g(im,:)); hold on
    plot(samples, nanmean(cell2mat(left(:,im))), 'color', 'b', 'linewidth',2)
    set(gca,'xlim', [-0.3,1])

    subplot(4,6,indexmat(2,im))
    plot(samples, cell2mat(left_err(:,im))', 'color', r(im,:)); hold on
    plot(samples, nanmean(cell2mat(left_err(:,im))), 'color', 'b', 'linewidth',2)
    set(gca,'xlim', [-0.3,1])
    
    subplot(4,6,indexmat(3,im))
    plot(samples, cell2mat(right(:,im))', 'color', g(im,:)); hold on
    plot(samples, nanmean(cell2mat(right(:,im))), 'color', 'b', 'linewidth',2)
    set(gca,'xlim', [-0.3,1])

    subplot(4,6,indexmat(4,im))
    plot(samples, cell2mat(right_err(:,im))', 'color', r(im,:)); hold on
    plot(samples, nanmean(cell2mat(right_err(:,im))), 'color', 'b', 'linewidth',2)
    set(gca,'xlim', [-0.3,1])

end

