classdef BayerSplit
    % Example: Output Order: R, GR, GB, B 
    % BayerOrder = 1;
    % obj = BayerSplit;
    % [newimage] = obj.RUN(image,BayerOrder);
    properties
    end
    methods
        function [newimage] = RUN(obj,image,BayerOrder);
            % INPUTS:
            % -------
            %   image       - bayer image (single channel or grey scale type image)
            %   BayerOrder  - bayer order [1:4]
            %
            %
            % OUTPUTS:
            % -------
            %   image       - 4 channel matrix image array. 
            %
            % 
            % Example: Output Order: R, GR, GB, B 
            % -----------------------------------
            %
            % BayerOrder = 1;
            % obj = BayerSplit;
            % [newimage] = obj.RUN(image,BayerOrder);
            

            %% Read Image
            [x,y] = size(image);

            %% Spilt Channels
            Ch1 = image(1:2:x,1:2:y);
            Ch2 = image(1:2:x,2:2:y);
            Ch3 = image(2:2:x,1:2:y);
            Ch4 = image(2:2:x,2:2:y);

            switch BayerOrder
                case 1
                    newimage(:,:,1) = Ch1;
                    newimage(:,:,2) = Ch2;
                    newimage(:,:,3) = Ch3;
                    newimage(:,:,4) = Ch4;
                case 2
                    newimage(:,:,3) = Ch1;
                    newimage(:,:,2) = Ch2;
                    newimage(:,:,1) = Ch3;
                    newimage(:,:,4) = Ch4;
                case 3
                    newimage(:,:,1) = Ch1;
                    newimage(:,:,2) = Ch2;
                    newimage(:,:,3) = Ch3;
                    newimage(:,:,4) = Ch4; 
                case 4
                    newimage(:,:,3) = Ch1;
                    newimage(:,:,4) = Ch2;
                    newimage(:,:,1) = Ch3;
                    newimage(:,:,2) = Ch4; 
                otherwise
                    error('Bayer order must be between 1 and 4')
            end
        end
        function image = BayerCombine(obj,newimage,BayerOrder)
            %% Spilt Channels
            [x,y,z] = size(newimage);
            x = x*2;
            y = y*2;
            switch BayerOrder
                case 1
                    Ch1 = newimage(:,:,1);
                    Ch2 = newimage(:,:,2);
                    Ch3 = newimage(:,:,3);
                    Ch4 = newimage(:,:,4);
                case 2
                    Ch1 = newimage(:,:,3);
                    Ch2 = newimage(:,:,2);
                    Ch3 = newimage(:,:,1);
                    Ch4 = newimage(:,:,4);
                case 3
                    Ch1 = newimage(:,:,1);
                    Ch2 = newimage(:,:,2);
                    Ch3 = newimage(:,:,3);
                    Ch4 = newimage(:,:,4); 
                case 4
                    Ch1 = newimage(:,:,3);
                    Ch2 = newimage(:,:,4);
                    Ch3 = newimage(:,:,1);
                    Ch4 = newimage(:,:,2); 
                otherwise
                    error('Bayer order must be between 1 and 4')
            end
            image(1:2:x,1:2:y) = Ch1;
            image(1:2:x,2:2:y) = Ch2;
            image(2:2:x,1:2:y) = Ch3;
            image(2:2:x,2:2:y) = Ch4;
        end
    end
end