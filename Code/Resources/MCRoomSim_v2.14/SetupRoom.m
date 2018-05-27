function Room = SetupRoom(varargin)
%
%
% Room = SetupRoom('FieldName',FieldValue,...)
% Room = SetupRoom('RoomType')
% Room = SetupRoom
%    
% Generate a room configuration structure for MCRoomSim.
%
% If RoomType is passed in then a setup for a pre-configured room type is 
% generated. Choices are:
%       - MediumRoom
%       - ConcertHall
%       - Cathedral
%
% Room = SetupRoom is  
%
% DESCRIPTION:
% MCRoomSim requires a number of parameters specifying the physical 
% charateristics of the simulated room. These characteristics are passed 
% in a structure with the following fields:
% 
% |----------|---------------------------------------|--------------------|
% |  Field   |               Field                   |      Field         |
% |   Name   |            Description                |      Values        |
% |          |                                       |     {DefaultValue} |
% |----------|---------------------------------------|--------------------|
% |   Dim    | Room dimensions in metres [X,Y,Z]     | 3-element array of |
% |          |                                       | real-positive      |
% |          | 	                                     | numbers            |
% |          |                                       |        {[14,10,3]} |
% |----------|---------------------------------------|--------------------|
% | Humidity | Relative humidity of room             | Any real-positive  |
% |          | 	                                     | number in range    |
% |          | 	                                     | (0,1)              |
% |          |                                       |             {0.42} |
% |----------|---------------------------------------|--------------------|
% |  Temp    | Room temperature (Celsius)            | Any real number    |
% |          | (see remarks below)                   |               {20} |
% |----------|---------------------------------------|--------------------|
% |  Freq    | Frequencies at which absorption and   | Array of real-     |
% |          | diffusion coefficients are specified  | positive numbers   |
% |          | (Hz)                                  | {[ 125, 250, 500,  |
% |          | (see remarks below)                   |   1000,2000,4000]} |
% |----------|---------------------------------------|--------------------|
% |Absorption| Wall absorption coeffients as a       | 2D matrix of real- |
% |          | function of frequency with 0=purely   | positive values in |
% |          | reflective, 1=purely absorbing        | range (0,1)        |
% |          | (see remarks below)                   | {Characteristic of |
% |          |                                       |     a medium room} |
% |----------|---------------------------------------|--------------------|
% |Scattering| Wall Scattering coeffients as a       | 2D matrix of real- |
% |          | function of frequency with 0=purely   | positive values in |
% |          | specular wall reflections, 1=purely   | range (0,1)        |
% |          | diffuse reflections                   | {Characteristic of |
% |          | (see remarks below)                   |     a medium room} |
% |----------|---------------------------------------|--------------------|
%
% SetupRoom generates this structure given some field values.
%
% REMARKS:
% - ('FieldName',FieldValue) pairs can be passed in any order.
% - Temp:
%   The value set for temperature influences the speed of sound in the room
%   but is ignored by MCRoomSim when the speed of sound is specified in the 
%   simulation options structure.
% - Freq:
%   The values for frequencies must be in increasing order and non-
%   redundant. The length of the frequency array must match the number of
%   columns in the absorption/scattering coefficient matrices.
% - Absorption:
%   Each row of the absorption coefficient matrix represents one of 6 walls
%   in the room in the order [X0;X1;Y0;Y1;Z0;Z1] (see room coordinate
%   system below). Each column specifies absorption coefficients at the
%   frequency with matching array index in the Freq vector. There must be
%   6 rows and the number of columns must match the number of frequencies
%   specified in Freq vector.
% - Scattering:
%   Each row of the scattering coefficient matrix represents one of 6 walls
%   in the room in the order [X0;X1;Y0;Y1;Z0;Z1] (see room coordinate
%   system below). Each column specifies scattering coefficients at the
%   frequency with matching array index in the Freq vector. There must be
%   6 rows and the number of columns must match the number of frequencies
%   specified in Freq vector.
% - Room coordinate system:
%   (Right Hand Coordinate System)
%   
%                       X
%             X1        ^
%        _______________|
%       |               |           * Z axis increases upwards from origin
%       |               |           * Z0 (floor)   
%       |               |           * Z1 (ceiling)
%    Y1 |               | Y0
%       |               | 
%       |               |
%       |               |
%    Y<-----------------0
%             X0
%
% EXAMPLES:
% - Describe a room with dimensions X=4,Y=3,Z=10 and default absorption/
%   scattering coefficients:
%   Room = SetupRoom('Dim',[4,3,10]);
% - Set all scattering coefficients for the room to 0.5:
%   Room = SetupRoom('Scattering',0.5*ones(6,6));
% - Specify absorption/scattering coeffients at 7 frequencies:
%   Room = SetupRoom(   'Freq'      ,[ 100, 200, 400, 800,1600,3200,6400],
%                       'Absorption',[ 0.6, 0.5, 0.4, 0.3, 0.4, 0.5, 0.6;
%                                      0.7, 0.6, 0.6, 0.3, 0.4, 0.6, 0.7;
%                                      0.6, 0.5, 0.4, 0.3, 0.4, 0.5, 0.6;
%                                      0.7, 0.6, 0.6, 0.3, 0.4, 0.6, 0.7;
%                                      0.5, 0.5, 0.5, 0.4, 0.4, 0.5, 0.6;
%                                      0.7, 0.7, 0.6, 0.5, 0.4, 0.6, 0.7],
%                       'Scattering',[ 0.5, 0.5, 0.5, 0.5, 0.6, 0.6, 0.6;
%                                      0.5, 0.5, 0.5, 0.5, 0.6, 0.6, 0.6;
%                                      0.5, 0.5, 0.5, 0.5, 0.6, 0.6, 0.6;
%                                      0.5, 0.5, 0.5, 0.5, 0.6, 0.6, 0.6;
%                                      0.8, 0.8, 0.8, 0.8, 0.8, 0.9, 0.9;
%                                      0.5, 0.5, 0.5, 0.5, 0.6, 0.6, 0.6]);
%
% Copyright 2013, A. Wabnitz and N. Epain
% Last update: 05/09/2013

%--------------------------------------------------------------------------
%   Default Values For Room Settings
%--------------------------------------------------------------------------
Room.Dim         = [ 10 8 3 ];   
Room.Humidity    = 0.42;         
Room.Temp        = 20;   

%--------------------------------------------------------------------------
%    Default Values For Surface Absorption & Diffusion Coefficients
%--------------------------------------------------------------------------
Room.Freq        = [ 125    250     500     1000    2000    4000];
Room.Absorption  = [ 0.30   0.30    0.30    0.30    0.30    0.30;  %X0  
                     0.30   0.30    0.30    0.30    0.30    0.30;  %X1
                   	 0.30   0.30    0.30    0.30    0.30    0.30;  %Y0
                   	 0.30   0.30    0.30    0.30    0.30    0.30;  %Y1
                     0.44   0.42    0.40    0.40    0.40    0.40;  %Z0
                   	 0.45   0.46    0.47    0.48    0.49    0.50]; %Z1
Room.Scattering  = [ 0.80   0.80    0.80    0.80    0.80    0.80;  %X0
                  	 0.80   0.80    0.80    0.80    0.80    0.80;  %X1
                   	 0.80   0.80    0.80    0.80    0.80    0.80;  %Y0
                 	 0.80   0.80    0.80    0.80    0.80    0.80;  %Y1
                  	 0.60   0.60    0.60    0.60    0.60    0.60;  %Z0
                   	 0.60   0.60    0.60    0.60    0.60    0.60]; %Z1

%--------------------------------------------------------------------------
%   Check For Preset Rooms or Correct Number Of Arguments
%--------------------------------------------------------------------------
if nargin == 1
    if strcmp(varargin{1},'MediumRoom')
        % Do nothing, the settings above are that of an office
    elseif strcmp(varargin{1},'ConcertHall')
        Room.Dim  = [ 49 19 18 ];
        Room.Freq =      [  125    250     500     1000    2000    4000];
        Room.Absorption =[  0.16   0.10    0.07    0.05    0.03    0.01;
                        	0.16   0.10    0.07    0.05    0.03    0.01; 
                           	0.16   0.10    0.07    0.05    0.03    0.01; 
                          	0.16   0.10    0.07    0.05    0.03    0.01;   
                           	0.50   0.65    0.75    0.75    0.75    0.75;   
                         	0.16   0.10    0.07    0.05    0.03    0.01];
        Room.Scattering =[  0.90   0.90    0.90    0.90    0.90    0.90;
                          	0.90   0.90    0.90    0.90    0.90    0.90;
                         	0.90   0.90    0.90    0.90    0.90    0.90;
                           	0.90   0.90    0.90    0.90    0.90    0.90;
                          	1.00   1.00    1.00    1.00    1.00    1.00;
                           	0.90   0.90    0.90    0.90    0.90    0.90];
    elseif strcmp(varargin{1},'Cathedral')
        Room.Dim  = [ 80 45 40 ];
        Room.Freq =      [  125    250     500     1000    2000    4000];
        Room.Absorption =[  0.10   0.10    0.10    0.15    0.20    0.25;
                         	0.10   0.10    0.10    0.15    0.20    0.25; 
                           	0.10   0.10    0.10    0.15    0.20    0.25;
                          	0.10   0.10    0.10    0.15    0.20    0.25;   
                          	0.10   0.10    0.10    0.15    0.20    0.25;
                          	0.10   0.10    0.10    0.15    0.20    0.25];
        Room.Scattering =[  0.75   0.75    0.75    0.75    0.75    0.75;
                        	0.75   0.75    0.75    0.75    0.75    0.75;
                        	0.75   0.75    0.75    0.75    0.75    0.75;
                        	0.75   0.75    0.75    0.75    0.75    0.75;
                         	0.75   0.75    0.75    0.75    0.75    0.75;
                            0.75   0.75    0.75    0.75    0.75    0.75];
    else
        error(['Unknown room type: ' varargin{1}]);
    end
elseif round(length(varargin)/2)~=length(varargin)/2
    error('Illegal number of arguments') ;
end

%--------------------------------------------------------------------------
%   Check Field Values And Assign To Room Structure
%--------------------------------------------------------------------------
for I = 1 : 2 : length(varargin)-1
    
    switch varargin{I}
        
        case 'Dim'

            if ~isreal(varargin{I+1})
                error('Room dimensions must be real numbers');
            elseif (min(varargin{I+1})<=0)
                error('Room dimensions must be greater than 0');
            elseif (length(varargin{I+1})<3)
                error('Too few elements supplied to Dim');
            elseif (length(varargin{I+1})>3)
                error('Too many elements supplied to Dim');
            else
                Room.Dim = varargin{I+1};
            end

        case 'Humidity'
            
            if (  (isscalar(varargin{I+1})) ...
               && (isreal(varargin{I+1}))   ...
               && (varargin{I+1}>=0)        ...
               && (varargin{I+1}<=1)        )
                Room.Humidity = varargin{I+1};
            else
                error('Humdity must be a real number between 0 and 1');
            end

        case 'Temp'
            
            if (  (isscalar(varargin{I+1})) ...
               && (isreal(varargin{I+1}))   )
                Room.Temp = varargin{I+1};
            else
                error('Temp must be a real number');
            end
            
        case 'Freq'

            if (size(varargin{I+1},1)>1 && size(varargin{I+1},2)>1)
                error('Frequency values must be a vector');
            elseif (length(varargin{I+1})==1)
                error('More than one frequency needs to be specified');
            elseif min(varargin{I+1})<0
                error('Frequency values cannot be negative');
            elseif ~issorted(varargin{I+1})
                error('Frequency values must be in ascending order');
            elseif ~isreal(varargin{I+1})
                error('Frequency values must be real');
            else
                Room.Freq = varargin{I+1};
            end
            
        case 'Absorption'
            
            if size(varargin{I+1},1) ~= 6
                error(['Absorption coefficient matrix must have ' ...
                       'exactly 6 rows']);
            elseif (  (min(min(varargin{I+1}))<0) ...
                   || (max(max(varargin{I+1}))>1) )
                error('Absorption coefficients must be between 0 and 1');
            elseif ~isreal(varargin{I+1})
                error('Absorption coefficients must be real');
            else
                Room.Absorption = varargin{I+1};
            end

        case 'Scattering'
            
            if size(varargin{I+1},1) ~= 6
                error(['Scattering coefficient matrix must have ' ...
                       'exactly 6 rows']);
            elseif (  (min(min(varargin{I+1}))<0) ...
                   || (max(max(varargin{I+1}))>1) )
                error('Scattering coefficients must be between 0 and 1');
            elseif ~isreal(varargin{I+1})
                error('Scattering coefficients must be real');
            else
                Room.Scattering = varargin{I+1};
            end

        otherwise
            
            error([varargin{I} ' is not a recognised options field']) ;
            
    end
end
    
%--------------------------------------------------------------------------
%   Check Number Of Absorption/Diffusion Columns Match Number Of Freqs
%--------------------------------------------------------------------------
if (length(Room.Freq) ~= size(Room.Absorption,2))
    error(['Mismatch between number of columns in Absorption '...
           'Coefficient matrix and number of frequencies']);
end

if (length(Room.Freq) ~= size(Room.Scattering,2))
    error(['Mismatch between number of columns in Scattering '...
           'Coefficient matrix and number of frequencies']);
end

end