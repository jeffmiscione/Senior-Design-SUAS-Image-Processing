function [targetColor, letterColor] = determineColors(image)
% i = imread('I:\Homework\Senior Design\Image Processing\camera test images\target.jpg');
% determineColors(i);

% =======If you want to crop the target image at all to eliminate grass====
[height, width, ~] = size(image);
cropAmount = 0; % no cropping done at 0
cropX = cropAmount*width;
cropY = cropAmount*height;
% =========================================================================

image = imcrop(image, ...
    [cropX cropY (width - (2*cropX)) (height - (2*cropY))]);

[X,map] = rgb2ind(image,3,'nodither'); % reduce the image to 3 colors

color0 = 0;     % set count for color0
color1 = 0;     % set count for color1
color2 = 0;     % set count for color2

for rows = 1:size(X,1)
    for cols = 1:size(X,2)
        if(X(rows,cols) == 0)
            color0 = color0 + 1;
        elseif(X(rows,cols) == 1)
            color1 = color1 + 1;
        else
            color2 = color2 + 1;
        end
    end
end

colors = [color0 color1 color2];    % create matrix with each color in it
[~,indexOfMostCommonColor] = max(colors); % determine index of the most common color
[~,indexOfLeastCommonColor] = min(colors); % determine index of the least common color

if (indexOfMostCommonColor ~= 1) && (indexOfLeastCommonColor ~= 1)
    indexOfMiddleCommonColor = 1;
elseif (indexOfMostCommonColor ~= 2) && (indexOfLeastCommonColor ~= 2)
    indexOfMiddleCommonColor = 2;
else
    indexOfMiddleCommonColor = 3;
end

mostCommonColor = colornames('html', [map(indexOfMostCommonColor,1),...
    map(indexOfMostCommonColor,2), map(indexOfMostCommonColor,3)]);

leastCommonColor = colornames('html', [map(indexOfLeastCommonColor,1),...
    map(indexOfLeastCommonColor,2), map(indexOfLeastCommonColor,3)]);

middleCommonColor = colornames('html', [map(indexOfMiddleCommonColor,1),...
    map(indexOfMiddleCommonColor,2), map(indexOfMiddleCommonColor,3)]);

targetColor = mostCommonColor{1};
letterColor = middleCommonColor{1};

% disp(strcat('The least common color is: ', leastCommonColor));
% disp(strcat('The most common color is: ', mostCommonColor));

% figure
% imshow(ind2rgb(X, map));

