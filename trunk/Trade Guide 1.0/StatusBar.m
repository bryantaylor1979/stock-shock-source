%% Status Bar
function [h] = StatusBar(varargin);

[x] = size(varargin,2);
if x == 1
    number = varargin{1};
    [bar] = ImageGen(number);
    h.image = imshow(bar);
    h.axes =gca;
    set(h.axes,'Position',[0.68,0.02,0.3,0.22]);
    x = 1;
    h.text1 = text(97,8,1,'0%');
    set(h.text1,'HorizontalAlignment','center');
    set(h.text1,'FontWeight','bold');
    set(h.text1,'FontSize',10);
else
    h = varargin{1};
    number = varargin{2};
    [bar] = ImageGen(number);
    set(h.image,'cdata',bar);
    if number == 1;
        set(h.text1,'String',['Complete']);
    else
        set(h.text1,'String',[num2str(number*100,2),'%']);
    end
end

function [bar] = ImageGen(number)
bar = ones(15,200,3);
one = round(200*double(number));
bar(:,1:one,1:2) = 0.35;
[x,y,z] = size(bar);

%Border
bar(1:x,1,:) = 0;
bar(1:x,y,:) = 0;
bar(1,1:y,:) = 0;
bar(x,1:y,:) = 0;