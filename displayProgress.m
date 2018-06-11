% displayProgress.m

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function displayProgress(progressTracker, iterationCounter, totalIterations)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
Displays progress of loops in command window

INPUTS:
    progressTracker     - Vector containing elapsed time for each iteration
    iterationCounter    - Scalar of the current iteration index
    totalIterations     - Scalar of total number of iterations

OUTPUTS:

REQUIRES:

%}
% ----------------------------------------------

% Define strings used in displayProgress
str1 = '............................................................';
str2 = '                                                            ';

% Only Consider Nonzero Entries
progressTracker = progressTracker(progressTracker~=0);

%clc;
home
disp(' ')

disp('Data Point:')
disp(iterationCounter)

if length(progressTracker) >= 25
    disp('Current Speed (ms per calculation):')
    disp(1000 * mean(progressTracker(end - 24:end)))
    %nextUpdate = 1/mean(progressTracker(end-24:end));
else
    disp('Current Speed (ms per calculation):')
    disp('...')
    %nextUpdate = 100;
end

disp('Average Speed (ms per calculation):')
disp(1000 * mean(progressTracker))

disp('Total Time Elapsed:')
%disp(sum(time))
s = sum(progressTracker);
hours = floor(s / 3600);
s = s - hours * 3600;
mins = floor(s / 60);
secs = s - mins * 60;
fprintf('    %02d:%02d:%05.2f\n\n', hours, mins, secs);

disp('Percent Complete:')
disp(iterationCounter / totalIterations * 100)

disp('Time Remaining:')
s = (totalIterations - iterationCounter) * mean(progressTracker);
hours = floor(s / 3600);
s = s - hours * 3600;
mins = floor(s / 60);
secs = s - mins * 60;
fprintf('    %02d:%02d:%05.2f\n\n', hours, mins, secs)

mark = fix(length(str1) * iterationCounter / totalIterations);

bar = str1(1:mark);
blank = str2(1:length(str1) - mark);

fprintf('|%s%s|\n', bar, blank);

drawnow;

end
