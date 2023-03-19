function TdName =  buildTdFuncs(blockName, funcName)

existingsubBlks = find_system(blockName, 'SearchDepth', 1, 'blockType', 'SubSystem');
hasTd = cellfun(@(x) endsWith(x, 'TrackerDerivates'), existingsubBlks);
if any(hasTd)
    % Acquire existing `VoidTrackerDerivates` block name.
    tdIdx = find(hasTd, 1);
    TdName = existingsubBlks{tdIdx};
else
    % Add a new `VoidTrackerDerivates` module to current system.
    % CAUTION: MUST DISABLE LINK(set 'CopyOption' to 'nolink')
    % so that each function block can be found later.
    add_block('VoidTrackerDerivates/VoidTrackerDerivates', ...
        [blockName, '/VoidTrackerDerivates'], ...
        'Name', [funcName, '_TrackerDerivates'], ...
        'CopyOption','nolink');
    TdName = [blockName, '/', funcName, '_TrackerDerivates'];
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
    'atan', 'function y = fcn(x, a, b) \ny = a * atan(b*x);'...
    );
end

