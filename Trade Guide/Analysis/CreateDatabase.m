classdef CreateDatabase
    properties
        ColumnNames = { 'Symbol'; ...
                        'Org_StartDate'; ...
                        'Org_EndDate'; ...
                        'New_StartDate'; ...
                        'New_EndDate'; ...
                        'NotEnoughData'; ...
                        'Status'; ...
                        };
        Mode = 'Silent';
        Config = true;
    end
    methods (Hidden = false)
        function [Output] = Process(varargin)
            %
            %Written by:    Bryan Taylor
            %Date Created:  25th August 2008
            %Date Modified: 25th August 2008
            global h

            %%
            h = get(h.figure,'UserData');
            path = h.path.savedata;
            MainDatabaseLocation = [path,'Database\Download_Mat\Data\'];

            %Get list of downloaded symbols
            cd(MainDatabaseLocation);
            names = struct2cell(dir)';
            [x] = size(names,1);
            tablelist = names(3:x,1);

            %User Inputs
            [reqstartdate,Duration,DatabaseName] = GetNumberOfInvestments();
            reqenddate = reqstartdate + Duration;

            %% Make new database
            NewDatabasePath = [path,DatabaseName,'\Download_Mat\Data\'];
            try
                mkdir(NewDatabasePath);
            catch
                %TODO: Ask if you want to overwrite this info.
                error('Database already exists') 
            end

            %Int Var
            Data = [];

            %% Main Loop
            [x] = size(tablelist,1);
            for i = 1:x
                  %Update GUI
                  set(h.Status,'String',['Processing... ',num2str(i),' of ',num2str(x),' (',num2str(round(i/x*100)),'%)']);
                  drawnow;

                  %Load Data And Expect Date Range
                  load([MainDatabaseLocation,'\',tablelist{i}])
                  LocalBase_Symbol = strrep(tablelist{i},'.mat','');
                  LocalBase_Symbol = strrep(LocalBase_Symbol,'.','_');
                  [startdate,enddate] = StockDateRangeMat(DatabaseName,LocalBase_Symbol,DataStore);

                  NotEnoughData = 'false';
                  Status = 'Error';
                  %Workout if to be included
                  if startdate>reqstartdate
                     NotEnoughData = 'True';
                     Status = 'Dismissed';
                  end
                  if enddate<reqenddate
                     NotEnoughData = 'True';
                     Status = 'Dismissed';
                  end

                  %Crop data & Save
                  try
                  if strcmpi(NotEnoughData,'false')
                      n = find(DataStore(:,1)>reqstartdate);
                      DataStore = DataStore(n,:);
                      n = find(DataStore(:,1)<reqenddate);
                      DataStore = DataStore(n,:);
                      save([NewDatabasePath,'\',LocalBase_Symbol],'DataStore');
                      Status = 'Complete';
                  end
                  end

                  %New row
                  try
                  NewRow = {LocalBase_Symbol, ...
                            datestr(startdate), ...
                            datestr(enddate), ...
                            datestr(reqstartdate), ...
                            datestr(reqenddate), ...
                            NotEnoughData, ...
                            Status, ...
                            };
                  catch
                  %TODO: Why is the mat file with no data in them? 
                  NewRow = {LocalBase_Symbol, ...
                            'n/a', ...
                            'n/a', ...
                            datestr(reqstartdate), ...
                            datestr(reqenddate), ...
                            NotEnoughData, ...
                            Status, ...
                            };
                  end
                  Data = [Data;NewRow];

                  %Update GUI
                  if strcmpi(Mode,'Visual')
                     set(h.table,'Data',Data);
                  end
                  Data = [Data;NewRow];
            end

            if strcmpi(Mode,'Silent')
                  set(h.table,'Data',Data);
            end
            set(h.Status,'String','Ready');
            Output = 1;

            String = get(h.DatabaseSelection.pulldown,'String');
            String = [String;{DatabaseName}];
            set(h.DatabaseSelection.pulldown,'String',String);
        end
        function [StartDate,Duration,DatabaseName] = GetNumberOfInvestments();
            %Written by:    Bryan Taylor
            %Date Created:  30th April 2008
            prompt= {'StartDate: ', ...
                     'Duration: ', ...
                     'DatabaseName'};
            name        = 'Inputs for Decsion function';
            numlines    = 1;

            % Get Date Range
            StartDate               = today - 365;
            Duration                = 365;
            DatabaseName            = 'Name';

            % input para gui
            defaultanswer   = {num2str(StartDate),num2str(Duration),DatabaseName};
            answer          = inputdlg(prompt,name,numlines,defaultanswer);
            drawnow;

            % Return data
            StartDate               = str2num(answer{1});
            Duration                = str2num(answer{2});
            DatabaseName            = answer{3};
        end
    end
end
