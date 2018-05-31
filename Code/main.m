% Main Script for "Audio Signal Zoom for Small Microphone Arrays"
% By Chi Hang Leung (chl214), Supervised by Dr. Patrick Naylor, 2017/18

close all
clearvars

%Choose the input database for sources of anechoic speech
numSrc = 2;
numRec = 2;
userInput = false;
absorptionC = 'default'; %'default'/number in range of (0,1]
srcFilePath = ["../Data/IEEE sentences/male/16kHz/ieee02m01.dbl"; "../Data/IEEE sentences/female/16kHz/ieee01f08.dbl"] ;
srcType = ["malespeech"; "femalespeech"];
srcFileInd = [11; 8];
if userInput == true
    for src = 1:numSrc
        [srcFileInd(src,:),srcFilePath(src,:), srcType(src,:)] = AudioInput(src);
    end
end

%Choose the test cases to implement
testCase = 2;
roomSize = 'Large';        

%Choose which figures to be displayed
pltImpRes = false;
pltImpResParams = struct('Receiver',[],'Source',[]);
plt3D = true;
pltT30 = true;
pltSchCur = false;

%Specify the parameters for STFT Analysis
OV=2;                                     % overlap factor of 2 (4 is also often used)
INC=256;                                 % set frame increment in samples
N_window=INC*OV;                          % DFT window length
if OV==2
    W=sqrt(hamming(N_window,'periodic')); % OV=2
elseif OV==4
    W=hamming(N_window,'periodic');       % OV=4
end
W=W/sqrt(sum(W(1:INC:N_window).^2));      % normalize window

%Choose which method to implement:
%1. naive
%2. FCM
%3. wFCM
%4. wcFCM
method = 'cluster';
clusterMethod = 'wfcm';

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
[Receivers,Sources,Room]=SetupSim(testCase,roomSize,srcType,absorptionC);

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

%Plot the Reverberation time of the first receiver and first source
[T30,~] = ReverberationTime(cell2mat(RIR_orig(1,1)),fs_room,'oct',pltT30,pltSchCur);

%% Filter the RIR with source samples to generate .wav outputs
%Obtain the source samples
x=cellfun(@DBLRead, srcFilePath,'UniformOutput',false);
[x(1),x(2)]=cellfun(@(x,y) TrimSignals(x,y,tsim*fs_output),x(1),x(2),'UniformOutput',false);

% Plot Sources' Spectrogram
figure('pos',[150 300 900 300]);
tmp=cellfun(@(S) rfft(enframe(S,W,INC),N_window,2),x,'UniformOutput',false);      % do STFT: one row per time frame, +ve frequencies only
t = (1:size(tmp{1},1))/fs_output*INC;
f = (0:size(tmp{1},2)-1)/(size(tmp{1},2)-1)*fs_output/2;
for i = 1:numSrc
   subplot(1,numSrc,i);
   PlotSpectrogram(tmp{i}.*conj(tmp{i}),f,t,['Spectrogram of Source ' num2str(i)],[-30 40]); 
end

%Convolve(Filter) them with the Room Impulse Response
y_sep=cellfun(@(h,x) filter(h,1,x),RIR_deci,repmat(x',2,1),'UniformOutput',false);

%Plot Spectrogram to show the effect of reverberation
% Break the signal down into frames and do STFT analysis
F_sep=cellfun(@(S) rfft(enframe(S,W,INC),N_window,2),y_sep(1,:),'UniformOutput',false);      % do STFT: one row per time frame, +ve frequencies only
% Spectrogram of Received Signal
figure('pos',[150 300 900 300]);
for i = 1:numRec
    subplot(1,numSrc,i);
    PlotSpectrogram(F_sep{i}.*conj(F_sep{i}),f,t,['Effect of Reverberation: Source ' num2str(i)],[-30 40]);
end


%Lastly sum all the sources w.r.t each receiver
y_rec=cellfun(@(i,j) i+j,y_sep(:,1),y_sep(:,2),'UniformOutput',false);

%% Start Processing by breaking down the received signal into TF bins
% Break the signal down into frames and do STFT analysis
F=cellfun(@(S) rfft(enframe(S,W,INC),N_window,2),y_rec,'UniformOutput',false);      % do STFT: one row per time frame, +ve frequencies only

% Spectrogram of Received Signal
figure('pos',[150 300 900 300]);
for i = 1:numRec
    subplot(1,numSrc,i);
    PlotSpectrogram(F{i}.*conj(F{i}),f,t,['Spectrogram of Receiver ' num2str(i)],[-30 40]);
end

%% Choose Processing Algorithm 
% Find the Direction of Arrival
User_DOA = [Sources(1).Location - Receivers(1).Location; Sources(2).Location - Receivers(1).Location];
User_DOA = 90-atan2d(User_DOA(:,2),User_DOA(:,1));

switch lower(method)
    case 'cluster'
        F_output = PhaseClustering(F,clusterMethod,Receivers,numSrc,fs_output,INC);
end

%% Recover the Signal using Inverse FFT and Overlap-add method
% Overlap-add to recover each of the output signal
y=cellfun(@(F) overlapadd(irfft(F,N_window,2),W,INC),F_output,'UniformOutput',false);  % reconstitute the time waveform

% Spectrogram of Processed Signal
figure('pos',[150 300 900 300]);
t = (1:size(F_output{1},1))/fs_output*INC;
f = (0:size(F_output{1},2)-1)/(size(F_output{1},2)-1)*fs_output/2;
for i = 1:numSrc
    subplot(1,numSrc,i);
    PlotSpectrogram(F_output{i}.*conj(F_output{i}),f,t,['Spectrogram of Recovered Source ' num2str(i)],[-30 40]);
end

%% Play the Signals 
%First Source (Male)
pause();
sound(x{1},fs_output)
%Second Source (Female)
pause();
sound(x{2},fs_output)
%Mixed Source
pause();
sound(y_rec{1},fs_output)
%Zoomed First Source (Male)
pause();
sound(y{1},fs_output)
%Zoomed Second Source (Female)
pause();
sound(y{2},fs_output)

%% Evaluation Metrics
pesq_score_nozoom = pesq_mex_fast_vec(x{1},y_rec{1}, fs_output, 'narrowband')
pesq_score = pesq_mex_fast_vec(x{1},y{1}, fs_output, 'narrowband')


%% Output all results and records to the outputFolder
OutputResult(outputFilePath,fs_output,srcFilePath,srcFileInd,srcType,DRR,testCase,x,y_rec,y);
