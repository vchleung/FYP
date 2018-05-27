%Inputs: two row/column signals with different durations
%Outputs: trimmed signals of same length
function [y1,y2] = TrimSignals(x1,x2,nsample)
%check if both input are vectors
if size(x1,1)~=1 && size(x1,2)~=1 && size(x2,1)~=1 &&size(x2,2)~=1
    Error('One or more Inputs are not vectors')
end
%make both row vector
[~,x1dim] = max([size(x1,1),size(x1,2)]);
[~,x2dim] = max([size(x2,1),size(x2,2)]);
if x1dim(1) == 1
    x1=x1';
end
if x2dim(1) == 1
    x2=x2';
end

minLen=min(min(size(x1,2),size(x2,2)),nsample);
%trimming the longer signal
y1 = x1(1:minLen);
y2 = x2(1:minLen);
end