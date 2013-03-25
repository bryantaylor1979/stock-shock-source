classdef ImageIO < handle
    properties (SetObservable = true)
        Mode = 'all' %all or ui
        Path = 'C:\ISP\awb\'
        ImageType = '.raw'
        names
    end
    properties (Hidden = true)
        log
    end
    methods
        function Example(obj)
            %% 
            close all
            clear classes
            obj = ImageIO;
            ObjectInspector(obj)
            
            %%
            obj.names
        end
        function RUN(obj)
            %%
            if strcmpi(obj.Mode,'ui')
                obj.names = obj.SelectImageNamesFromDir(obj.Path,obj.ImageType);
            else
                try
                obj.names = obj.GetImageNamesFromDir(obj.Path,obj.ImageType);
                catch
                obj.names = {};    
                end
            end
        end
    end
    methods (Hidden = true)
        function obj = ImageIO(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end     
        end
        function Convert_Bmp2Pgm(obj,FileName)
            %inserted into same direct and the same name. 
            %%
            image = imread(FileName);
            obj.WritePgmFile(image,255,strrep(FileName,'.bmp','.pgm'),2);
%             image = uint16(double(image)*4);          
%             imwrite(image,strrep(FileName,'.bmp','.pgm'))
        end
        function Convert_Raw2Pgm(obj,FileName)
            %inserted into same direct and the same name. 
            %% 
            image = obj.ReadRawFile(FileName,3280/2);
            obj.WritePgmFile(image,255,strrep(FileName,'.raw','.pgm'),2);
%             image = uint16(double(image)*4);          
%             imwrite(image,strrep(FileName,'.bmp','.pgm'))
        end
        function [W,H,D] = UI_GetImDim(obj,W,H,D)
            %%
            disp('raw decode')
            prompt={'Width:','Height:','Depth'};
            title ='Enter Image Dimensions:';
            numlines=1;
            defaultanswer={num2str(W),num2str(H),num2str(D)};
            answer=inputdlg(prompt,title,numlines,defaultanswer);
            W = str2num(answer{1});
            H = str2num(answer{2});
            D = str2num(answer{3});
            return   
        end
        function [bayerimage] = readimage(obj,name,Width)
            %Written by:    Bryan Taylor
            %Date Created:  23rd October 2008
            n = findstr(name,'.');
            format = name(n(end)+1:end);

            if strcmpi(format,'raw')
                %% default
                bayerimage = obj.ReadRawFile(name,Width);
                bayerimage = double(bayerimage)./255;
                return    
            end

            if strcmpi(format,'pgm')
                %%
                [bayerimage, image_width, image_height, max_code] = obj.ReadPgmFile(name);
                bayerimage = bayerimage./double(max_code);
                return
            end

            %All other formats
            bayerimage = imread(name); %Read in image
            if obj.log == true
                disp(['Class: ',class(bayerimage)])
            end
            switch class(bayerimage)
                case 'uint8'
                    bayerimage = double(bayerimage)./256;
                case 'uint16'
                    bayerimage = double(bayerimage)./(2^16);
                otherwise

            end
        end
        function names = GetImageNamesFromDir(obj,Path,imagetype)
            % names = GetImageNamesFromDir(obj,Path,imagetype)
            % Written by: bryan taylor
            p = [];
            PWD = pwd;
            try
                cd(Path);
            catch
                msgbox(['Cannot CD to ',Path, ' (Name isnonexistent or not a directory).'])
            end
            files = dir;
            filenames = rot90(struct2cell(files),3);
            
            filenames = filenames(3:end,end);
            
            %Filter filenames that are not images. 
            x = size(filenames,1);
            for i = 1:x
                n = findstr(filenames{i},imagetype);
                if isempty(n)
                p(i) = 0;
                else
                p(i) = 1;
                end
            end
            if isempty(p)
               error('No image files found') 
            end
            names = filenames(find(p==1));              
        end
        function names = SelectImageNamesFromDir(obj,Path,imagetype)
            names = obj.GetImageNamesFromDir(Path,imagetype);
            [s,v] = listdlg('PromptString','Select a file:',...
                            'SelectionMode','multiple',...
                            'ListString',names);
            names = names(s);          
        end  
        function Img = WriteRaw10Bit(obj, FileName, Img, Stride, Header )
            error( nargchk( 4, 5, nargin));
            if ( nargin < 5 )
                Header = zeros(1,1024);
            end

            [SizeY, SizeX] = size(Img);
            Reminder = Stride - SizeX*1.25;
            if( round(Reminder) ~= Reminder )
                Reminder = 0;
            end

            ImgRaw = zeros( SizeY, Stride );

            ImgRaw(:,1:5:end-Reminder) = bitand(Img(:,1:4:SizeX), hex2dec('FFFC'))/4;
            ImgRaw(:,2:5:end-Reminder) = bitand(Img(:,2:4:SizeX), hex2dec('FFFC'))/4;
            ImgRaw(:,3:5:end-Reminder) = bitand(Img(:,3:4:SizeX), hex2dec('FFFC'))/4;
            ImgRaw(:,4:5:end-Reminder) = bitand(Img(:,4:4:SizeX), hex2dec('FFFC'))/4;
            ImgRaw(:,5:5:end-Reminder) = bitand(Img(:,1:4:end), 3)    + bitand(Img(:,2:4:end), 3)*4  + ...
                                         bitand(Img(:,3:4:end), 3)*16 + bitand(Img(:,4:4:end), 3)*64;

            fid = fopen( FileName, 'wb' );
            fwrite( fid, Header, 'uint8');
            fwrite( fid, ImgRaw', 'uint8');
            fclose( fid );
        end
    end
    methods (Hidden = true)
        function [image, image_width, image_height, max_code] = ReadPgmFile(obj,pgmFileName )
        % [image, image_width, image_height, max_code]=ReadPgmFile( pgmFileName )
        % Reads in an PGM Raw Bayer Image either 8-bit or 16-bit
        %
        % Input Parameters:
        % pgm_file_name  = input ASCII PGM file name
        %
        % Return Parameters:
        % image = 2-D integer array containing raw bayer image data
        %
        % Examples:
        % [image, image_width, image_height, max_code] = ReadPgmFile( 'DUT_1_AV_On_D65_10bit_10.bmp_AvgOut.pgm' )

            % Attempt to open PGM Raw Bayer Image File
            fid = fopen( pgmFileName, 'rb' );

            if fid > -1
               display( sprintf( 'Reading PGM File "%s"', pgmFileName ) );

               % Read in pgm file infomation header
               info           = uint16(zeros( 4 ) );
               index          = 1;
               prev_data_flag = 0;
               commentFlag    = 0;

               while( index <= 4 )

                   % Read in a character 
                   byte = fread( fid, 1, 'uint8' );

                   if byte == uint8('#')  % # Comment Character
                       commentFlag = 1;
                       data_flag = 0;
                   elseif byte == 10 || byte == 13  % 10=NL, 13=CR
                       commentFlag = 0;
                       data_flag = 0;
                   elseif commentFlag == 0 && byte >= uint8('0') && byte <= uint8('9')
                       info(index) = info(index)*10 + (uint16(byte)-uint16('0'));
                       data_flag = 1;
                   else
                       data_flag = 0;
                   end    

                   if prev_data_flag == 1 && data_flag == 0
                       index = index + 1;
                   end

                   prev_data_flag = data_flag;          
               end

               % Print output Pgm file information
               pgmFileType  = info(1);
               image_width  = info(2);
               image_height = info(3);
               max_code     = info(4);

               display( sprintf( 'PGM File Type = "P%d"', pgmFileType ) );
               display( sprintf( 'Image Info: %d x %d, Max: %d', image_width, image_height, max_code ) );

                % Endianess
                machineFormat = 'ieee-be'; % Big Endian
                % machineFormat = 'ieee-le'; % Little Endian

                % Read in data values
               if pgmFileType == 5
                   if max_code > 255
                       image = fread( fid, 'uint16', machineFormat );
                   else
                       image = fread( fid, 'uint8',  machineFormat );
                   end
               else
                   image = fscanf( fid, '%d', inf );
               end

               fclose( fid );

               % Determine the number of values read
               valuesRead = length( image );
               display( sprintf( 'Read %d values', valuesRead ) );   

               % transform image
               image = reshape(image, info(2), info(3) )';

            else
                display( sprintf( 'Failed to open PGM File "%s"', pgmFileName ) );
                image        = [];
                image_width  = 0;
                image_height = 0;
                max_code     = 0;
            end

        end
        function image = ReadRawFile(obj,image_file_name,W)
            % image=ReadRawFile(image_file_name, image_width, image_height, max_code )
            % Reads in an Binary Raw Bayer Image either 8-bit or 16-bit
            %
            % Input Parameters:
            % pgm_file_name  = input Binary Raw file name
            %
            % Return Parameters:
            % image = 2-D integer array containing raw image data
            %
            % Examples:
            % image = vup_read_raw_file( 'DUT_1_AV_On_D65_10bit_10.bmp_AvgOut.raw', 2048, 1536, 10 )

                % Attempt to open Binary  Raw Image File
                fid = fopen(image_file_name, 'rb' );

                if fid > -1
%%
                    display( sprintf( 'Reading Raw File "%s"', image_file_name ) );

                    % Endianess
            %         machineFormat = 'ieee-be'; % Big Endian
                    machineFormat = 'ieee-le'; % Little Endian


                    %1280 x 720
                    
                    %
%                     [W,H,D] = obj.UI_GetImDim(W,H,D);
%                     W
                    
                    % Read in raw data
                    D = 255;
                    D = 2^16-1;
                    if D > 255
                        raw=fread( fid, 'uint16', machineFormat);
                    else
                        raw=fread( fid, 'uint8',  machineFormat);
                    end

                    
                    x = size(raw,1);
                    
                    %
                    H = floor(x/(W*2));
                    length = W*H*2;
                    
                    raw = raw(1:length);
                    image = reshape( raw, W*2, H )';
                    
                    %%
                    fclose( fid );

                    % transform image
                else
                    display( sprintf( 'Failed to open Raw  File "%s"', image_file_name ) );
                    image = [];
                end

        end
        function WritePgmFile(obj, image, max_code, image_file_name, pgmFileType )
        % WritePgmFile( image, max_code, image_file_name, pgmFileType )
        %
        % Writes a Binary Pgm Bayer Image either 8-bit or 16-bit
        %
        % Input Parameters:
        % image        = 2-D image array
        %                must be either uint8 or unit16
        % max_code     = maximum valid value
        %                 8-bit data =  255
        %                10-bit data = 1023
        % pgmFileName  = output Binary Pgm file name
        % pgmFileType  = 2 (Ascii) or 5 (Binary)
        %
        % Return Parameters:
        % None
        %
        % Examples:
        % WritePgmFile( image, 'DUT_1_AV_On_D65_10bit_10.bmp_AvgOut.raw' )

            % Attempt to open Binary Pgm Image File
            fid = fopen( image_file_name, 'wb' );

            % Determine Image width and height
            [image_height image_width] = size( image );

            if fid > -1

                display( sprintf( 'Writing Pgm File "%s"', image_file_name ) );

                % transform image
                image1 = image(:,:,1)';
                image2 = image(:,:,2)';
                image3 = image(:,:,3)';

                % Print Output PGM File header
                % P2 = ASCII Data, P5 = Binary Data
                fprintf( fid, 'P%d\n',    pgmFileType );
                fprintf( fid, '# "%s"\n', image_file_name );
                fprintf( fid, '%d %d\n',  image_width, image_height );
                fprintf( fid, '%d\n',     max_code );

                % Endianess
                machineFormat = 'ieee-be'; % Big Endian
                % machineFormat = 'ieee-le'; % Little Endian

                % Read in raw data
                if pgmFileType == 5
                    switch class( image )
                        case 'uint16'
                            fwrite( fid, image, 'uint16', machineFormat );
                        case 'uint8'
                            fwrite( fid, image, 'uint8',  machineFormat );
                        otherwise
                            display( 'Unsupported array class = must be either uint8 or uint16 data' );
                    end
                else
                    fprintf( fid, '%d\n', image );
                end

                % Close output file
                fclose( fid );

            else
                display( sprintf( 'ERROR! - Failed to open Pgm File "%s"', image_file_name ) );
            end

        end
        function CheckFileNameExists(obj,path,filename)
            %%
            cd(path)
            filenames = struct2cell(dir);
            filenames = filenames(1,3:end);
            
            x = numel(filenames);
            n = find(strcmpi(filenames,filename));
            
            if isempty(n)
                string = ['File does not exist: ',filename];
                uiwait(msgbox(string));
                error(string);
            end
        end
    end
end
