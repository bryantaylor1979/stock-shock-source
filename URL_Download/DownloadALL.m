function URL_Download(varargin)
% Examples:
% close all
% clear classes
% 
% URL_Download('Macro','Stox','WaitbarEnable',true);
% URL_Download('Macro','BritishBulls_HIST','WaitbarEnable',true);
% obj = URL_Download('Macro','BritishBulls_HIST','RunOnInt',false); 
    % Set compulsory inputs
    Mode = varargin{1};

    args.MapName = 'iii_map_v2.m';
    map = readsymbolslist('iii_map_v2.m');
    args.Symbols = map.SymbolList();
    args.WaitbarEnable = false;
    args.IllegalSymbols = {'CON'}; %Add symbols here if you get a save error.

    [path,~,~] = fileparts(which('URL_Download'));
    args.InstallDir = path;         
    args.MacroLogDir = path;    
    
    switch lower(Mode) 
        case 'britishbulls_hist'
        args.sURL = 'https://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=';
        args.eURL = '.L';
        args.MaxDelayUnit = 16; %number of attempt when exit.
        args.Method = 'url2'; % url, url2, wq, xml
        args.timeout_url2 = 100000; 
        case 'britishbulls_summary'
        args.sURL = 'https://www.britishbulls.com/SignalList.aspx?lang=en&MarketSymbol=LSE';
        args.eURL = '';
        args.MaxDelayUnit = 16; %number of attempt when exit.
        args.Method = 'url2'; % url, url2, wq, xml
        args.timeout_url2 = 100000; 
    end
    
    % Set variable overwrides.
    varargin = varargin(2:end);
    [x] = size(varargin,2);
    for i = 1:2:x
        args.(varargin{i}) = varargin{i+1};
    end

    %Symbols = obj.GetRequiredSymbols(ProgramName,ResultName,Date);
    DownloadAllURL(args,args.Symbols,Mode,args.WaitbarEnable);
end
function Example()
    %%
    URL_Download('BritishBulls_HIST','Symbols',{'BARC.L'})
    %%
    URL_Download('BritishBulls_SUMMARY','Symbols',{''})
end
function DownloadAllURL(args,Symbols,MacroName,WaitbarEnable)
    %
    disp(['Executed: ',datestr(now)])

    %Intialise a waitbar if not visible
    try
        get(obj.handles.figure);
    catch
        if WaitbarEnable == true
            h = waitbar(0);
            position = get(h,'position');
            position(4) = 75;
            set(h,'position',position)
        else
            h = 1; 
        end
    end

    %% Load Objects
    %Verfied - The symbols 
    [x] = size(Symbols,1);
    tic
    ResultsPath = '';
    disp(['URL_Download - ',MacroName])
    for j = 1:x
          if WaitbarEnable == true
              waitbar((j)/x,h,{['URL_Download -',obj.Macro];['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)']})
              drawnow;
          else
              disp(['Processing... ',num2str(j),' of ',num2str(x),' (',num2str(round(j/x*100)),'%)'])
          end
          Symbol = strrep(Symbols{j},'.L','');
          s = sDownloadURL(args,Symbol,ResultsPath);
    end
    if WaitbarEnable == true
        close(h)
    end
    disp(['Time Taken: ',CalculateTime(toc)])
end
function s = sDownloadURL(args,Symbol,ResultsPath)
    url = [args.sURL,Symbol,args.eURL];
    disp(url);
    [s,Error] = DownloadURL(url ,    'Method',          args.Method, ...
                                     'MaxDelayUnit',    args.MaxDelayUnit, ...
                                     'timeout_url2',    args.timeout_url2)
    n = find(strcmpi(Symbol,args.IllegalSymbols), 1);
    if not(isempty(n))
        Symbol = [Symbol,'__'];
    end
    
%     obj.ResultsLog_OBJ.SaveResult_Type(s,Symbol,ProgramName,ResultName,upper(obj.Method),Date);
end

% Get Save Symbols from British Bulls Summary
function Symbols = GetRequiredSymbols(Program,MacroName,Date)
    %% Required Symbols
    [Data] = obj.III_IndexMap;
    RequiredSymbols = Data(:,2);

    %% Saved Symbols List
    try
        SavedSymbols = obj.GetSaveType_Symbols('URL',Program,MacroName,Date);
    catch
        disp('No symbols found')
        Symbols = RequiredSymbols;   
        return
    end
    [Symbols] = obj.RemoveSymbols(RequiredSymbols,SavedSymbols);
end
function [Symbols] = RemoveSymbols(~,array1,array2)
    % remove small array from the big symbol array
    % order doesn't matter.
    % input array must be column-wise

    small_array = strrep(array1,'.L','');
    big_array = strrep(array2,'.L','');
    Symbols = [];

    [x] = size(small_array,1);
    [y] = size(big_array,1);

    for i = 1:x %first symbol to remove
        n = find(strcmpi(small_array{i},big_array), 1);
        if isempty(n)
            Symbols = [Symbols;small_array(i)];
        end
    end
end