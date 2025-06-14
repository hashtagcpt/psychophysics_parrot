function zgo( cmd, shortname, longname )
% zgo  Change working directory using abbreviated folder names
%
% Usage: zgo cmd shortname longname 
%
% Instructions: zgo provides an easy directory switching routine which is
% handy for switching quickly among directories. Once a directory has been 
% associated with a shortname one can switch directories by typing 
% zgo <shortname>.   
%
% On the first run of zpath, or if paths.mat can not be found on the 
% default path the user will be prompted for a location to save paths.mat
%
% zgo save <shortname> <longname>
%	save a shorthand <shortname> for directory <longname> to shorthand.mat
%   if the <longname> is not passed <shortname> is assigned the current dir
%
% zgo [ set ] <shortname>
%	set directory to <shortname>, [ set ] argument not required 
%
% zgo ls
%	list shortnames
%
% zgo rm <shortname>
%	remove <shortname> from shorthand.mat
%
% zgo where
%   display the location shorthand.mat 
%
% zgo clean
%   remove shorthands that do not point to valid directories -- USE WITH
%   CARE!

%isOctave = exist('OCTAVE_VERSION') ~= 0; % are we octave or MATbad

% handle abbreviated syntax
if nargin == 0
    cmd = 'ls';
end

if nargin == 1 && ~strcmp(cmd,'ls') && ~strcmp(cmd,'where') && ~strcmp(cmd,'clean') 
	shortname = cmd;
	name = cmd;
	cmd='set';
end

%handle case for first/run non-existant shorthand.mat
if ~exist('shorthand.mat', 'file')
    answer = input('\n\nFile shorthand.mat not found - create? (y/n)? ','s');
    if strcmp(lower(answer),'y')
        eval('cd ~');
        home = pwd;
		uisave('home','shorthand.mat');
    elseif strcmp(lower(answer),'n')   
        error('FATAL: zgo.m shorthand.mat file not found');
    end
    return;
end

% execute appropriate command
switch lower(cmd),
    % load a stored path
    case 'set',
        load('shorthand.mat'); 
        if exist('name','var')
            eval(sprintf('godir = %s;', name));
            fprintf(1,'directory:  %s\n',godir);            
        end
        if ~exist(godir,'dir')
            fprintf(1,'Not a directory:  %s\n',godir);
            return;
        elseif exist(godir,'dir')
            cd(godir);
            return;
        else
            fprintf(1,'Directory shorthand ''%s'' not found\n',shortname);
            return;
        end
    case 'save',
        if ~exist('longname','var');
            longname = pwd;
        end
        eval([ shortname '=longname;' ]);
        save('shorthand.mat', shortname, '-append');
    case 'ls',
        fprintf('\nShorthands found:\n\n');
        s=whos('-file','shorthand.mat');
        for tmpCtr = 1:size(s)
            if ~(strcmp(s(tmpCtr).name,'tmpCtr') | strcmp(s(tmpCtr).name,'cmd'))
                fprintf('%s\n', s(tmpCtr).name);
            end
        end
        fprintf('\n');
    % remove a stored shorthand 
    case 'rm',
        load shorthand.mat 
        s=whos('-file','shorthand.mat');
        for tmpCtr = 1:size(s)
            if strcmp(s(tmpCtr).name, shortname)
               fprintf(1,'Directory shorthand ''%s'' removed.\n', shortname); 
               clear(shortname)               
            end
        end
        clear s shortname 
        save(which('shorthand.mat'));
    % where is shorthand.mat    
    case 'where'
        which('shorthand.mat')
    % clean up shorthand.mat
    case 'clean'
        load shorthand.mat 
        fprintf(1,'Cleaning...\n\n');            
        s=whos('-file','shorthand.mat');
        for tmpCtr = 1:size(s)
            eval(sprintf('godir = %s;', s(tmpCtr).name)); 
            if godir ~= 7 && ischar(godir)
                if exist(godir,'dir') ~= 7 && ~strcmp(godir,'rm')
                   fprintf('Removing %s shorthand to %s\n', s(tmpCtr).name, godir);
                   eval(sprintf('clear %s', s(tmpCtr).name));
                end
            end
        end            
        clear s godir tmpCtr
        save shorthand.mat
        fprintf(1,'\n\nCleaning complete.\n');
    otherwise
        error(sprintf('Unknown command parameter ''%s''',cmd));
end

return;
