function training_callbacks(varargin)

% TRAINING_CALLBACKS   Callback functions for the training interface
%
% training_callbacks(fname,varargin) executes the callback function
% fname_callback with various parameters

fname=[varargin{1},'_callback'];
feval(fname,varargin{2:end});



%%%exiting and possibly starting the evaluation phase
function proceed_callback(handles)

if handles.run_all,
    %suggesting a break
%     wfig=warndlg(['You have been working for ' int2str(round(etime(clock,handles.time)/60)) 'minutes. It is recommended that you take a break of at least the same duration before starting the evaluation phase. Click on OK when you are ready.'],'Warning');
%     uiwait(wfig);
    %exiting and starting evaluation with the same experiment order
    close(gcbf);
    mushram('evaluation',handles.expe_order);
else,
    %exiting
    close(gcbf);
end



%%%playing sound files

function play_callback(handles,e,f)
% if f,
%     myplay(handles.files{handles.expe_order(e),handles.file_order(e,f)});
% else,
%     myplay(handles.files{handles.expe_order(e),1});
% end
global myAudioPlayer

switch f,
    case 0
    s = handles.files{handles.expe_order(e),1};
    case -1
    s = handles.files{handles.expe_order(e),3};
    otherwise
    s = handles.files{handles.expe_order(e),handles.file_order(e,f)};
end

if ~isempty(myAudioPlayer)
    if isplaying(myAudioPlayer)
        stop(myAudioPlayer);
    end
end
[x,fs] = audioread(s);
myAudioPlayer = audioplayer(x,fs);
play(myAudioPlayer);


function myplay(file)
if isunix,
    %using system's play (from the sox package) on Unix (MATLAB's sound does not work)
    [s,w]=unix(['play ' file]);
else,
    %using MATLAB's wavplay on Windows
    [y,fs]=wavread(file);
    wavplay(y,fs);
end
