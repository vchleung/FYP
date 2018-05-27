function [ DRR, extras ] = EstDRR(h, fs, inParams)
%   Description: Estimate DRR in dB from source-equalised RIR.
%
%   Inputs:
%       A single or multi-channel RIR in the form h(samples,channels)
%   Outputs
%       Returns a vector of DRRs in dB, one scalar for each channel
%
%   If no parameters are specified, no EQ is applied and the default
%   parameters are applied for the width of the direct path.
%
%   Assumptions
%    -  the energy of the direct path is contained in a +/- 0.008s
%       interval around the location of the direct path [1,2]
%   -   That the location of the direct path is the largest peak in the 
%       EQed or un-EQed RIR
%   -   input vector is a l x c vector where c is the number of channels
%   
%   For the ACE challenge, the pre EQ used was preEQ_415_1.wav which can be
%   found on 
%   https://wiki.imperial.ac.uk/display/sap/Fostex+6301B+Personal+Monitor
%
%   [1] P. A. Naylor and N. D. Gaubitch, Eds., Speech Dereverberation. 
%       Springer, 2010.
%   [2] S. Mosayyebpour, H. Sheikhzadeh, T. Gulliver, and M. Esmaeili,
%       "Single-microphone LP residual skewness-based inverse
%       filtering of the room impulse response", IEEE Trans.
%       Audio, Speech, Lang. Process., vol. 20, no. 5, pp. 1617?1632,
%       July 2012.
%
%   Revision history
%   ================
%   Date        ID      Description
%   20160128    dje11   Created from ACE codebase

% CONSTANTS

% Use +/- 8 ms either side of the peak
DIR_PLUS                                    = 0.008;
DIR_MINUS                                   = 0.008;

% No default equalisation is provided
H_PRE_EQ                                    = [];

% FUNCTION LOGIC

% If no input parameters specified, default parameters
defParams.dirPlus                           = DIR_PLUS;
defParams.dirMinus                          = DIR_MINUS;
defParams.hPreEQ                            = H_PRE_EQ;
params                                      = defParams;
if nargin == 3 && ~isempty(inParams)
    inParamNames                            = fieldnames(inParams);
    for i = 1:length(inParamNames)
        params.(inParamNames{i})            = inParams.(inParamNames{i});
    end
end

if isempty(params.hPreEQ)
    warning('No pre-EQ provided.  Assumption that direct path is the largest peak is not reliable');
end

% Return the actual values used for later verification
extras.dirPlus                              = params.dirPlus;
extras.dirMinus                             = params.dirMinus;

% Determine the DRR for each channel of the RIR
[hLen, nChannels]                           = size(h);
DRR                                         = zeros(nChannels,1);
for chanInd = 1:nChannels
    
    % If a filter is specified, EQ the RIR individually by channel
    if isempty(params.hPreEQ)
        hEQed                        = h(:,chanInd);
    else
        %filter zeropadded version to keep tail
        hEQed                        = fftfilt(params.hPreEQ,[h(:,chanInd);zeros(length(params.hPreEQ)-1,1)]); 
    end

    % Find the maximum of the filtered or unfiltered RIR, which is assumed
    % to be the location of the direct path
    maxInd                           = find(hEQed == max(hEQed));

    % Determine the direct path location:
    
    % Find the starting index
    dirStartInd                      = maxInd - params.dirMinus * fs;
    if dirStartInd < 1
        dirStartInd                  = 1;
        fprintf(sprintf('Warning, dirStartInd, %d set to start of RIR\n',dirStartInd));
    end
    
    % Find the 
    dirEndInd                        = maxInd + params.dirPlus * fs;
    if dirEndInd > hLen
        dirEndInd                    = hLen;
        fprintf(sprintf('Warning, dirEndInd, %d set to length of RIR\n', dirEndInd));
    end

    % Obtain the direct path from the RIR using the indices determined
    % above
    hDirect                          = h(dirStartInd:dirEndInd, chanInd);

    % Obtain the indirect path from the RIR by setting the direct path
    % component to zero.
    hReverb                          = h(:,chanInd);
    hReverb(dirStartInd:dirEndInd)   = zeros(size(hDirect));

    % Compute the DRR
    DRR(chanInd)                     = 10*log10((sum(hDirect.^2)/sum(hReverb.^2)));


end %for chanInd etc

end %function