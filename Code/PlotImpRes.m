function PlotImpRes(outputFilePath, plotImpResParams, RIR, fsamp)

%plot the impulse response (choosing the receiver and source)
numReceivers = size(RIR,1);
numSources = size(RIR,2);

%if empty array, plot all available receivers
if isempty(plotImpResParams.Receiver)
    plotImpResParams.Receiver = 1:numReceivers;
elseif nnz(plotImpResParams.Receiver>numReceivers)~=0 %warn user if input receiver is not in range
    warning('Input exceeds number of receivers (Plotting Impulse Response)')
    plotImpResParams.Receiver= plotImpResParams.Receiver(plotImpResParams.Receiver<=numReceivers);
end
%if empty array, plot all available sources
if isempty(plotImpResParams.Source)
    plotImpResParams.Source = 1:numSources;
elseif nnz(plotImpResParams.Source>numSources)~=0 %warn user if input source is not in range
    warning('Input exceeds number of sources (Plotting Impulse Response)')
    plotImpResParams.Source= plotImpResParams.Source(plotImpResParams.Source<=numSources);
end
%Plot the impulse response for each receiver-source pair
count = 1;
figure;
for i = plotImpResParams.Receiver
    for j = plotImpResParams.Source
        t = 0:1/fsamp:(length(cell2mat(RIR(i,j)))-1)/fsamp;
        subplot(numReceivers,numSources,count);
        cellfun(@(x) plot(t,x),RIR(i,j));
        title(sprintf('RIR of Source %d at Receiver %d', j, i))
        xlabel('Time (s)');
        ylabel('Amplitude');
        count = count + 1;
    end
end

%Save the Figure
fig = gcf;
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 640 480];
export_fig([outputFilePath,'ir'],'-png','-eps','-p0.05','-transparent');
end