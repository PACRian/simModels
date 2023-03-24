function blk = buildModules(buildFuncs, varargin)
blk = feval(buildFuncs, struct(varargin{:}));
end

function fromwkBlk = buildFromWk(cfg)
cfg = update_struct(struct('moduleName', findSimModel, 'InPortName', 'SigIn', ...
    'simInVariableName', '[ti,ui]', 'Position', [20, 80, 60, 100]), cfg);
try
    add_block('simulink/Sources/From Workspace', [cfg.moduleName, '/From Workspace'], ...
    'Name', cfg.InPortName, 'VariableName', cfg.simInVariableName, 'Position', cfg.Position);
    
catch ME
    if strcmp(ME.identifier, 'Simulink:blocks:DupBlockName')
        fromwkBlk = find_system(cfg.moduleName, 'Name', cfg.InPortName);
        set_param(fromwkBlk{1}, 'VariableName', cfg.simInVariableName, 'Position', cfg.Position);
    else
        rethrow(ME);
    end
end
fromwkBlk = cfg.InPortName;
end

function towkBlk = buildToWk(cfg)
cfg = update_struct(struct('moduleName', findSimModel, 'OutPortName', 'SigOut', ...
    'simOutVariableName', 'yout', 'Position', [320, 80, 360, 100]), cfg);
try
    add_block('simulink/Sinks/To Workspace', [cfg.moduleName, '/To Workspace'], ...
    'Name', cfg.OutPortName, 'VariableName', cfg.simOutVariableName, 'Position', cfg.Position);
catch ME
    if strcmp(ME.identifier, 'Simulink:blocks:DupBlockName')
        towkBlk = find_system(cfg.moduleName, 'Name', cfg.OutPortName);
        set_param(towkBlk{1}, 'VariableName', cfg.simOutVariableName,  'Position', cfg.Position);
    else
        rethrow(ME);
    end
end
towkBlk = cfg.OutPortName;
end

function towkBlk = buildToWkwithInputSig(cfg)
cfg = update_struct(struct('moduleName', findSimModel, 'OutPortName', 'USigOut', ...
    'simOutVariableName', 'uout', 'Position', [75, 120, 115, 140]), cfg);
towkBlk = buildToWk(cfg);
% add link line from the input signal to `towkBlk`

end

function sineBlk = buildSineGen(cfg)
cfg = update_struct(struct('moudleName', findSimModel, 'SigName', 'SineWave'), cfg);
try
    add_block('SineSigGen/SineSigGen', [cfg.moudleName, '/SineSigGen'], 'Name', cfg.SigName);
catch ME
    if strcmp(ME.identifier, 'Simulink:blocks:DupBlockName')
        sineBlk = find_system(cfg.moduleName, 'Name', cfg.SigName);
    else
        rethrow(ME);
    end
end
sineBlk = cfg.SigName;
end

function lineHandle = connectLine(cfg)
cfg = update_struct(struct('moudleName', findSimModel, ...
    'srcBlockName', '', 'destBlockName', '', 'OutPortNum', '1', 'InPortNum', '1', ...
    'LineName', '', 'alreadyLogged', false), cfg);

try
    lineHandle = add_line(cfg.moudleName, [cfg.srcBlockName, '/', cfg.OutPortNum], ...
        [cfg.destBlockName, '/', cfg.InPortNum]);
catch ME
    if ~strcmp(ME.identifier, 'Simulink:Commands:AddLineDestAlreadyConnected')
        rethrow(ME);
    end
    lineHandle = {};
end
if cfg.alreadyLogged
    return
end

if isempty(lineHandle)
    sHandle = get_param([cfg.moudleName, '/', cfg.srcBlockName], 'PortHandles');
    lineHandle = get_param(sHandle.Outport(str2num(cfg.OutPortNum)), 'Line');
end
set_param(lineHandle, 'Name', cfg.LineName);
Simulink.sdi.markSignalForStreaming(lineHandle, 'on')

end



