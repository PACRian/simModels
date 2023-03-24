function TdName =  buildTdFuncs(blockName, funcName)
%% Add an existing tracking differentiator block(from Library) to 
%           a specified model and set the type of its non-linear function.
% 
% [Arguments]:
% + blockName: The model name to be modified that the specified TD module
% will be added.
% + funcName: The name of the non-linear function to be set in the Td module, 
% two forms can be used: One, use a PRESET function description (such as 'sigmoid') 
% to declare the function; 
% Two, by defining a CUSTOM function in advance in the executable path 
% (which requires the function to have a signal input 'x' and two 
% adjustable parameters 'a' and 'b', if there are less than two 
% adjustable parameters, the formal parameter will be replaced with a 
% placeholder `~` in the function program), 
% and passing the name of the function as a string.
% [Return]:
% + TdName:
% The path of the TD module in that Simulink model.
% [Example]:
% To add a sigmoid TD module(where the control function is sigmoid
% function) in a new model named 'testSigTd.slx', you can excute lines
% below: 
% >> new_system('testSigTd');
% >> buildTdFuncs('testSigTd', 'sigmoid'); 
% >> % Sigmoid function is pre-defined, check `getStoredFuncs` in this
%      function script for detailed declaration.
% >> save_system('testSigTd');
% 
% Then you can find a model named 'testSigTd.slx' in the working directory,
% and in that model, you will find a subsystem named
% 'sigmoid__TrackerDerivates', 
% open it, the function declaration is:
% >>><<<
% function y = fcn(x, a, b) 
% y = a ./ (1 + exp(-b*x))-.5*a;
% >>><<<
%% 
existingsubBlks = find_system(blockName, 'SearchDepth', 1, 'blockType', 'SubSystem');
hasTd = cellfun(@(x) endsWith(x, 'TrackerDerivates'), existingsubBlks);
if any(hasTd)
    % Acquire existing `VoidTrackerDerivates` block name.
    tdIdx = find(hasTd, 1);
    TdName = existingsubBlks{tdIdx};
    set_param(TdName, 'Position', [120, 50, 240, 120]);
else
    % Add a new `VoidTrackerDerivates` module to current system.
    % CAUTION: MUST DISABLE LINK(set 'CopyOption' to 'nolink')
    % so that each function block can be found later.
    add_block('VoidTrackerDerivates/VoidTrackerDerivates', ...
        [blockName, '/VoidTrackerDerivates'], ...
        'Name', [funcName, '_TrackerDerivates'], ...
        'CopyOption','nolink', ...
        'Position', [120, 50, 240, 120]);
    TdName = [blockName, '/', funcName, '_TrackerDerivates'];
%     TdName = [funcName, '_TrackerDerivates'];
end

% Acquire function scripts.
try
    funcScript = getfield(getStoredFuncs, funcName);
catch
    funcScript = evalc(['type ',funcName, '.m']);
end

%MAIN OPTION
% Modify the function script in the `VoidTrackerDerivates` block 
% so that it can work as we wished.
sf = sfroot();
fcn1 = sf.find('Path', [TdName, '/fcnBlock1'], '-isa', 'Stateflow.EMChart');
fcn1.Script = sprintf(funcScript);
fcn2 = sf.find('Path', [TdName, '/fcnBlock2'], '-isa', 'Stateflow.EMChart');
fcn2.Script = sprintf(funcScript);
end


function fd = getStoredFuncs
fd = struct( ...
    'tanh', 'function y = fcn(x, a, b) \ny = a*tanh(b*x);', ...
    'sigmoid', 'function y = fcn(x, a, b) \ny = a ./ (1 + exp(-b*x))-.5*a;', ...
    'atan', 'function y = fcn(x, a, b) \ny = a * atan(b*x);', ...
    'fsg', 'function y = fcn(x, a, b) \ny=sign(x-a)-sign(x-b);' ...
    );
end

