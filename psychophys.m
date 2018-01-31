function [stimuli, p] = psychophys(e,xdata)
% Plots the probability of answering left as a function of stimulus
% magnitude.
%
% USAGE: [stimuli, p] = psychophys(e,xdata)
%
% Inputs:
% e: structure with the information of the session
% xdata: independent values that you would like to have in the x axis (rotationAngle or initialAngle)
%
% Outputs: if no outputs are given the function will plot the psychophysic
% curve.
% stimuli: vector with the stimuli found in the structure array.
% p: vector with the probability of 'left' choices as a function of
% stimulus magnitude.


trials = e.trial;
xdata = [trials.(xdata)];
choice = [trials.choice];
stimuli = unique(xdata');

p = zeros(length(stimuli),1);

for a = 1:length(stimuli)
    c = choice(xdata== stimuli(a));
    leftchoice = sum(c == 1);
    n = length(c);
    p(a) = leftchoice/n;
end

if nargout == 0;
    plot(stimuli,p, '-ob', 'markerfacecolor','b', 'markersize',2)
end