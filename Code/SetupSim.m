function [Receivers,Sources,Room]=SetupSim(testcase,roomSize,srcType,reverberation)

recSeparation = 0.02;

switch lower(roomSize)
    case 'small'
        roomDim = [3 4 3];
    case 'medium'
        roomDim = [6 8 3];
    case 'large'
        roomDim = [9 12 3];
    otherwise
        error('Invalid Room Size');
end

switch testcase
    case 1
        %receiver (microphone) properties
        recLoc = [0.5*(roomDim(1)-recSeparation) 0.3*roomDim(2) 1.6 ;...
            0.5*(roomDim(1)+recSeparation) 0.3*roomDim(2) 1.6];    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
        recOrientation = [0 0 0; 0 0 0];      % Microphone orientation (rad)
        recType = ["omnidirectional"; "omnidirectional"];  % Type of microphone
        
        %source properties
        srcLoc = [0.5*roomDim(1)-1 0.3*roomDim(2)+1 1.6; ...
            0.8*roomDim(1) 0.8*roomDim(2) 1.6];              % Source position [x y z] (m)
        srcOrientation = [-45 0 0;0 0 0];      % Source orientation (rad)
    case 2
        %receiver (microphone) properties
        recLoc = [0.5*(roomDim(1)-recSeparation) 0.3*roomDim(2) 1.6 ; ...
            0.5*(roomDim(1)+recSeparation) 0.3*roomDim(2) 1.6];    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
        recOrientation = [0 0 0; 0 0 0];      % Microphone orientation (rad)
        recType = ["omnidirectional"; "omnidirectional"];  % Type of microphone
        
        %source properties
        srcLoc = [0.25*roomDim(1) 0.3*roomDim(2)+0.25*roomDim(1) 1.6;...
            0.75*roomDim(1) 0.3*roomDim(2)+0.25*roomDim(1) 1.6];              % Source position [x y z] (m)
        srcOrientation = [-45 0 0;-135 0 0];      % Source orientation (rad)
    case 3
        %receiver (microphone) properties
        recLoc = [(roomDim(1)-recSeparation)/2 0.3*roomDim(2) 1.6 ;...
            (roomDim(1)+recSeparation)/2 0.3*roomDim(2) 1.6];    % Receiver positions [x_1 y_1 z_1 ; x_2 y_2 z_2] (m)
        recOrientation = [0 0 0; 0 0 0];      % Microphone orientation (rad)
        recType = ["omnidirectional"; "omnidirectional"];  % Type of microphone
        
        %source properties
        srcLoc = [0.375*roomDim(1) 0.3*roomDim(2)+0.375*roomDim(1) 1.6;...
            0.625*roomDim(1) 0.3*roomDim(2)+0.375*roomDim(1) 1.6];               % Source position [x y z] (m)
        srcOrientation = [-90 0 0;-90 0 0];      % Source orientation (rad)
    otherwise 
        error('Invalid Test Case');
end

%find the number of receivers and sources
numReceivers = size(recLoc, 1);
numSources = size(srcLoc, 1);

%Add all receivers into the system
Receivers = [];
for i = 1:numReceivers
    Receivers = AddReceiver(Receivers,'Type',       char(recType(i)),     ...
                                    'Location',     recLoc(i,:),    ...
                                    'Orientation',  recOrientation(i,:) ...
                           );
end

%Add all sources into the system
Sources = [];
for i = 1:numSources
    Sources = AddSource(Sources,'Type',     char(srcType(i)),     ...
                                'Location',     srcLoc(i,:),    ...
                                'Orientation',  srcOrientation(i,:) ...
                           );
end

%Set up the Room with Specified Revereberation
if strcmpi(reverberation,'default')
   Room = SetupRoom('Dim',roomDim);
elseif isnumeric(reverberation)
   Room = SetupRoom('Dim',roomDim,'Absorption',ones(6,6).*reverberation); 
else
   error('Invalid Reverberation Input');
end