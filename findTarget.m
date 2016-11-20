function [targetFound, targetImage, targetCentroidX, targetCentroidY] = findTarget(image)
% FINDTARGET Output whether the image has a target.  If it does, an image
% of that target and the X and Y points of the target's centroid are
% returned.
%
% Example:
%
% [targetFound, targetImage, targetCentroidX, targetCentroidY] = findTarget(image)

scalingFactor = 0.25;   % amount to scale the image...
                        % New dimensions become
                        % (scalingFactor*oldHeight)*(scalingFactor*oldWidth)
Iorig = image;
Ismall = imresize(Iorig, scalingFactor);    % scales  for faster processing
Ismall = rgb2gray(Ismall);  % convert image to grayscale for edge detection

% perform blur
Iblur = imfilter(Ismall, fspecial('disk',4),'replicate');

% perform edge detection
finalI = edge(Iblur,'canny', 0.8);

% convert to binary image
finalI = imfill(finalI, 'holes');
[B,L] = bwboundaries(finalI,'noholes');


for k = 1:length(B)
  boundary = B{k};
end

stats = regionprops(L,'Area','Centroid','BoundingBox');

threshold = 0.85;
highest = 0;
result = 0;

% loop over the boundaries
for k = 1:length(B)
  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;
  perimeter = sum(sqrt(sum(delta_sq,2)));

  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;

  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;
  
  if (metric > threshold) && (metric > highest)
      highest = metric;
      result = k;
  end  
end

if result == 0
    targetFound = 0;
    targetCentroidX = 0;
    targetCentroidY = 0;
    targetImage = 0;
else
    % should perform the imfill part again on the full size image to get a more defined bounding box
    targetFound = 1;
    targetCentroidX = stats(result).Centroid(1) / scalingFactor;
    targetCentroidY = stats(result).Centroid(2) / scalingFactor;

    thisBB = stats(result).BoundingBox;     % determine the bounding box
    thisBB(1) = (thisBB(1)/scalingFactor);  % left start
    thisBB(2) = (thisBB(2)/scalingFactor);  % top start
    thisBB(3) = (thisBB(3)/scalingFactor);  % width
    thisBB(4) = (thisBB(4)/scalingFactor);  % height

    
    figure(1);
    targetImage = imcrop(Iorig, thisBB);
    imshow(targetImage);
    
% Testing to ensure centriod is in correct location
%     imshow(Iorig);
%     hold on
%     plot(targetCentroidX,targetCentroidY, 'x');
end

end