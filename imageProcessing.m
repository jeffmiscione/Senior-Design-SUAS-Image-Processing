function [targetFound, outLatitude, outLongitude, targetType, outOrientation, ...
    outShape, outTargetColor, outLetter, outLetterColor, ampifyingText] = ...
    imageProcessing(path, filename)

%% Import Image
% The Mission Planner has a feature that will inject GPS data into...
% your photos’ EXIF tags by using APM’s TELEMETRY LOG from a flight
SUASImage = imread(strcat(path, '\', filename));

%% Send to Mike's code
[targetFound, targetImage, targetCentroidX, targetCentroidY] = findTarget(SUASImage);

%% Was there a target?
if (targetFound == 1)
    %% Import EXIF data
    SUASImageInfo = imfinfo(strcat(path, '\', filename));
    
    %% Altitude Data
    altitude = SUASImageInfo.GPSInfo.GPSAltitude;
    
    %% Image size and center points
    [height, width, ~] = size(SUASImage);
    Xcenter = width/2;
    Ycenter = height/2;

    %% Latitude (Y axis) and Longitude (X Axis) Data
    LATRef = SUASImageInfo.GPSInfo.GPSLatitudeRef;
    LATdegrees = SUASImageInfo.GPSInfo.GPSLatitude(1);
    LATminutes = SUASImageInfo.GPSInfo.GPSLatitude(2);
    LATseconds = SUASImageInfo.GPSInfo.GPSLatitude(3);
    
    LONRef = SUASImageInfo.GPSInfo.GPSLongitudeRef;
    LONdegrees = SUASImageInfo.GPSInfo.GPSLongitude(1);
    LONminutes = SUASImageInfo.GPSInfo.GPSLongitude(2);
    LONseconds = SUASImageInfo.GPSInfo.GPSLongitude(3);
    
    %% ACCOUNT FOR THE ROTATION HERE
    heading = SUASImageInfo.GPSInfo.GPSImgDirection;
    % heading is measured 0 to 360 starting at 12 o'clock and going clockwise

    XtargetConvert = targetCentroidX - Xcenter; % value as if center of image is (0,0)
    YtargetConvert = Ycenter - targetCentroidY; % value as if center of image is (0,0)
    radius = sqrt((XtargetConvert^2) + (YtargetConvert^2));

    angleFromHorizontal = rad2deg(atan2(YtargetConvert,XtargetConvert));
    angleFromVertical = 90 - angleFromHorizontal;
    if angleFromVertical < 0
       % indicates where the centroid is measured from 0 to 360 starting from 12 o'clock
        angleFromVertical = 360 + angleFromVertical; 
    end

    targetAngleFromNorth = mod(angleFromVertical + heading,360);

    targetCentroidX = Xcenter + (radius * sind(targetAngleFromNorth));
    targetCentroidY = Ycenter - (radius * cosd(targetAngleFromNorth));

    %% Localization
    % for the location we will be competing in, going left raises the
    % longitude (measured as W) and going up raises the latitude (measured as N)

    % targetCentroid is measured from top left where right is positive X
    % and down is positive Y

    % for latitude lines = 0.009878 seconds/foot
    % for longitude lines = 0.012518 seconds/foot

    feetPerPixel = 2*altitude*tan(deg2rad(22.5))/width; % determine feet/pixel

    LATFeetOffset = feetPerPixel*(Ycenter - (targetCentroidY)); % in feet
    LATSecondOffset = (0.009878)*LATFeetOffset; % value in seconds
    LATSecondTarget = LATseconds + LATSecondOffset;

    if(LATSecondTarget >= 60)           %if seconds are greater than 60
        LATSecondTarget = LATSecondTarget - 60;
        LATMinuteTarget = LATminutes + 1;
    elseif (LATSecondTarget < 0)        %if seconds are less than 0
        LATSecondTarget = LATSecondTarget + 60;
        LATMinuteTarget = LATminutes - 1;
    else                                %if between 0 and 60
        LATMinuteTarget = LATminutes;
    end

    if(LATMinuteTarget >= 60)
        LATMinuteTarget = LATMinuteTarget - 60;
        LATDegreesTarget = LATdegrees + 1;
    elseif(LATMinuteTarget < 0)
        LATMinuteTarget = LATMinuteTarget + 60;
        LATDegreesTarget = LATdegrees - 1;
    else
        LATDegreesTarget = LATdegrees;
    end

    outLatitude = [LATRef sprintf('%02i',LATDegreesTarget) ' ' ...
        sprintf('%02i',LATMinuteTarget) ' ' ...
        sprintf('%06.3f',LATSecondTarget)];

    LONFeetOffset = feetPerPixel*(Xcenter - (targetCentroidX)); %  in feet
    LONSecondOffset = (0.012518)*LONFeetOffset; % value in seconds
    LONSecondTarget = LONseconds + LONSecondOffset;

    if(LONSecondTarget >= 60)           %if seconds are greater than 60
        LONSecondTarget = LONSecondTarget - 60;
        LONMinuteTarget = LONminutes + 1;
    elseif (LONSecondTarget < 0)        %if seconds are less than 0
        LONSecondTarget = LONSecondTarget + 60;
        LONMinuteTarget = LONminutes - 1;
    else                                %if between 0 and 60
        LONMinuteTarget = LONminutes;
    end

    if(LONMinuteTarget >= 60)
        LONMinuteTarget = LONMinuteTarget - 60;
        LONDegreesTarget = LONdegrees + 1;
    elseif(LONMinuteTarget < 0)
        LONMinuteTarget = LONMinuteTarget + 60;
        LONDegreesTarget = LONdegrees - 1;
    else
        LONDegreesTarget = LONdegrees;
    end

    outLongitude = [LONRef sprintf('%03i',LONDegreesTarget) ' ' ...
        sprintf('%02i',LONMinuteTarget) ' ' ...
        sprintf('%06.3f',LONSecondTarget)];
    %% Color Detection
    [outTargetColor, outLetterColor] = determineColors(targetImage);
    
    %% Fill in Missing Data
    ampifyingText = '-';            % any other info
    targetType = 'STD';             % this will not change for 2015 competition
    outOrientation = 'Orientation'; % mike
    outShape = 'Shape';             % mike
    outLetter = 'Letter';           % mike
    
else % send back these values if target not found
    outLatitude = 0;
    outLongitude = 0;
    targetType = 0;
    outOrientation = 0;
    outShape = 0;
    outTargetColor = 0;
    outLetter = 0;
    outLetterColor = 0;
    ampifyingText = 0;
end