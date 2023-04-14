function simStru = getsimLogs(simOut, signals, OtherType)
    arguments
        simOut 
        signals cell = {}
        OtherType = {}
    end
    
    % Single simulation output 
    if isequal(class(simOut), 'Simulink.SimulationOutput')
        simStru = getSingleSimLogs(simOut, signals, OtherType);
        return
    end
    
    % Mutiple simulation outputs
    simStru = struct();
    batchNum = length(simOut);
    for i=1:batchNum
        logs = getSingleSimLogs(simOut{i}, signals, OtherType);
        
        sigNames = fieldnames(logs);
        for j = 1:length(sigNames)
            simStru(i).(sigNames{j}) = logs.(sigNames{j});
        end
        
    end
end


function logs = getSingleSimLogs(simOut, signals, OtherType)
    arguments
        simOut Simulink.SimulationOutput
        signals cell = {}
        OtherType = {}
    end
    
    if isempty(OtherType)
        simLogs = simOut.logsout;
    else
        simLogs = getfield(simOut, OtherType);
    end
%     logs = {};
    logs = struct();
    if isempty(signals)
        signals = simLogs.getElementNames();
    end
    
    signals = signals(~cellfun(@isempty, signals)); % Remove the nameless
    for i=1:length(signals)
%         logs = [logs simLogs.get(signals{i}).Values];
        logs.(signals{i}) = simLogs.get(signals{i}).Values;
    end

end
