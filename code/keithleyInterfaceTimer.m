%% keithleyInterfaceTimer.m
%
% Sets up an event timer for communicating with the Keithley SMU
%
% Alexander Volkov
% 16-722

function t = keithleyInterfaceTimer(s,duration,vds,imax,file)

    rate = 50; % [Hz]

    t = timer;
    t.UserData = struct('serialObj',s,'data',[],'voltage',vds,'currentMax',imax,'saveName',file);
    t.StartFcn = @setupKeithley;
    t.TimerFcn = @readKeithleyData;
    t.StopFcn = @saveAndClean;
    t.Period = 1/rate;
    t.StartDelay = t.Period;
    t.TaskstoExecute = ceil(duration/t.Period);
    t.ExecutionMode = 'fixedRate';
    t.BusyMode = 'queue';
    
end

function setupKeithley(eventTimer,~)
    fprintf('\nSetting up measurement...\n');

    ud = get(eventTimer,'UserData');
    
    SMU = ud.serialObj;
    vds = ud.voltage;
    imax = ud.currentMax;
    
    % Start communication
    fopen(SMU);
    
    % Send setup commands
    fprintf(SMU,':SENS:FUNC "RES"\n');
    fprintf(SMU,':SENS:RES:MODE MAN\n');
    fprintf(SMU,':SOUR:FUNC VOLT\n');
    fprintf(SMU,':SOUR:VOLT:MODE FIX\n');
    fprintf(SMU,':SOUR:VOLT:RANG 2\n');
    fprintf(SMU,':SOUR:VOLT:LEV %.2f\n',vds);
    %fprintf(SMU,':SOUR:DEL 0');
    fprintf(SMU,':SENS:CURR:PROT %.2f\n',imax);
    fprintf(SMU,':SENS:CURR:RANG:AUTO ON\n');
    fprintf(SMU,':SYST:RSEN OFF\n');
    fprintf(SMU,':RES:NPLC 0.1');
    fprintf(SMU,':TRIG:SOUR IMM\n');
    fprintf(SMU,':ARM:SOUR IMM\n');
    fprintf(SMU,':ARM:COUN 1\n');
    fprintf(SMU,':TRIG:COUN 1\n');
    fprintf(SMU,':FORM:ELEM RES, TIME');
    
    % Enable output
    fprintf(SMU,':OUTP ON\n');
    
end

function readKeithleyData(eventTimer,event)
    time = event.Data.time;
    ud = get(eventTimer,'UserData');
    SMU = ud.serialObj;

    fprintf('Data transferred at time: %s',datestr(time,'dd-mmm-yyyy HH:MM:SS.FFF\n'));
    fprintf(SMU,':READ?\n');
    
    parsed = fscanf(SMU,'%e,%e');
    
    ud.data = [ud.data; parsed']; % Figure out format
    
    % Read data from SMU and clear buffer
    set(eventTimer,{'UserData'},{ud});
end

function saveAndClean(eventTimer,~)
    fprintf('\nAll done... saving data and cleaning up.\n');
    
    ud = get(eventTimer,'UserData');
    SMU = ud.serialObj;
    
    % Disable output
    fprintf(SMU,':OUTP ON\n');
    
    ud = get(eventTimer,'UserData');
    
    data = ud.data;
    
    % Save data
    save(ud.saveName,'data');
    
    % Close everything up
    fclose(SMU);
    delete(eventTimer);
end
