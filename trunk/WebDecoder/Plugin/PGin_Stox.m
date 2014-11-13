classdef PGin_Stox <    handle & ...
                        DataSetFiltering
    methods
        function DataSet = StarRating(obj,DataSet)
            %%
            Overall = DataSet.Overall;
            Overall = strrep(Overall,'<img border=0 src=http://uk.stoxline.com/pics/','');
            Rating = str2double(strrep(Overall,'s.bmp>',''))
            DataSet.Rating = Rating;
        end
        function DataSet2 = Signal(obj,DataSet2)
            %%
            Rating = DataSet2.Rating;
            x = max(size(Rating))
            for i = 1:x
                switch Rating(i)
                    case 1
                        Signal{i} = 'Strong Sell';
                    case 2
                        Signal{i} = 'Sell';
                    case 3
                        Signal{i} = 'Neutral';
                    case 4
                        Signal{i} = 'Buy';
                    case 5
                        Signal{i} = 'Strong Buy';
                    otherwise
                        Signal{i} = 'N/A';
                end
            end
            DataSet2.Signal = Signal;
        end
        function DataSet = Stars(obj,DataSet)
            %%
            Rating = DataSet.Rating;
            x = max(size(Rating));
            for i = 1:x
                switch Rating(i)
                    case 1
                        Stars{i} = '?';
                    case 2
                        Stars{i} = '??';
                    case 3
                        Stars{i} = '???';
                    case 4
                        Stars{i} = '????';
                    case 5
                        Stars{i} = '?????';
                    otherwise
                        Stars{i} = 'N/A';
                end
            end
            DataSet.Stars = Stars;
        end
    end
end