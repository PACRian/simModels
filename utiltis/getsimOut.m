function y=getsimOut(simOut, signals)
if nargin<2
    signals = {};
end

y = getsimLogs(simOut, signals, 'yout');
end