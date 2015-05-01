function [s,Error] = download(varargin)
    % Download URL
    % Method
    %     xml - this can be a wen page that is in xml format
    %     url - this is the inbuilt url query function.
    %     url2 - this is from the mathworks exchange. 
    %     wq - web query.
    %
    % Example: 
    %     [s,Error] = DownloadURL(varargin)
    
    % compulsory inputs
    url = varargin{1};
    
    % Defaults
    args.MaxDelayUnit = 20;
    args.DelayUnit = 1;
    args.MaxNumberOfRetry = Inf;
    
    args.timeout_url2 = 100000;
    args.Method = 'url2'; %xml, url, url2, wq
    args.filename2save = [];
    args.IllegalSymbols = {'CON'}; %Add symbols here if you get a save error.
    args.display_html = false;
    
    % optional iputs
    varargin = varargin(2:end);
    x = size(varargin,2);
    for i = 1:2:x
        args.(varargin{i}) = varargin{i+1};
    end
    
    Error = 0;
    DelayUnit = args.DelayUnit;
    TryNumber = 1;
    while DelayUnit < args.MaxDelayUnit
        try 
            switch lower(args.Method)
                case 'xml'
                    s = download_xml(url);
                case 'url'
                    s = urlread(url);
                case 'url2'
                    s = download_url2(url,'GET','',[],'READ_TIMEOUT',args.timeout_url2);               
                case 'wq'
                    s = download_wq(url); 
                otherwise
                    error('method not recognised')
            end
            break
        catch
            if args.MaxNumberOfRetry == TryNumber
                break
            end
            TryNumber = TryNumber + 1;
            disp(['Connection problems, Wait: ',num2str(DelayUnit)])
            pause(DelayUnit);
            DelayUnit = DelayUnit*2;
        end
    end
    if or(args.MaxNumberOfRetry <= TryNumber,args.MaxDelayUnit <= DelayUnit)
       s = [];
       Error = -2;
       warning(['Failed to download: ',url])
       return 
    end 
    if not(isempty(args.filename2save))
        switch lower(args.Method)
            case {'url','url2'}
                fid = fopen(HTML_PATH,'wt');
                fprintf(fid,'%c',s);
            otherwise
                error('writing to file in this more not recognised')
        end
    end
    if args.display_html == true
        DisplayHTML(s);
    end
end
function DisplayHTML(s)
    SaveHTML(s,'temp.html')
    web('temp.html') 
end
function SaveHTML(s,filename)
    fid = fopen(filename,'wt');
    fprintf(fid,'%c',s)  
end
function Example()
    %%
    close all
    clear classes
    url = 'https://www.britishbulls.com/SignalPage.aspx?lang=en&Ticker=BARC.L';
    [s,Error] = DownloadURL(url);
    
    %%
    close all
    clear classes
    url = 'https://www.britishbulls.com/SignalList.aspx?lang=en&MarketSymbol=LSE';
    [s,Error] = DownloadURL(url,'display_html',true,'Method','url');    
    
    %%
    close all
    clear classes
    url = 'https://www.britishbulls.com/IndexSignalList.aspx?lang=en';
    [s,Error] = DownloadURL(url,'Method','url')      
end