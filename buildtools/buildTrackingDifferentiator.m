function varargout = buildTrackingDifferentiator(varargin)
% A default configuration, a sigmoid TD module will be build up 
% if nothing changed.
DEFAULT_CONFIGS = struct( ...
    'stylish', '', ...                % Stylish can be `sweep` or `input`[TODO]
    ... 
    'sysPrefix', '', ...
    'sysName', 'TrackingDifferentiator', ...
    'funcName', 'sigmoid', ...
    ...
    'wksSigName', 'SigIn', ...
    'wksLineName', 'x', ...
    'wksVariableName', '[ti,ui]', ...
    ...
    'doLogFromWkSignal', true, ...    % If you want to use a sweep signal test, 
    ...                               % check `doLogFromWkSignal` as true
    'logSigName', 'SigOut', ...
    'simLogVariableName', 'xout', ...
    ...
    'trackSigName', 'TrackSig', ...
    'trackLineName', 'x1', ...
    'simTrackVariableName', 'yout', ...
    ...
    'diffSigName', 'DiffSig', ...
    'diffLineName', 'x2', ...
    'simDiffVariableName', 'vout', ...
    ...
    'assignInputSig', false, ...
    'timeList', [], ...
    'dataList', [], ...
    'sigFunc', [], ...
    ...                              % Return type: 
    ...                              % 'all', all Modules in that Simulink model
    ...                              % 'td', only the module name of the Td module
    ...                              % 'towk', only the block 'to Workspace'
    ...                              
    'returnType', 'all', ...
    'killOld', true);
cfg = update_struct(DEFAULT_CONFIGS, struct(varargin{:}));
% Kill previous duplicated system if possible
if cfg.killOld
    try
        close_system(cfg.sysName);
        delete([cfg.sysName, '.slx']);
    catch
    end
end

% Check whether the system exists
% If not, then build it.
cfg.sysName = [cfg.sysPrefix, cfg.sysName];
checkSimulinkSys(cfg.sysName);
% Build basic modules(Td Module & One fromWks & Two toWks)
% close_system(cfg.sysName);
% load_system(cfg.sysName);
try % DOUBLE BUILD TD BLOCK
    TdModule = buildTdFuncs(cfg.sysName, cfg.funcName);
catch
    TdModule = buildTdFuncs(cfg.sysName, cfg.funcName);
end
FromWkModule = buildModules('buildFromWk', 'moduleName', cfg.sysName, ...
    'InPortName', cfg.wksSigName, 'simInVariableName', cfg.wksVariableName);
ToWkSignaltraModule = buildModules('buildToWk', 'moduleName', cfg.sysName, ...
   'OutPortName', cfg.trackSigName, 'simOutVariableName', cfg.simTrackVariableName);
ToWkDifftraModule = buildModules('buildToWk', 'moduleName', cfg.sysName, ...
   'OutPortName', cfg.diffSigName, ...
   'simOutVariableName', cfg.simDiffVariableName, 'Position', [320, 120, 360, 140]);
% save_system(cfg.sysName);

% Add lines
TdModule = withBlock(TdModule, 'strip');
buildModules('connectLine', 'moudleName', cfg.sysName, 'srcBlockName', FromWkModule, ...
    'destBlockName', TdModule, 'LineName', cfg.wksLineName);
buildModules('connectLine', 'moudleName', cfg.sysName, 'srcBlockName', TdModule, ...
    'destBlockName', ToWkSignaltraModule, 'LineName', cfg.trackLineName);
buildModules('connectLine', 'moudleName', cfg.sysName, 'srcBlockName', TdModule, ...
    'destBlockName', ToWkDifftraModule, ...
    'LineName', cfg.diffLineName, 'OutPortNum', '2');

% If possible, add a `ToWkSignalsigModule` to record the input signal
% If you are not using a frenquency sweep analyzer, it is suggested that to
% close this option(by setting 'doLogFromWkSignal' as false)
% that you can directly get the input signal from the workspace that you
% created by your own.
if cfg.doLogFromWkSignal
    ToWkSignalsigModule = buildModules('buildToWkwithInputSig', ...
        'moduleName', cfg.sysName, 'OutPortName', cfg.logSigName, ...
        'simOutVariableName', cfg.simLogVariableName);
    buildModules('connectLine', 'moudleName', cfg.sysName, 'srcBlockName', FromWkModule, ...
        'destBlockName', ToWkSignalsigModule, 'alreadyLogged', true);
end

% Additional work: create a timeseries object and then assign it to the
% workspace as the input signal for the model.
if cfg.assignInputSig
    timeList = cfg.timeList;
    assert(~isempty(timeList), 'TimeList must not be empty');
    
    if ~isempty(cfg.dataList) && length(cfg.dataList) == length(timeList)
        ts = timeseries(cfg.dataList, timeList, 'Name', cfg.wksVariableName);
    else
        assert(~isempty(cfg.sigFunc), '`SigFunc` must not be empty');
        ts = timeseries(cfg.sigFunc(timeList), timeList, 'Name', cfg.wksVariableName);
    end
    assignin('base', cfg.wksVariableName, ts);
end

save_system(cfg.sysName);
switch cfg.returnType
    case 'all'
        varargout = {TdModule, FromWkModule, ToWkSignaltraModule, ToWkDifftraModule};
    case 'td'
        varargout = {TdModule};
    case 'towk'
        varargout = {ToWkSignaltraModule, ToWkDifftraModule};
end

if cfg.doLogFromWkSignal && ~isequal(cfg.returnType, 'td')
    varargout{end+1} = ToWkSignalsigModule;
end
end


function checkSimulinkSys(sysName)
try
    load_system(sysName);
catch ME
    if strcmp(ME.identifier, 'Simulink:Commands:OpenSystemUnknownSystem')
        new_system(sysName);
        save_system(sysName);
    else
        rethrow(ME);
    end
end
end