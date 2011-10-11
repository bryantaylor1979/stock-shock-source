function [image] = IconGenerate(String)
%% Icon generation

Color = [0.9255, 0.9137, 0.8471];
% Color = [0.5,    0.5,    0.5];
h = figure('Visible','off');
     
image(1:16,1:16,1) = Color(1);
image(1:16,1:16,2) = Color(2);
image(1:16,1:16,3) = Color(3);

VBorder = 3;
HBorder = 6;

imshow(image)

h1 = text(VBorder,16-HBorder,String, ...
         'FontSize',8, 'FontWeight','demi');
image2 =  getframe(gca);

imwrite(image2.cdata,[String,'.bmp'])
image = image2.cdata;
close(h)
