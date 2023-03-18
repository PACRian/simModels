% Generate `xList`(System input) ------------------ Step One
sampleTime = 1e-2;          % Sample lasting period
stopTime = 10;              % The stop timestamp
xRange = [-15, 15];         % To form a linear-growth list 
                            % which the limit is determined by `xRange`

xList = linspace(xRange(1), xRange(2), stopTime/sampleTime+1);
xList = timeseries(xList, 0:sampleTime:stopTime);

% Config parameters -------------------------------- Step Two
sigBlockNames = '/Sigmoid';
sigParas = {'a', 'b'}; 
factors = [1, 1; 2, 1; 2, .5]';
expBatchNum = size(factors, 2);

sims = multiModelSim('sigmoidFunc', sigBlockNames, sigParas, factors, ...
    {'StopTime', num2str(stopTime), 'FixedStep','0.05'}, false, 2);
simResults = getsimLogs(sims);

figure; hold on; grid on
for i=1:expBatchNum
    plot_xytimeseries(simResults(i).xval, simResults(i).sigfunc);
end
colororder({'#F80','#50F','#0B0'});
hold off
xlabel('x'); ylabel('sig(x; a, b)');
legend(multiModeLegend(sigParas, factors));

formatFig(mfilename);
