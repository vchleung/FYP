function evaluation_callbacks(varargin)

% EVALUATION_CALLBACKS   Callback functions for the evaluation interface
%
% evaluation_callbacks(fname,varargin) executes the callback function
% fname_callback with various parameters

fname=[varargin{1},'_callback'];
feval(fname,varargin{2:end});



%%%saving the rating results and proceeding to the next experiment or exiting
function results_callback(handles)
global questions
global currQuestion
global ratings

%getting the ratings for all files
for f=1:handles.nbfile,
    ratings(handles.expe_order(handles.expe),handles.file_order(f),currQuestion)=get(getfield(handles,['slider' int2str(f)]),'Value');
end
% if ~any(ratings(handles.expe_order(handles.expe),:,currQuestion)==100),
%     wfig=warndlg('At least one of the sounds must be rated 100.','Warning');
%     uiwait(wfig);
%     return;
% end
%saving the whole results (to avoid losing data if the program terminates early)
results='';
for eq = 1:length(questions)
    for e=1:handles.nbexpe,
        for f=1:handles.nbfile,
            results=[results int2str(ratings(e,f,eq)) char(10)];
        end
        results=[results char(10)];
    end
end
if ~isunix,
    results=strrep(results,char(10),char(13));
end
fid=fopen(handles.resultfile,'w');
fprintf(fid,'%c',results);
fclose(fid);
if handles.expe<handles.nbexpe
    handles.expe=handles.expe+1;
    %updating title
    set(handles.experiment,'String',['Task ' num2str(currQuestion) '/' num2str(length(questions)) ': ' questions{currQuestion} ' - Experiment ' int2str(handles.expe) '/' int2str(handles.nbexpe)]);
    if handles.expe==handles.nbexpe && currQuestion==length(questions),
        pos=get(handles.results,'Position');
        pos(1)=pos(1)+2.5;
        pos(3)=19;
        set(handles.results,'Position',pos,'String','Save and exit');
    end
    %moving all the sliders back to 0
    for f=1:handles.nbfile,
        shandle=getfield(handles,['slider' int2str(f)]);
        set(shandle,'Value',0);
        rhandle=getfield(handles,['rating' int2str(f)]);
        set(rhandle,'String',0);
    end
    %randomizing the order of the tested files for the next experiment
    handles.file_order=randperm(handles.nbfile);
    %testing whether a break is needed before the next experiment
    %     if etime(clock,handles.time) > 20*60,
    %         wfig=warndlg(['You have been working for ' int2str(round(etime(clock,handles.time)/60)) 'minutes. It is recommended that you take a break of at least the same duration before starting the next experiment. Click on OK when you are ready.'],'Warning');
    %         uiwait(wfig);
    %     end
    handles.time=clock;
    guidata(gcbf,handles);
elseif currQuestion<length(questions)
    currQuestion = currQuestion+1;
    handles.expe=1;
    %suggesting a break
    %     wfig=warndlg(['You have been working for ' int2str(round(etime(clock,handles.time)/60)) 'minutes. It is recommended that you take a break of at least the same duration before starting the evaluation phase. Click on OK when you are ready.'],'Warning');
    %     uiwait(wfig);
    %exiting and starting evaluation with the same experiment order
    close(gcbf);
    mushram('all',handles.expe_order);
else
    %exiting
    close(gcbf);
end



%%%rounding and displaying the values of the sliders
function slider_callback(handles,f)

shandle=getfield(handles,['slider' int2str(f)]);
set(shandle,'Value',round(get(shandle,'Value')));
rhandle=getfield(handles,['rating' int2str(f)]);
set(rhandle,'String',get(shandle,'Value'));



%%%playing sound files

% function play_callback(handles,f)
%
% if f,
%     myplay(handles.files{handles.expe_order(handles.expe),handles.file_order(f)});
% else,
%     myplay(handles.files{handles.expe_order(handles.expe),1});
% end
function play_callback(handles,f)
% if f,
%     myplay(handles.files{handles.expe_order(e),handles.file_order(e,f)});
% else,
%     myplay(handles.files{handles.expe_order(e),1});
% end
global myAudioPlayer

switch f,
    case 0
        s = handles.files{handles.expe_order(handles.expe),1};
    case -1
        s = handles.files{handles.expe_order(handles.expe),3};
    otherwise
        s = handles.files{handles.expe_order(handles.expe),handles.file_order(f)};
end

if ~isempty(myAudioPlayer)
    if isplaying(myAudioPlayer)
        stop(myAudioPlayer);
    end
end
[x fs] = audioread(s);
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
