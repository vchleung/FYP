clear all 
% define functionality of the code
plotImpRes = -1; % -1 = no plot, 0 = plot all, 1 onwards = specify receiver microphone

% define constants
c = 340;                    % Sound velocity (m/s)
fsamp = 16000;                 % Sample frequency (samples/s)
receiverPos = [2 1.5 1.5 ; 2 1.65 1.5];    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
sourcePos = [5 5 1.8];              % Source position [x y z] (m)
roomDim = [10 10 10];                % Room dimensions [x y z] (m)
numReceiver = size(receiverPos, 1);
numSource = size(sourcePos, 1);
beta = 1.5;                 % Reverberation time (s)
n = 4096;                   % Number of samples
mtype = 'cardioid';  % Type of microphone
order = -1;                 % -1 equals maximum reflection order!
dim = 3;                    % Room dimension
orientation = [180 0;180 0];            % Microphone orientation (rad)
hp_filter = 1;              % Enable high-pass filter

h = rirGenerator(c, fsamp, receiverPos, sourcePos, roomDim, beta, n, mtype, order, dim, orientation, hp_filter);

%plot the impulse response (choosing the receiver and source)
if plotImpRes~=-1
    if plotImpRes==0
        plotReceiver = 1:numReceiver;
    else
        plotReceiver = plotImpRes;
    end
    for i = 1:numSource
        for j = plotReceiver
            figure;
            plot(squeeze(h(j,1,:)));
        end
    end
end

plotSimMap(receiverPos, sourcePos, roomDim, mtype, orientation);