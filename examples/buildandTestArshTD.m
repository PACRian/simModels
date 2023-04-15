% CAUTION: OPEN simulink context first.
arshTdName = 'arshTd';
r=buildTrackingDifferentiator('sysName', arshTdName, 'funcName', 'arsh');

fprintf('Tracking Differentiator built.(%s)\n', r);

setTestSuite('setSweepSuite', 'moduleName', arshTdName);





