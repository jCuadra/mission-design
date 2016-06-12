function displayProgress(progressTracker,iterationCounter,totalIterations)


% Define strings used in DisplayProgress
str = '............................................................';
str2= '                                                            ';

%{
% Only Consider Nonzero Entries
progressTracker = progressTracker(progressTracker~=0);

clc;
disp(' ')

disp('Data Point:')
disp(iterationCounter)

if length(progressTracker) >= 25
    disp('Current Speed (ms per calculation):')
    disp(1000*mean(progressTracker(end-24:end)))
else
    disp('Current Speed (ms per calculation):')
    disp('...')
end

disp('Average Speed (ms per calculation):')
disp(1000*mean(progressTracker))

disp('Total Time Elapsed:')
s = sum(progressTracker);
hours = floor(s/3600);
s = s - hours*3600;
mins = floor(s/60);
secs = s-mins*60;
hms = sprintf('%02d:%02d:%05.2f\n', hours, mins, secs);
disp(hms)


disp('Percent Complete:')
disp(iterationCounter/nn_eff*100)

disp('Time Remaining:')
s = (nn_eff-iterationCounter)*mean(progressTracker);
hours = floor(s/3600);
s = s - hours*3600;
mins = floor(s/60);
secs = s-mins*60;
hms = sprintf('%02d:%02d:%05.2f\n', hours, mins, secs);
disp(hms)

mark = fix(length(str)*iterationCounter/nn_eff);

bar = str(1:mark);
blank = str2(1:length(str)-mark);

progress = sprintf('|%s%s|',bar,blank);

disp(progress)
%}

% Only Consider Nonzero Entries
progressTracker = progressTracker(progressTracker~=0);

clc;
disp(' ')

disp('Data Point:')
disp(iterationCounter)

if length(progressTracker) >= 25
    disp('Current Speed (ms per calculation):')
    disp(1000*mean(progressTracker(end-24:end)))
    nextUpdate = 1/mean(progressTracker(end-24:end));
else
    disp('Current Speed (ms per calculation):')
    disp('...')
    nextUpdate = 100;
end

disp('Average Speed (ms per calculation):')
disp(1000*mean(progressTracker))

disp('Total Time Elapsed:')
%disp(sum(time))
s = sum(progressTracker);
hours = floor(s/3600);
s = s - hours*3600;
mins = floor(s/60);
secs = s-mins*60;
hms = sprintf('%02d:%02d:%05.2f\n', hours, mins, secs);
disp(hms)


disp('Percent Complete:')
disp(iterationCounter/totalIterations*100)

disp('Time Remaining:')
s = (totalIterations-iterationCounter)*mean(progressTracker);
hours = floor(s/3600);
s = s - hours*3600;
mins = floor(s/60);
secs = s-mins*60;
hms = sprintf('%02d:%02d:%05.2f\n', hours, mins, secs);
disp(hms)

mark = fix(length(str)*iterationCounter/totalIterations);

bar = str(1:mark);
blank = str2(1:length(str)-mark);

progress = sprintf('|%s%s|',bar,blank);

disp(progress)

end