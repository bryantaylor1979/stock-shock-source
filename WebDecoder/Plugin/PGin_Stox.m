classdef PGin_Stox <    handle & ...
                        DataSetFiltering
    methods
        function DataSet2 = StarRating(obj,DataSet)
            %%
            Overall = obj.GetColumn(DataSet,'Overall');
            Overall = strrep(Overall,'<img border=0 src=http://uk.stoxline.com/pics/','');
            Rating = str2double(strrep(Overall,'s.bmp>',''));
            DataSet2 = [DataSet,dataset(Rating)];
        end
        function DataSet3 = Signal(obj,DataSet2)
            %%
            Rating = obj.GetColumn(DataSet2,'Rating');
            x = size(Rating,1);
            for i = 1:x
                switch Rating(i)
                    case 1
                        Signal{i,1} = 'Strong Sell';
                    case 2
                        Signal{i,1} = 'Sell';
                    case 3
                        Signal{i,1} = 'Neutral';
                    case 4
                        Signal{i,1} = 'Buy';
                    case 5
                        Signal{i,1} = 'Strong Buy';
                    otherwise
                        Signal{i,1} = 'N/A';
                end
            end
            DataSet3 = [DataSet2,dataset(Signal)];
        end
        function DataSet4 = Stars(obj,DataSet3)
            %%
            Rating = obj.GetColumn(DataSet3,'Rating');
            x = size(Rating,1);
            for i = 1:x
                switch Rating(i)
                    case 1
                        Stars{i,1} = '?';
                    case 2
                        Stars{i,1} = '??';
                    case 3
                        Stars{i,1} = '???';
                    case 4
                        Stars{i,1} = '????';
                    case 5
                        Stars{i,1} = '?????';
                    otherwise
                        Stars{i,1} = 'N/A';
                end
            end
            DataSet4 = [DataSet3,dataset(Stars)];
        end
    end
end