% Main Script for "Audio Signal Zoom for Small Microphone Arrays"
% By Chi Hang Leung (chl214), Supervised by Dr. Patrick Naylor, 2017/18

close all
clearvars

%Choose the input database for sources of anechoic speech
numSrc = 2;
numRec = 2;
userSelect = false;
srcFilePath = ["../Data/IEEE sentences/male/16kHz/ieee25m01.dbl"; "../Data/IEEE sentences/male/16kHz/ieee66m03.dbl" ] ;
srcType = ["malespeech"; "malespeech"];
srcFileInd = [241; 653];
if userSelect == true
    for src = 1:numSrc
        [srcFileInd(src,:),srcFilePath(src,:), srcType(src,:)] = AudioInput(src);
    end
end

%Choose the test cases to implement
testCase = 2;
roomSize = 'Medium';        

%Choose which figures to be displayed
pltImpRes = true;
pltImpResParams = struct('Receiver',   [], ...
                     'Source',     []);
plt3D = true;
pltT30 = false;
pltSchCur = false;

%% Simulate Room Impulse Response (RIR)
%Define simulation parameters
fs_room = 48000;            % Sample frequency (samples/s) used in MCRoomSim
fs_output = 16000;          % Sample frequency (samples/s) used in Output RIR
tsim = 5;
deciRatio = fs_room/fs_output;
order = [-1, -1, -1];       % -1 equals maximum reflection order!
outputFilePath = ['Results/TestCase' num2str(testCase) '-' roomSize '/']; %Specify the output file path

%Set up MCRoomSim Options
Options = MCRoomSimOptions('Fs',fs_room, ...
                            'Order',order ...
);

%Set up the simulation environment
[Receivers,Sources,Room]=SetupSim(testCase,roomSize,srcType);

%Plot a 3-D map for the display of source and receivers
if plt3D
    PlotSimSetup(Sources,Receivers,Room);
    title(sprintf('Receivers and Sources Location for Test Case %d in %s Room', testCase, regexprep(lower(roomSize),'(\<[a-z])','${upper($1)}')),'Interpreter', 'latex')
    view(2);
    print([outputFilePath,'\3DMap.png'],'-dpng');
end

%Run the Simulation and obtain the Room Impulse Response (RIR_orig)
RIR_orig = RunMCRoomSim(Sources,Receivers,Room,Options);

%Downsample the impulse response from 48kHz to 16kHz
RIR_deci = cellfun(@(x) resample(x,1,deciRatio),RIR_orig,'UniformOutput',false);

%Normalise RIR to increase the audibility
maxEnergyImpRes = max(max(cellfun(@norm,RIR_deci))); %Find the maximum energy amongst all the RIRs
RIR_deci = cellfun(@(x) x/maxEnergyImpRes,RIR_deci,'UniformOutput',false);

%Plot the impulse response as specified by users
if pltImpRes
    PlotImpRes(outputFilePath, pltImpResParams, RIR_deci, fs_output);
end

%Find the Direct-to-Reverberant Ratio (DRR) of the impulse response
%The longer the distance between source and receiver, the lower the DRR
[DRR,~] = cellfun(@(h) EstDRR(h, fs_output),RIR_deci);

%Plot the Reverberation time of the first receiver
[T30,~] = ReverberationTime(cell2mat(RIR_orig(1,:)),fs_room,'oct',pltT30,pltSchCur);

%% Filter the RIR with source samples to generate .wav outputs
%Obtain the output samples after filtering with RIR
%Obtain the source samples
x=cellfun(@DBLRead, srcFilePath,'UniformOutput',false);
[x(1),x(2)]=cellfun(@(x,y) TrimSignals(x,y,tsim*fs_output),x(1),x(2),'UniformOutput',false);

%Convolve(Filter) them with the Room Impulse Response
y_sep=cellfun(@(h,x) filter(h,1,x),RIR_deci,repmat(x',2,1),'UniformOutput',false);

%Lastly sum all the sources w.r.t each receiver
y_rec=cellfun(@(i,j) i+j,y_sep(:,1),y_sep(:,2),'UniformOutput',false);

%Output all results and records to the outputFolder
OutputResult(outputFilePath,fs_output,srcFilePath,srcFileInd,srcType,DRR,testCase,x,y_rec);
