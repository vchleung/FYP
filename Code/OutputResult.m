%The fuction stores the generated result to /Results
function OutputResult(outputFilePath,Fs,srcFilePath,srcFileInd,srcType,DRR,testcase,x,y_rec,y)

%Output the Original Source Signals in .wav files
for i = 1:size(x,1)
    fileName = ['src' num2str(i) '.wav'];
    audiowrite([outputFilePath,fileName],cell2mat(x(i)),Fs);
end

%Output the Received Signals in .wav files
for j = 1:size(y_rec,1)
    fileName = ['rec' num2str(j) '.wav'];
    audiowrite([outputFilePath,fileName],cell2mat(y_rec(j)),Fs);
end

%Output the Zoomed Signals in .wav files
for j = 1:size(y,1)
    fileName = ['zoomed' num2str(j) '.wav'];
    audiowrite([outputFilePath,fileName],cell2mat(y(j)),Fs);
end

%Output the Relevent Information to a text file
fileID = fopen([outputFilePath,'resultinfo.txt'],'w');
fprintf(fileID,'Test Case %d \r\n\r\n',testcase);
fprintf(fileID,'%25s %60s %60s \r\n',['Fs=',num2str(Fs)],'Source 1', 'Source 2');
fprintf(fileID,'%25s %60s %60s \r\n','Directivity(Gender)',srcType(1), srcType(2));
fprintf(fileID,'%25s %60d %60d \r\n','Index',srcFileInd(1), srcFileInd(2));
fprintf(fileID,'%25s %60s %60s \r\n','File',srcFilePath(1), srcFilePath(2));
fprintf(fileID,'%25s %60.2f %60.2f \r\n','DRR(dB)',mean(DRR(:,1)), mean(DRR(:,2)));
fclose(fileID);

end