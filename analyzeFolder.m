clc;

% Put file path here =================
path = 'I:\Homework\Senior Design\Image Processing\camera test images\High Altitude Picture';
outputFolderName = 'Targets';
% ====================================

textfileName = strcat(path,'\', outputFolderName,'\SIT.txt');
pictureDir = dir(path); % lists all the items in the path
numFiles = size(pictureDir,1); % counts the number of items in the path
outputFolder = 0;
index = 0;


for x = 1:numFiles % go through list of items
    if((pictureDir(x).isdir == 0) && strcmp(pictureDir(x).name(end-3:end), ...
            '.jpg')) % check if it is a picture
        if(outputFolder == 0) 
            mkdir(path, outputFolderName)     % make folder for target imgs
            fileID = fopen(textfileName,'w'); % create text file
            fclose(fileID);                   % close text file

            outputFolder = 1; % sets flag indicating folder has been created
        end
        
        [targetFound, outLatitude, outLongitude, targetType, outOrientation, ...
            outShape, outTargetColor, outLetter, outLetterColor, amplifyingText] = ...
            imageProcessing(path, pictureDir(x).name); % process the image
 
        outFilename = pictureDir(x).name;
        
        if(targetFound == 1) % update text file
            fileID = fopen(textfileName,'a'); % open & add to the txt file
            index = index + 1;
            
            if(index == 1)
                indexSTR = strcat('0',int2str(index));
                fprintf(fileID, strcat(indexSTR,'\t',targetType,'\t',...
                    outLatitude,'\t',outLongitude,'\t',outOrientation,...
                    '\t',outShape,'\t', outTargetColor,'\t',outLetter,...
                    '\t',outLetterColor,'\t',outFilename,'\t',amplifyingText));
            elseif(index < 10)
                indexSTR = strcat('0',int2str(index));
                fprintf(fileID, strcat('\r\n',indexSTR,'\t',targetType,...
                    '\t',outLatitude,'\t',outLongitude,'\t',...
                    outOrientation,'\t',outShape,'\t',outTargetColor,...
                    '\t',outLetter,'\t',outLetterColor,'\t',outFilename,'\t',amplifyingText));
                    % \r\n for notepad, just \n for other programs to start new line
            else
                indexSTR = int2str(index);
                fprintf(fileID, strcat('\r\n',indexSTR,'\t',targetType,...
                    '\t',outLatitude,'\t',outLongitude,'\t',...
                    outOrientation,'\t',outShape,'\t',outTargetColor,...
                    '\t',outLetter,'\t',outLetterColor,'\t',outFilename,'\t',amplifyingText));
                    % \r\n for notepad, just \n for other programs to start new line
            end
            
            fclose(fileID);                   % close text file
        end
    end
end