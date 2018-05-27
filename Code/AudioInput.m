function [fileInd,filePath, srcType] = AudioInput(src)
dataPath='../Data/';
dirList = ls(dataPath);
disp(dirList);
%Locate the Database for User input
while size(dirList,1) > 1
    dir = input(['Please choose from above a database for Source ' ...
        num2str(src) ': '],'s');
    dirList = ls([dataPath '*' dir '*']);
    disp(dirList);
end
if size(dirList,1) ==0
    error('Database not found');
else
    disp(['Selected Database Directory is: ' dirList]);
end

%Select the gender
gender = input('Please choose the gender (male/female): ','s');
dir = [dataPath dirList '/' gender '/16kHz/*.dbl'];
if isempty(ls(dir))
    error('Invalid gender input/The database does not support the gender')
elseif strcmpi(gender,'male')     %Set the directivity
    srcType = "malespeech";
elseif strcmpi(gender,'female')
    srcType = "femalespeech";
end

fileList = ls(dir);
fileInd = input(['Please choose a file from 1 to ' ...
    num2str(size(fileList,1)) ': ']);
filePath = string([dataPath dirList '/' gender '/16kHz/' fileList(fileInd,:)]);
disp(['File Selected for Source ' num2str(src) ':']);
disp(filePath);
disp(newline);
end