function [varargout] = waitbar2(varargin)
% Waitbar
warning off

[x] = size(varargin,2);
if x == 2    % update
    h = varargin{1};
    Percentage = varargin{2};
    [image] = CreateImage(Percentage);
    Image2 = get(h.figure,'CDATA');
    
    %merge image
    [x1,y1,z1] = size(Image2);
    x1 = x1/2;
    y1 = y1/2;
    
    [x2,y2,z2] = size(image);
    xmin = x1-x2/2;
    xmax = x1+x2/2;
    ymin = y1-y2/2;
    ymax = y1+y2/2;
    Image2(xmin:xmax-1,ymin:ymax-1,:) = image;
    set(h.figure,'CDATA',Image2);
else                        % intialise
    load Image2 Image2
    Percentage = varargin{1};
    [image] = CreateImage(Percentage);
    
    %merge image
    [x1,y1,z1] = size(Image2);
    x1 = x1/2;
    y1 = y1/2;
    
    [x2,y2,z2] = size(image);
    Image2(x1-x2/2:x1+x2/2-1,y1-y2/2:y1+y2/2-1,:) = image;
    
    h.figure = imshow(Image2);
    h.axis = gca;
    varargout{1} = h;
end
    drawnow;
warning on

function [image] = CreateImage(Percentage);
% CreateImage for Percentage Bar

BackGroundColour = [0.8,0.8,0.8];
BarColour = [0,0,1];
Height = 15;
Width = 430;
Period = 20;
BarWidth = 15;

image(1:Height,1:Width,1) = BackGroundColour(1)*255;
image(1:Height,1:Width,2) = BackGroundColour(2)*255;
image(1:Height,1:Width,3) = BackGroundColour(3)*255;

Value = Width*Percentage;
image(1:Height,1:Value,1) = BarColour(1)*255;
image(1:Height,1:Value,2) = BarColour(2)*255;
image(1:Height,1:Value,3) = BarColour(3)*255;
image = uint8(image);

for i = 1:Width
    Logic = rem(i,Period);
    if Logic > BarWidth;
    image(1:Height,i,1) = BackGroundColour(1)*255;
    image(1:Height,i,2) = BackGroundColour(2)*255;
    image(1:Height,i,3) = BackGroundColour(3)*255;
    end
end

