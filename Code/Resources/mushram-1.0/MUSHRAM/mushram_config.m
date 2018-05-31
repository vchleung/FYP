function mushram_config

% MUSHRAM_CONFIG   GUI for the creation of the configuration file
%
% configure asks a series of questions and writes the configuration file
% into mushram_config.txt in the same directory as mushram.m
%
% uses relative paths to the sound files when they are in the same
% directory as mushram.m, or in a subdirectory of it

%getting the directory containing mushram.m
path=which('mushram');
if ~exist(path),
    errordlg('MUSHRAM is not properly installed.','Error');
    return;
end
path=path(1:end-9);

%warning if the configuration file already exists
if exist([path 'mushram_config.txt']),
    wfig=warndlg('The previous configuration file mushram_config.txt will be overwritten.','Warning');
    uiwait(wfig);
end

%asking for the number of experiments and files
nb=inputdlg({'Number of experiments','Number of sound files per experiment (including reference)'},'Size of the experiments',1);
if ~isempty(nb),
    if (length(nb{1}) > 0) & all((nb{1} >= 48) | (nb{1} <= 57)) & (length(nb{2}) > 0) & all((nb{2} >= 48) | (nb{2} <= 57)),
        nbexpe=eval(nb{1});
        nbfile=eval(nb{2});
    else,
        errordlg('Invalid parameter.','Error');
        return;
    end
else,
    return;
end

%asking for the filenames
files=cell(nbexpe,nbfile);
for e=1:nbexpe,
    [filename,pathname]=uigetfile('*.wav',['Experiment ' int2str(e) ' reference sound file']);
    file=[pathname filename];
    if file,
        if strcmp(file(1:length(path)),path),
            file=file(length(path)+1:end);
        end
        files{e,1}=file;
    else,
        return;
    end
    for f=1:nbfile-1,
        [filename,pathname]=uigetfile('*.wav',['Experiment ' int2str(e) ' test sound file ' int2str(f)]);
        file=[pathname filename];
        if file,
            if strcmp(file(1:length(path)),path),
                file=file(length(path)+1:end);
            end
            files{e,f+1}=file;
        else,
            return;
        end
    end
end

%writing the configuration file
config='';
for e=1:nbexpe,
    for f=1:nbfile,
        config=[config files{e,f} char(10)];
    end
    config=[config char(10)];
end
if ~isunix,
    config=strrep(config,char(10),char(13));
end    
fid=fopen([path 'mushram_config.txt'],'w');
if fid~=-1,
    fprintf(fid,'%c',config);
    fclose(fid);
else,
    error('The configuration file mushram_config.txt cannot be opened with writing permission.');
end