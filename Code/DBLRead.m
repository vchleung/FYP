function  [signal, len]=DBLRead(name, lenr)
%function  [signal, len]=DBLRead(name, lenr);
% 
% reads a signal vector from a 64-bits DBL file
%
% where: 
%  signal = signal vector
%  len    = actual # of samples read
%  name   = filename
%  lenr   = requested # of samples (defaul: EOF)
if nargin < 2
  lenr = inf;
end
fid  = fopen(name);
if (fid>0)
  [signal, len] = fread(fid,[1, lenr],'double');  % 
  fclose(fid);
else
  signal = 0;
  len    = 0;
end
%By Pete D. Best 05/27/08
