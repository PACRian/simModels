clear; 
% CAUTION: OPEN simulink context first.
% BUILD TD MODEL
arshTdName = 'arshTd';
r = buildTrackingDifferentiator('sysName', arshTdName, 'funcName', 'arsh', 'doLogFromWkSignal', true);

fprintf('Tracking Differentiator built.(%s)\n', r);

% SET SINE-WAVE TEST ENVIROMENT
setTestSuite('setSineSuite', 'moduleName', arshTdName);

fprintf('Tracking Differentiator set to sine-wave testsuite\n');

% DO SIMULATION
fList = [1 2];
sims = multiModelSim('arshTd', '/sineIn', {'Frequency'}, 2*pi*fList);
sims = getsimLogs(sims);

% TIMING PLOT
tiledlayout(3, 3)

N = length(sims);
nexttile(2, [1, 2]);
for i=1:N
    plot(sims(i).x2); 
    hold on
end
hold off; xlim([0, 1]); xlabel('Time - s'); ylabel('x1'); title('')
camroll(-90)

nexttile(5, [2, 2]);
for i=1:N
    plot_xytimeseries(sims(i).x1, sims(i).x2);
    hold on
end
hold off; xlabel('x1'); ylabel('x2');
legend(arrayfun(@(x) sprintf('f=%d Hz', x), [1, 2], 'UniformOutput', false))

nexttile(4, [2, 1])
for i=1:N
    plot(sims(i).x2); 
    hold on
end
hold off; xlim([0, 1]); xlabel('Time - s'); ylabel('x2'); title('')


