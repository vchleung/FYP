function mushram(varargin)

% MUSHRAM   Runs the MUSHRA experiments described in the configuration file
% mushram_config.txt
%
% mushram or mushram('all') runs both training and evaluation phases
%
% mushram('training') runs the training phase only
%
% mushram('evaluation') runs the evaluation phase only
%
% mushram(phase,'no_random') where phase is 'all', 'training' or 'testing'
% does not randomize the order of the experiments (but does randomize the
% order of the test files within each experiment anyway)
%
% mushram(phase,expe_order) performs the evaluation experiments in the
% alternative order given by the vector expe_order (must span all the
% experiments defined in the configuration file)

%%%process input flags
%default parameters
global questions
global currQuestion
global resultfile
global ratings

phase=0;
run_all=true;
random_expe=true;
%user parameters
if length(varargin) > 0,
    phasename=varargin{1};
    if ischar(phasename),
        if strcmp(phasename,'training'),
            run_all=false;
        elseif strcmp(phasename,'evaluation'),
            phase=1;
        elseif ~strcmp(phasename,'all'),
            errordlg('Bad input parameters.','Error');
            return;
        end
    else,
        errordlg('Bad input parameters.','Error');
        return;
    end
    if length(varargin) > 1,
        norandom=varargin{2};
        if ischar(norandom),
            if strcmp(varargin{2},'no_random'),
                random_expe=0;
            else,
                errordlg('Bad input parameters.','Error');
                return;
            end
        elseif isnumeric(norandom),
            expe_order=norandom;
        else,
            errordlg('Bad input parameters.','Error');
            return;
        end
    end
end

%%%parsing the config file
%opening the file
fid=fopen('mushram_config.txt','r');
if fid~=-1,
    config=fscanf(fid,'%c');
    fclose(fid);
else,
    errordlg('The configuration file mushram_config.txt does not exist or cannot be opened.','Error');
    return;
end

%suppressing spurious linefeeds and transforming Windows linefeeds into Unix ones
if length(config)>1,
    config=strrep(config,char(13),char(10));
    c=find(config~=10);
    config=[config(1:c(end)) char(10) char(10)];
    while ~isempty(strfind(config,[char(10) char(10) char(10)])),
        config=strrep(config,[char(10) char(10) char(10)],[char(10) char(10)]);
    end
else,
    errordlg('The configuration file mushram_config.txt is empty.','Error');
    return;
end

%parsing and checking the file names for all experiments
dblines=strfind(config,[char(10) char(10)]);
nbexpe=length(dblines);
expconfig=config(1:dblines(1));
lines=strfind(expconfig,char(10));
nbfile=length(lines);
files=cell(nbexpe,nbfile);
dblines=[-1 dblines];
for e=1:length(dblines)-1,
    expconfig=config(dblines(e)+2:dblines(e+1));
    lines=strfind(expconfig,char(10));
    if length(lines) == nbfile,
        lines=[0 lines];
        for f=1:length(lines)-1,
            file=expconfig(lines(f)+1:lines(f+1)-1);
            if exist(file),
                files{e,f}=file;
            else,
                errordlg(['The specified sound file ' file ' does not exist. Check the configuration file mushram_config.txt.'],'Error');
                return;
            end
        end
    else,
        errordlg('The number of test files must be the same for all experiments. Check the configuration file mushram_config.txt.','Error');
        return;
    end
end

%%%randomizing the order of the experiments or checking the alternative experiment order is acceptable
if exist('expe_order'),
    err=false;
    for e=1:nbexpe,
        if ~any(expe_order==e),
            err=true;
        end
    end
    if err,
        errordlg('Bad input parameters.','Error');
        return;
    end
elseif random_expe,
    expe_order=randperm(nbexpe);
else,
    expe_order=1:nbexpe;    
end

if phase,

    %%%opening the GUI for the evaluation phase
    %asking for the name of the results file
    if currQuestion==1
    ratings=zeros(nbexpe,nbfile,length(questions));
    [filename,pathname]=uiputfile('mushram_results.txt','Results file name');
    resultfile=[pathname filename];
    end
    if ~resultfile,
        return;
    end
    
    %opening the GUI
%     questions = {...
%         'rate the quality in terms of preservation of the original signal in each test signal';...
%         'rate the quality in terms of level of other sources in each test signal';...
%         'rate the quality in terms of level of artifacts in each test signal';...
%         'give a global quality rate for each test signal '};
    fig=evaluation_gui(nbfile,1,nbexpe);
    if ~fig,
        errordlg('There are too many test files to display. Try increasing the resolution of the screen.','Error');
        return;
    end
    handles=guihandles(fig);
    
    %randomizing the order of the tested files
    file_order=randperm(nbfile);

    %storing data within the GUI
    handles.expe=1;
    handles.resultfile=resultfile;
else,
    
    %%%opening the GUI for the training phase
    %opening the GUI
    fig=training_gui(nbfile,nbexpe,run_all);
    if ~fig,
        errordlg('There are too many experiments or too many test files to display. Try increasing the resolution of the screen.','Error');
        return;
    end
    handles=guihandles(fig);
    
    %randomizing the order of the tested files
    file_order=zeros(nbexpe,nbfile-1);
    for e=1:nbexpe,
        file_order(e,:)=randperm(nbfile-1)+1;
    end
    
    %storing data within the GUI
    handles.run_all=run_all;
    
end

%%%storing data within the GUI
handles.expe_order=expe_order;
handles.nbexpe=nbexpe;
handles.file_order=file_order;
handles.nbfile=nbfile;
handles.files=files;
handles.time=clock;
guidata(fig,handles);