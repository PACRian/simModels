% Generate `xList`(System input) ------------------ Step One
sampleTime = 1e-2;          % Sample lasting period
stopTime = 10;              % The stop timestamp
xRange = [-15, 15];         % To form a linear-growth list 
                            % which the limit is determined by `xRange`

xList = linspace(xRange(1), xRange(2), stopTime/sampleTime+1);
xList = timeseries(xList, 0:sampleTime:stopTime);

% Config parameters -------------------------------- Step Two
cauBlockNames = {'/CauchyCdf', '/CauchyPdf'};
cauParas = {'a', 'b', '', 'g'}; 
cauVals = [300, 15, 1; 500, 25, .5; 700, 100, .2]'; 
expBatchNum = size(cauVals, 2);

% cauCdfParas = {'a', 'b'};    % Gain factor & Bias factor
% cauCdfVals = [300, 15; 500, 20; 700, 100]';
% 
% sims = multiModelSim({}, '/CauchyCdf', cauCdfParas, cauCdfVals);
sims = multiModelSim('cauchyFuncs', cauBlockNames, cauParas, cauVals, ...
    {'StopTime', num2str(stopTime), 'FixedStep','0.05'});
% plot(sims{1}.logsout.get('xval'))
% plot(sims{2}.logsout.get('xval'))
% plot(sims{3}.logsout.get('xval'))
simSigs = getsimLogs(sims);

% Draw x-y map then plot in a same figure
figure;
subplot(211);
hold on
for i=1:expBatchNum
    plot_xytimeseries(simSigs(i).xval, simSigs(i).cauchyCfs);
end
colororder({'#00F','#50F','#A0F'});
hold off

subplot(212);
hold on
for i=1:expBatchNum
    plot_xytimeseries(simSigs(i).xval, simSigs(i).cauchyPfs);
end
hold off

% for i=1:length(cauCdfVals)
%     p = plot_xytimeseries(simSigs(i).xval, simSigs(i).cauchyCfs);
%     hold on
% end
% hold off
% legend(multiModeLegend(cauCdfParas, cauCdfVals))