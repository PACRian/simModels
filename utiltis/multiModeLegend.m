function legendStr = multiModeLegend(paraNames, paraVals, paraIdx)
%% Generate legend string in the multiple "name-value" pairs
% [Arguments]:
% + paraNames: The namelist of each parameter, which should be a string or
% char cell object.
% + paraVals: The matrix that records parameter values, its shape should be
% p-by-n, where p is the number of the parameters in a fixed group and n is
% the batch number.
% [Return]:
% legendStr: A cell object that each item correspond to one group, in the
% form of "[<paraName>=<paraValue>], "
% 
% [Example]:
% >> % Suppose we want to set multiple working conditions in the fashion to
% $(staticForce, brakeForce)$ pair
% >> multiModeLegend({'staticForce', 'brakeForce'}, [3e5, 1e6; 4e5, 1.2e6]')
% ans =
% 
%   2×1 cell 数组
% 
%     {["staticForce=300000, brakeForce=1000000"]}
%     {["staticForce=400000, brakeForce=1200000"]}
% >> % And each element in that cell is a string.
% [Usecase description]:
% You can use that to auto-generate legend string and show it in the plot
% ares by `legend` function, below is a practice:
% ====================================
% forceNames = {'staticForce', 'brakeForce'};    
% forceVals = [3e5, 1e6; 4e5, 1.2e6]';
% 
% % ... Process & Plot
% legend(multiModeLegend(forceNames, forceVals))
% ====================================
%% 
arguments
    paraNames cell 
    paraVals {mustBeNumericOrLogical}
    paraIdx = {}
end
trials = size(paraVals, 2);
legendStr = cell(trials, 1);
if isempty(paraIdx)
    paraIdx = 1:length(paraNames);
end
for i=1:trials
    % Get each parameter group
    s = [];
    for j=paraIdx
        s = [s ...
    convertCharsToStrings(sprintf('%s=%s', paraNames{j}, num2str(paraVals(j, i))))];
    end
    legendStr{i} = join(s, ', ');
end
