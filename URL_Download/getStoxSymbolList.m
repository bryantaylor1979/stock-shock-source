function [Symbols] = getStoxSymbolList(varargin)
    %     url = ['http://uk.stoxline.com/symbols.php?fl=',Symbol];
    %%
    tic
    args.InstallPath = fileparts(which('getStoxSymbolList'));
    args.ResultsDir = fullfile(args.InstallPath,'Results');
    args.SaveAsArray = true;
    args.SaveAsStruct = true;
    args.SaveAsJson = true;
    
    [x] = size(varargin,2);
    for i = 1:2:x
        args.(varargin{i}) = varargin{i+1};
    end
    
    if not(exist(args.ResultsDir,'file'))
        mkdir(args.ResultsDir)
    end
    Alpha = { 'A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L'; ...
              'M';'N';'O';'P';'Q';'R';'S';'T';'U';'V';'W'; ...
              'X';'Y';'Z'}; 
          
    ARRAY = DownloadAll(Alpha);
    Symbols = ARRAY(:,1);
    
    if args.SaveAsArray == true
        save(fullfile(args.ResultsDir,'ARRAY.mat'),'ARRAY')
    end
    
    struct = Array2Struct(ARRAY);
    if args.SaveAsStruct == true
        save(fullfile(args.ResultsDir,'struct.mat'),'struct')
    end
    if args.SaveAsJson == true
        string = struct2json2({struct})
        fid = fopen(fullfile(args.ResultsDir,'json.mat'),'wb');
        fwrite(fid,string,'char');
        fclose(fid)
    end
    
    disp(CalculateTime(toc))
end
function DATASET = DownloadAll(Alpha)
    x = size(Alpha,1);
    for i = 1:x
        url = ['http://uk.stoxline.com/symbols.php?fl=',Alpha{i}];
        disp(url)
        [s,Error] = download(url);
        TABLE = decodeTable2(s);
        if i == 1
            DATASET = TABLE;
        else
            DATASET = [DATASET;TABLE];
        end
    end
end
function struct = Array2Struct(ARRAY)
    struct.Symbol = ARRAY(:,1);
    struct.CompanyName = ARRAY(:,2);
end
function Example()
    %%
    close all
    clear classes
    DATASET = getStoxSymbolList();
end
