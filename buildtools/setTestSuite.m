function setTestSuite(setFunc, varargin)
feval(setFunc, struct(varargin{:}));
end

% Use this function to test the frenquency response characteristic.
function setSweepSuite(cfg)
% Basically three options to be modified on a generic model
% 1. Set `configTowksModule` to `true` in order to modify the "To
% Workspace" block, as the following two measures:
% + Set the 'SaveFormat' as `array` so the the frenquency analyzer can use
%   these outputs normally
% + Set the 'Sample time' as `cint' so that it can we can simply access and
%   modify the simulation sample time from outer script.
% 2. Set `configFromwksModule` to `true` in order to modify the "From
% Workspace" block, just to change the data name as `[ti,ui]`
% 3. Set `genSweepConfigs` to `true` so that appropriate variables can be set
% in the workspace, here is some options:
% + `cint`: Sample time;
% + `duration`: Max simulation duration;
% + `freLogIndex`: The frequency span of the sweep includes from 1Hz to
% 10^(`freLogIndex`) Hz;
% + `fracFreNums`: The number of fractional frequency, if it is set to 0,
% no fractional frenquency will be list.
% + `freNum`: The number of sampling frequencies, if `isSection` is set to
% be `true`, the total sampling number is around freNum*(freLogIndex-1)
% + `doRound`: If true, integer frequency is only permitted;
% + `simulationTime`: Middle simulation time at frenquency point -- 1Hz;
cfg = update_struct(struct('moduleName', findSimModel, ...
    'configTowksModule', true, 'ToWksModules', '', ...
    'configFromwksModule', true, 'FromWksModules', '', ...
    'genSweepConfigs', true, ...
    'cint', .001, 'duration', 100, ...
    'freLogIndex', 2, 'fracFreNums', 3, ...
    'freNum', 8, 'isSection', true, ...
    'doRound', true, ...
    'ncycleThrottles', [5, 10, 20, 30, 50, 70, 100], ...
    'simulationTime', 10, 'decayRatio', 10, ...
    'ncycleRoundMethod', 'round'), cfg);

load_system(cfg.moduleName);
if cfg.configTowksModule
    if isempty(cfg.ToWksModules)
        cfg.ToWksModules = find_system(cfg.moduleName, 'BlockType', 'ToWorkspace');
        disp(cfg.ToWksModules)
    end
    
    for i=1:length(cfg.ToWksModules)
        wksm = cfg.ToWksModules{i};
        set_param(wksm, 'SaveFormat', 'array');
        set_param(wksm, 'SampleTime', 'cint');
    end
end

if cfg.configFromwksModule
    if isempty(cfg.FromWksModules)
        cfg.FromWksModules = find_system(cfg.moduleName, 'BlockType', 'FromWorkspace');
    end
    for wks=cfg.FromWksModules
        set_param(wks{:}, 'VariableName', '[ti,ui]')
    end
end

if cfg.genSweepConfigs
    assignin('base', 'cint', cfg.cint);
    assignin('base', 'ti', [0;cfg.duration]);
    assignin('base', 'ui', [0;0]);
    freLogIndex = max(min(round(cfg.freLogIndex), 5), 1);
    
    % 生成要测试的频段范围`fra_fvec`
    % isSection -- 
    if cfg.isSection
        fre_fvec = [];
        for i=0:freLogIndex-1
            fre_fvec = [fre_fvec logspace(i, i+1, cfg.freNum)];
        end
        fre_fvec = unique(fre_fvec);
    else
        fre_fvec = logspace(0, freLogIndex, cfg.freNum);
    end
    
    if cfg.doRound 
        fre_fvec = round(fre_fvec);
        fre_fvec = unique(fre_fvec);
    end
%     simulationTime = linspace(cfg.simulationTime, cfg.simulationTime/cfg.decayRatio, length(fre_fvec));
    if cfg.fracFreNums>0
        fra_fres = logspace(-1, 0, cfg.fracFreNums);
        fre_fvec = [fra_fres(1:end-1) fre_fvec];
%         
%         fraSimulationTime = linspace(cfg.duration, cfg.simulationTime, length(fra_fres)-1);
%         simulationTime = [fraSimulationTime simulationTime];
    end
    
%     freThrottles = round(log10(fre_fvec));
    fre_ncyc = arrayfun(@(x) cfg.ncycleThrottles(x+2), round(log10(fre_fvec)));

%     fre_ncyc = simulationTime.*fre_fvec;
%     switch cfg.ncycleRoundMethod
%         case 'round'
%             fre_ncyc = round(fre_ncyc);
%         case 'ceil'
%             fre_ncyc = ceil(fre_ncyc);
%         case 'floor'
%             fre_ncyc = floor(fre_ncyc);
%     end
    assignin('base', 'fra_fvec', fre_fvec);
    assignin('base', 'fra_ncyc', fre_ncyc);
end
    
end

function setPulseGenerator
end

function setTriangleSweepSuite(cfg)
cfg = update_struct(struct('moduleName', findSimModel, ...
    'sigName', 'x', ...
    'beginTime', 1, 'period', 2, 'dutyCycle', .5, ...
    'riseSlope', 1, 'downSlope', 1, ...
    'duration', 10, 'cint', .001), cfg);
% Generate time series
t = 0:cfg.cint:cfg.duration;
rectWave = zeros(size(t));

i = cfg.beginTime/cfg.cint+2;
tLength = length(t);
while true
    riseTick = i;
    downTick = min(i+cfg.dutyCycle*cfg.period/cfg.cint, tLength);
    nextRiseTick = min(i+cfg.period/cfg.cint, tLength);
    rectWave(riseTick:downTick-1) = cfg.riseSlope;
    rectWave(downTick:nextRiseTick) = -cfg.downSlope;
    
    i = nextRiseTick;
    if i>=tLength
        break
    end
end

triWave = cumsum(rectWave*cint);
assignin('base', cfg.sigName, triWave);

if isempty(cfg.FromWksModules)
    cfg.FromWksModules = find_system(cfg.moduleName, 'BlockType', 'FromWorkspace');
end
for wks=cfg.FromWksModules
    set_param(wks{:}, 'VariableName', cfg.sigName);
end
end

% function setSineWaveSuite(cfg)
% cfg = update_struct(struct(), cfg);
% 
% if cfg.
% end
% end