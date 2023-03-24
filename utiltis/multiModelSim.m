function simResults = multiModelSim(modelName, subSysName, ...
                        paraNames, paraVals, simConfigs, noTrace, verbose)
%%  Run SimulinkR Model with multiple parameter groups 
% [Arguments]: 
% + ModelName: The name of the Simulink model to be loaded and ran. Be
% caution that `ModelName` should not contain `.slx` or `.mdl` extension.
% Note: If you have not set `ModelName`, program will automatically search
% the current working directory to check if there exists a Simulink model
% file, and the first one searched will be used.
% + subSysName: The block that parameters with the desired parameter set,
% if no subsystem exists, please set this argument to a void char ''.
% Mutiple levels of nesting is permitted and blankslash is needed. For
% example, suppose in a model, there exists a subsystem called 'S1', and a
% deeper subsystem inside 'S1' called 'S2', and a constant block in 'S2' named
% 'C1', we can access that constant block via a nesting structure that the
% path is '/S1/S2/C1'.
% + paraNames: The name of each parameter, which should be consistent with 
% the naming of model parameters.
% **Ambiguity Notes**: 
% function argument `subSysName` also can be a `paraStru` object, which 
% should contain two fields at least: `subSysName` and `paraName`. 
% At that case, if you treat `subSysName` as a `paraStru` object, you 
% should set `paraNames` to a void cell(`{}`).
% In another case, You can set both `subSysName` and `paraNames` as a cell
% object like normal, and use '' as a delimiter in parameter_name groups.
% 
% + paraVals: The matrix that records parameter values, its shape should be
% p-by-n, where p is the number of the parameters in a fixed group and n is
% the batch number.
% + simConfigs: The configs passed to simulation process, in the form of `cell`
% in a "name-value" fashion, detailed configs can check 
% https://www.mathworks.com/help/simulink/slref/sim.html#bvfe92n-ConfigSet
% + noTrace: A boolean variable determining whether it should be kept.
% + verbose: 0(Default) - No intermediate process display; 1 - A brief log; 2 - A
% throughout record. 
% **Ambiguity Notes**: 
% verbose can also be an indicator to manipulate the estabilish of the
% whole model, if `verbose` is set to `3`, then the model build up with the
% "top" parameter group and no simulation will be carried out.
% [Return]: 
% + SimResults: A cell object that stores each simulation results(instance
% class is 'Simulink.SimulationOutput')
% [Example]: 
% >> % Set cauchy Function parameters
% >> % 'a', 'b' can be modified here as a scale and initialzation factor.
% >> cauCdfParas = {'a', 'b'}; cauCdfVals = [300, 15; 500, 20; 700, 100]';
% >> 
% >> sims = multiModelSim('cauchyFuncs', '/CauchyCdf', ...
%     cauCdfParas, cauCdfVals, {"StopTime", "10"});
% >> sims
% 
% sims =
% 
%   3×1 cell object
% 
%     {1×1 Simulink.SimulationOutput}
%     {1×1 Simulink.SimulationOutput}
%     {1×1 Simulink.SimulationOutput}
% [Usecase description]: 
% Commonlly we use get `getsimLogs` or `getsimOut` function to process the
% simulation output, to extract the desired data from a compact form. Below
% is a simple but typical use case, it contains three phase:
% 1. Define the parameters and test group(In this case, they are
% `cauCdfParas` and `cauCdfVals`)
% 2. Run the simulation through prescribed rounds using `multiModelSim`
% 3. Extract valuable timeseries and post-process, evaluation, etc.
% ====================================
% % Pre-defining[Phase1]
% cauCdfParas = {'a', 'b'};    % Gain factor & Bias factor
% cauCdfVals = [300, 15; 500, 20; 700, 100]'; % Test para groups
% 
% % Run model[Phase2]
% sims = multiModelSim('cauchyFuncs', '/CauchyCdf', ...
%     cauCdfParas, cauCdfVals, {"StopTime", "10"});
% 
% % Acquire inspect datas[Phase3](using `getsimLogs`)
% sims = getsimLogs(sims);
% ====================================
%%
arguments
    modelName 
    subSysName 
    paraNames
    paraVals
    simConfigs cell = {"StopTime", "10"}
    noTrace (1, 1) = false
    verbose (1, 1) = 0
end

if verbose==3
    % See "Ambiguity Notes" about `verbose`
    noTrace = false;
end

if isempty(modelName)
    modelName = findSimModel;
    disv(verbose, {}, '[Info] Model %s found\n', [modelName, '.slx']);
end
disv(verbose, 1, '[Info] Model %s to be loaded\n', [modelName, '.slx']);

if noTrace
    load_system(modelName);
    save_system(['back_', modelName]);
    disv(verbose, {}, '[Info] Backup model %s stored\n', ['back_', modelName, '.slx']);
end
    
trials = size(paraVals, 2);
simResults = cell(trials, 1);
paraStru = genParaStruct(subSysName, paraNames);
disv(verbose, {}, '[Info] %d trails to be ran\n', trials);
for n = 1:trials
    disv(verbose, 1, '[Run] %d Batch\n', n);
    % Config model parameters
    load_system(modelName);
    i = 1;

    for para=paraStru
        set_param([modelName, para.subSysName], para.paraName, num2str(paraVals(i, n)));
        disv(verbose, {}, '[Run] ParameterSource: %s; ParameterValue: %.2f\n', ...
            [para.subSysName, '/', para.paraName], paraVals(i, n));
        i = i+1;
        % Bugfix: Note if the block to be simulated has initialization line
        % that would cause some weird text display in this code
        % Be cautious that 
    end

    save_system(modelName);
    
    if verbose==3
        simResults = {}; return
    end
    
    % Config running parameters and run it.
    simResults{n} = sim([modelName, '.slx'], simConfigs{:});
    disv(verbose, 1, '[Run] %d Batch model simulation successed\n', n);
end

if noTrace
    oldModel = [modelName, '.slx']; newModel = ['back_', modelName, '.slx'];
    delete(oldModel);
    movefile(newModel, oldModel);
    disv(verbose, {}, '[Info] Backup model %s utilted', ['back_', modelName, '.slx']);
end

end

%% Sub-function defination
% Find available Simulink model in the current directory, 
% If nothing found, an error will be thrown.
function f = findSimModel
    files = dir(pwd);
    if isempty(files)
        error("No files in current directory:%s", pwd);
    end
    
    for i=1:length(files)
        name = files(i).name; 
        if endsWith(name, '.slx') || endsWith(name, '.mdl')
            f = name(1:end-4);
            return
        end
    end
      
    error("Simulink model not found in current directory:%s", pwd);
end

% Display intermediate process with verbose control
function disv(v, varargin)
% A specific documentation, which verbose level=2, you should set:
% disv(verbose, {}, _)
% Otherwise, you should use:
% disv(verbose, 1, _)
if v==0
    return
end

if v==1 && isempty(varargin{1}) % Not concise
    return
end

fprintf(varargin{2:end});
end

% Construct mutiple parameter groups using `struct` object.
function paraStru = genParaStruct(subSysName, paraNames)
% The `subSysName` can be seen as a `ParaStruct`
paraStru = 0;
if isstruct(subSysName) 
    paraStru = subSysName;
    assert(isfield(paraStru, 'subSysName') && isfield(paraStru, 'paraName'), ...
    "Not a valid paraStru provided it must contains two fields: `subSysName` and `paraName`");     
end

if ischar(subSysName) || isstring(subSysName)
    paraStru = genParaStructWithFixedSys(subSysName, paraNames);
end

if iscell(subSysName) && iscell(paraNames)
    groupedParaNames = sepCell(paraNames);
    
    paraStru = {};
    for i=1:length(subSysName)
        paraStru = genParaStructWithFixedSys(subSysName{i}, ...
            groupedParaNames{i}, paraStru);
    end
end

if isequal(paraStru, 0)
    error("Please check the document to input the right parameters");
end

end

function paraStru = genParaStructWithFixedSys(subSysName, paraNames, paraStru)
if nargin==2
    paraStru = {};
end

paraStruLen = length(paraStru);
for i=paraStruLen+1:paraStruLen+length(paraNames)
    paraStru(i).subSysName = subSysName;
    paraStru(i).paraName = paraNames{i-paraStruLen};
end
end

function c=sepCell(c, delimiter)
if nargin==1
    delimiter = '';
end

dplace = find(cellfun(@(x) isequal(x, delimiter), c));

if ~isempty(dplace)
    ncell = length(dplace)+1;
    newc = cell(ncell, 1);
    
    top_idx = 1;
    for i=1:ncell-1
        newc{i} = c(top_idx:dplace(i)-1);
        top_idx = dplace(i)+1;
    end
    newc{ncell} = c(top_idx:end);
    c = newc;
end
end
