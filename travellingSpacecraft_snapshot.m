



function  travellingSpacecraft_snapshot(startDate, maxDuration, timeStep,...
    allPlanets, startPlanet, endPlanet, UserSettings)

if ~isempty(UserSettings)
    
    axHandle = UserSettings.axHandle;
    messageHandle = UserSettings.messageHandle;
    parallelOpt = UserSettings.parallelOpt;
    noIntOrbitOpt = UserSettings.noIntOrbitOpt;
    maxTransitOpt = UserSettings.maxTransitOpt;
    dtOpt = UserSettings.dtOpt;
    maxCost = UserSettings.maxCost;
    c3Opt = UserSettings.c3Opt;
    
else
    
    axHandle = UserSettings.axHandle;
    messageHandle = UserSettings.messageHandle;
    parallelOpt = UserSettings.parallelOpt;
    noIntOrbitOpt = UserSettings.noIntOrbitOpt;
    maxTransitOpt = UserSettings.maxTransitOpt;
    dtOpt = UserSettings.dtOpt;
    maxCost = UserSettings.maxCost;
    c3Opt = UserSettings.c3Opt;
    
end

minDT = 3*30;

%%%% TEST INPUT
% needs update to comply with gui changes
if nargin == 0
    startDate = struct('y',2020, 'm',1, 'd',9, 'UT',0);
    allPlanets = [2 3 4 5];
    startPlanet = 5;
    endPlanet = 2;
    maxDuration = 4*360;
    timeStep = 30;
end

%%
%%%% LAST UPDATED
% plain english output (i.e. planet names, specific dates)
% added sqrt dt factor to cost
% option to minimize earth c3 instead of dv
% try to eliminate obviously infeasible variables (cost too high)
% try to reduce number of variables for non-return mission
% GUI
% replace monotonically increasing index with 4 vectors to track x
% fix no intermediate orbits for return missions

%%
%%%%%   IN PROGRESS

% Forced Orbit Duration (need a way to force orbit between transits, and
%   remove orbit variables that don't meet duration)

% simulate input (hard code test input)
% initial version forces orbit duration for all planets (except start, end)
minPlanetOrbitDuration = 0;

% add forced orbit constraint in or after loop?

% dynamically switch between consolidated orbit constraint, and forced
% orbit constraint

% when allowing planet specific forced orbit duration, allow "no int
% orbits" option to force other planets to have no orbits

% force intermediate orbits and forced orbits to be exclusive otherwise


%%
%%%%%   CONSIDERATIONS

% flyby, two sets of variables, mag only dv that must string together
% make each constraint its own matrix, concatenate before optimization
% add maximum orbit duration in addition to minimum orbit duration
% what even is "proceedHandle"?
% add TOF^-1/2 factor
% update test input
% gui re-animate button
% implement minDT as input
% make parfor and for loops the same.  shared function?
% implement user settings
% visit specified planets multiple times
% simplify/rewrite getIndex (is it still necessary?)
% Parking Orbits (elliptical?)
% Specific Planet @ Date
% Specific Launch/Return date
% No orbit
% Specified Order
% create database of deltaV that persists between function calls
% create numberOfTimeSteps option, instead of explicit timeStep
% create CUDA mex files (inefficient w/out dynamic parallelism)
% re-write entirely/portions in C (to run on external graphics card)
% allow inputs to be strings instead of planet indices
% flyby capability (limit by deflection angle) (needs many complicated
%   constraints, especially if a burn is involved)
%   use second set of variables to calculate for flybys (calculate change in
%   mag of deltav only).  may not be able to restrict deflection angle
%   flyby can't have orbit on either side
%   will still need to match planet dv
% flyby approximation option (only check mag difference, not vector
%   difference)
% allow quiver to show dv instead of actual trajectories in plots
% use intlinprog for future matlab compatability
% add option to set end date instead of duration
% error handling
% reset gui window
% animation timestep gui option
% update test input for non-gui calls
% swap timeStep & duration in gui
% adaptive time steps!!!!!!!!
% planet specific c3, dv minimization
% min orbit time (eliminate very short flights)
% gui instant display of number of variables
% display realistic deltaV using parking orbits & calculating flybys ad hoc
% make it easier to see planet during orbits / reduce number of orbit
%   points
% re-implement orbit constraints
% move start/end auto-tick checkbox logic to individual radio callbacks
% disable intermediate orbit checkbox for return missions (or just
%   implement it)
% download xcode so lambert.m can be compiled
% remove c3 option when doing no intermittent orbits
% add progress update for serial implementation
% add option to only optimize arrival or departure planet (mainly for fun if no intermediate orbits)
% display error if duration is not multiple of time step (or fix if
%   possible)
% use actual warning messages
% when re-implementing lower dt limit, remove variables based on dt rather
%   than high cost
% don't calculate max transit dt cost values
% find a way to make defineConstants inputs "prettier"
% fix parfor warnings
% arriveTimeVector should be transiteTimeVector?
% fill in max cost in gui with default value
% throw out extreme elliptical orbits (i.e. don't fly through the sun!!)
% use UserSettings throughout missionGUI, not just right before function
%   call


%%

home

% Remember format option
orig_form = get(0,'format'); format short

% Start and End Planet Indices
startPlanetIndex = find(allPlanets == startPlanet);
endPlanetIndex   = find(allPlanets == endPlanet);

nonReturn = startPlanet~=endPlanet;

% Define Start Date
startTime = centPastJ2000(startDate);

% Various time vectors
departTimeVector = 0:timeStep:maxDuration-timeStep;
arriveTimeVector = timeStep:timeStep:maxDuration;
arriveTimeIndex  = maxDuration/timeStep:-1:0;

% Number of Planets
numberOfPlanets = length(allPlanets);

% Number of time permutations
timePermutations = sum(arriveTimeIndex);

% Final Indices
n1EndIndex = numberOfPlanets;
n2EndIndex = numberOfPlanets;
t1EndIndex = maxDuration/timeStep;
t2EndIndex = 1;

% Define total number of variables and effective variables
totalNumOfVars = getIndex(n1EndIndex,n2EndIndex,t1EndIndex,t2EndIndex,numberOfPlanets,timePermutations,arriveTimeIndex);

% Define time vector used for GetIndex
transitTimeSum = zeros(size(arriveTimeIndex));
for timeLoop = 1:length(arriveTimeIndex)
    transitTimeSum(timeLoop) = sum(arriveTimeIndex(1:timeLoop));
end

%%% Constraints

% Number of rows for inequality constraints
mi(1) = 1;
mi(2) = numberOfPlanets;
mi(3) = numberOfPlanets;
mi(4) = length(departTimeVector);
mi(5) = length(departTimeVector);
% if ~nonReturn
%     mi(6) = numberOfPlanets;
% else
%     mi(6) = numberOfPlanets+1;
% end

% Number of rows for equality constraints
me(1) = 2;
me(2) = numberOfPlanets*(length(departTimeVector)-1);

% Initialize A and b matrices
%Ai = sparse(zeros(sum(mi),totalNumOfVars));
%Ae = sparse(zeros(sum(me),totalNumOfVars));
Ai = zeros(sum(mi),totalNumOfVars);
Ae = zeros(sum(me),totalNumOfVars);
bi = zeros(sum(mi),1);
be = zeros(sum(me),1);

% Define inequality b matrix
if ~nonReturn
    bi(1) = -numberOfPlanets;
else
    bi(1) = -(numberOfPlanets-1);
end
bi(    mi(1  ) +1:sum(mi(1:2))) = -1;
bi(sum(mi(1:2))+1:sum(mi(1:3))) = -1;
if nonReturn                     %% non return mission
    bi(    mi(1  ) +endPlanetIndex  ) = 0;
    bi(sum(mi(1:2))+startPlanetIndex) = 0;
end
bi(sum(mi(1:3))+1:sum(mi(1:4))) = 1;
bi(sum(mi(1:4))+1:sum(mi(1:5))) = 1;
%b_i(sum(mi(1:5))+1:sum(mi(1:6))) = 1;

% Define nonzero elements of equality b matrix
be(1) = 1;
be(2) = 1;

% Initialize values
c = zeros(totalNumOfVars,1);
n1IndexVector = zeros(totalNumOfVars,1);
n2IndexVector = zeros(totalNumOfVars,1);
t1IndexVector = zeros(totalNumOfVars,1);
t2IndexVector = zeros(totalNumOfVars,1);
dtVector = zeros(totalNumOfVars,1);

disp(' ')
fprintf('Total number of variables: %d\n',totalNumOfVars);
effNumOfVars = totalNumOfVars*(1-1/numberOfPlanets);
% upper bound
fprintf('Estimated number of deltaV calculations: %d\n', int32(effNumOfVars));
% warn if bintprog might fail
if effNumOfVars >= 65535
    disp('Warning: It is unlikely that the current solver can solve the system.');
elseif totalNumOfVars >= 65535
    disp('Warning: The current solver may not be able to solve the system.');
end
disp('Calculating cost vector...')
tic

%%

%%% 4 FOR LOOPS, OR SINGLE PARFOR
%{
x_eff = 0;
time = zeros(1,round(effectiveNumberOfVariables));
effectiveNumberOfVariables = totalNumberOfVariables*(1-1/numberOfPlanets);
tic
for index1 = 1:numberOfPlanets
    
    % Define the first planet
    pl1 = planetIndex(allPlanets(index1));
    
    for index2 = 1:numberOfPlanets
        
        % Define the second planet
        pl2 = planetIndex(allPlanets(index2));
        
        for index3 = 1:length(departTimeVector)
            
            % Define departure time
            t1 = departTimeVector(index3);
            
            for index4 = 1:length(departTimeVector)-index3+1
                
                % Define Arrival Time
                t2 = t1+arriveTimeVector(index4);
                
                % Index Check
                x = getIndex(index1,index2,index3,index4,numberOfPlanets,timePermutations,arriveTimeIndex);
                                
                % Find Cost
                if index1 ~= index2
                    
                    f(x) = calculateDV(t1, t2, pl1, pl2, startTime+t1/36525);
                    
                    time(x) = toc;
                    x_eff = x_eff+1;
                    if x_eff == 1 || x_eff == effectiveNumberOfVariables || floor(sum(time))~=floor(sum(time(1:x-1)))
                        displayProgress(time,x_eff,effectiveNumberOfVariables)
                    end
                end
                
                tic
                
                % Calculate Constraints in sub-function
                [Ai(:,x), Ae(:,x)] = defineConstraints(mi,me,t1,t2,index1,index2,index3,startPlanetIndex,endPlanetIndex,arriveTimeVector,departTimeVector);
                
            end
        end
    end
end
%}

if parallelOpt
    
    parfor j = 1:totalNumOfVars
        
        [n1Index,n2Index,t1Index,t2Index] = getIndex(j,numberOfPlanets,timePermutations,arriveTimeIndex);
        n1IndexVector(j) = n1Index;
        n2IndexVector(j) = n2Index;
        t1IndexVector(j) = t1Index;
        t2IndexVector(j) = t2Index;
        
        % Define departure time
        t1 = departTimeVector(t1Index);
        
        % Define Arrival Time
        t2 = t1+arriveTimeVector(t2Index);
        
        dt = t2-t1;
        dtVector(j) = dt;
        
        % Find Cost
        if n1Index ~= n2Index
            if dt<minDT
                c(j) = 1e8;
            elseif ~(nonReturn && (n1Index==endPlanetIndex || n2Index==startPlanetIndex)) %% for nonreturn, assume start isn't arrived at, and end is departed from
                c(j) = calculateDV(dt, allPlanets(n1Index), allPlanets(n2Index), startTime+t1/36525, dtOpt, c3Opt);
            end
        end
        
        % Calculate Constraints in sub-function
        [Ai(:,j), Ae(:,j)] = defineConstraints(mi,me,t1,t2,n1Index,n2Index,t1Index,startPlanetIndex,endPlanetIndex,arriveTimeVector,departTimeVector,numberOfPlanets);
        
    end
    
else
    
    %%% not in sync, just comment out for now
    %{
    for j = 1:totalNumOfVars
        
        [n1Index,n2Index,t1Index,t2Index] = getIndex(j,numberOfPlanets,timePermutations,arriveTimeIndex);
        n1IndexVector(j) = n1Index;
        n2IndexVector(j) = n2Index;
        t1IndexVector(j) = t1Index;
        t2IndexVector(j) = t2Index;
        
        % Define departure time
        t1 = departTimeVector(t1Index);
        
        % Define Arrival Time
        t2 = t1+arriveTimeVector(t2Index);
        
        % Find Cost
        if n1Index ~= n2Index
            if ~(nonReturn && (n1Index==endPlanetIndex || n2Index==startPlanetIndex)) %% for nonreturn, assume start isn't arrived at, and end is departed from
                c(j) = calculateDV(t2-t1, allPlanets(n1Index), allPlanets(n2Index), startTime+t1/36525, dtOpt, c3Opt);
            end
        end
        
        % Calculate Constraints in sub-function
        [Ai(:,j), Ae(:,j)] = defineConstraints(mi,me,t1,t2,n1Index,n2Index,t1Index,startPlanetIndex,endPlanetIndex,arriveTimeVector,departTimeVector,numberOfPlanets);
        
    end
    %}
    
end


%%

%%% add forced orbit constraint

if minPlanetOrbitDuration
    for i = 1:numberOfPlanets
        if allPlanets(i)~=startPlanet && allPlanets(i)~=endPlanet
            Ae(end+1,n1IndexVector==i & n2IndexVector==i) = 1;
            be(end+1) = 1;
        end
    end
end

% reduce number of variables
varsToDelete = false(size(c));

% remove invalid orbits from start & end planet(s)
if nonReturn
    invalidOrbit = n1IndexVector==n2IndexVector &...
        ~((n1IndexVector==startPlanetIndex & t1IndexVector==1) |...
        (n2IndexVector==endPlanetIndex & t2IndexVector==1) |...
        (n1IndexVector~=startPlanetIndex) |...
        (n2IndexVector~=endPlanetIndex));
    varsToDelete = invalidOrbit | varsToDelete;
else
    invalidOrbit = n1IndexVector==n2IndexVector &...
        n1IndexVector==startPlanetIndex &...
        ~(t1IndexVector==1 |...
        t2IndexVector==1);
    varsToDelete = invalidOrbit | varsToDelete;
end

% no intermediate orbits
if noIntOrbitOpt
    intOrbit = n1IndexVector==n2IndexVector &...
        ~((n1IndexVector==startPlanetIndex & t1IndexVector==1) |...
        (n2IndexVector==endPlanetIndex & t2IndexVector==1));
    varsToDelete = intOrbit | varsToDelete;
end

% deltav too high
% maybe find a way to adjust for c3 or sqrt(dt) options?
if maxCost
    tooHigh = c>maxCost;
else
    tooHigh = c>1e7;
end
varsToDelete = tooHigh | varsToDelete;

% remove the variables that weren't calculated due to dt too low
%shortDT = (t2IndexVector-t1IndexVector)<minDT;
%varsToDelete = shortDT | varsToDelete;

% non return mission simplifications
if nonReturn
    noDepart = n1IndexVector==endPlanetIndex & n1IndexVector~=n2IndexVector;
    noArrival = n2IndexVector==startPlanetIndex & n1IndexVector~=n2IndexVector;
    varsToDelete = noArrival | noDepart | varsToDelete;
end

% transit time limit (may remove sqrt(dt) factor if needed)
if maxTransitOpt
    tooLongTransit = (n2IndexVector-n1IndexVector)>maxTransitOpt & n1IndexVector~=n2IndexVector;
    varsToDelete = tooLongTransit | varsToDelete;
end

% set min orbit time (only if specified)
%if
orbitTooShort = (n1IndexVector==n2IndexVector) & (dtVector<minPlanetOrbitDuration);
varsToDelete = orbitTooShort | varsToDelete;
%end

c(varsToDelete) = [];
n1IndexVector(varsToDelete) = [];
n2IndexVector(varsToDelete) = [];
t1IndexVector(varsToDelete) = [];
t2IndexVector(varsToDelete) = [];
dtVector(varsToDelete) = [];
Ai(:,varsToDelete) = [];
Ae(:,varsToDelete) = [];

disp('Calculations finished.')
toc
fprintf('Reduced number of variables: %d\n',int32(length(c)))

%% Optimization

disp(' ')
disp('Optimization started.')

% Time MATLAB bintprog function
tic
X = bintprog(c,Ai,bi,Ae,be);
%X = intlinprog(c,1:length(c),Ai,bi,Aeq,beq,zeros(size(c)),ones(size(c)));
toc

% Find nonzero indices
X_indices = find(logical(round(X)));

% Get number nonzero indices
numIndex = length(X_indices);

% Initialize outputs
Xn1_index = zeros(1,numIndex);
Xn2_index = zeros(1,numIndex);
Xt1_index = zeros(1,numIndex);
Xt2_index = zeros(1,numIndex);
Xn1 = zeros(1,numIndex);
Xn2 = zeros(1,numIndex);
Xt1 = zeros(1,numIndex);
Xt2 = zeros(1,numIndex);

for indexLoop = 1:numIndex
    
    % Get current variable
    %[Xn1_index(loop), Xn2_index(loop), Xt1_index(loop), Xt2_index(loop)] = getIndex(X_indices(loop),numberOfPlanets,timePermutations,arriveTimeIndex);
    Xn1_index(indexLoop) = n1IndexVector(X_indices(indexLoop));
    Xn2_index(indexLoop) = n2IndexVector(X_indices(indexLoop));
    Xt1_index(indexLoop) = t1IndexVector(X_indices(indexLoop));
    Xt2_index(indexLoop) = t2IndexVector(X_indices(indexLoop));
    
    % Convert from indices to usable values
    Xn1(indexLoop) = allPlanets(Xn1_index(indexLoop));
    Xn2(indexLoop) = allPlanets(Xn2_index(indexLoop));
    Xt1(indexLoop) = departTimeVector(Xt1_index(indexLoop));
    Xt2(indexLoop) = Xt1(indexLoop)+arriveTimeVector(Xt2_index(indexLoop));
    
end

[~, indexOrder] = sort(Xt1);
Xn1 = Xn1(indexOrder);
Xn2 = Xn2(indexOrder);
Xt1 = Xt1(indexOrder);
Xt2 = Xt2(indexOrder);

% concatenate consecutive orbits
indexLoop = 2;
while indexLoop<numIndex+1;
    if Xn1(indexLoop)==Xn1(indexLoop-1) && Xn1(indexLoop)==Xn2(indexLoop) &&...
            Xn1(indexLoop-1)==Xn2(indexLoop-1)
        Xt2(indexLoop-1) = Xt2(indexLoop);
        Xn1(indexLoop) = [];
        Xn2(indexLoop) = [];
        Xt1(indexLoop) = [];
        Xt2(indexLoop) = [];
        numIndex = numIndex-1;
    else
        indexLoop = indexLoop+1;
    end
end

%%% print array
%{
fprintf('\r')
for line = 1:4
    switch line
        case 1
            array = Xn1;
            fprintf('n1\t')
        case 2
            array = Xn2;
            fprintf('n2\t')
        case 3
            array = Xt1;
            fprintf('t1\t')
        case 4
            array = Xt2;
            fprintf('t2\t')
    end
    for loop = 1:numIndex
        fprintf('%d\t',array(loop))
    end
    fprintf('\r')
end
fprintf('\r')
%}


%%% natural language ouput
fprintf('\r')
for line = 1:numIndex
    p1 = planetIndex(Xn1(line));
    date1 = gregDate(startTime+Xt1(line)/36525);
    date2 = gregDate(startTime+Xt2(line)/36525);
    if Xn1(line) == Xn2(line)
        fprintf('Orbit %s ',p1.name);
        fprintf('from %d/%d/%d ',date1.m,date1.d,date1.y);
        fprintf('until %d/%d/%d.\r',date2.m,date2.d,date2.y);
    else
        p2 = planetIndex(Xn2(line));
        fprintf('Transit from %s ', p1.name);
        fprintf('to %s ',p2.name);
        fprintf('from %d/%d/%d ',date1.m,date1.d,date1.y);
        fprintf('until %d/%d/%d.\r',date2.m,date2.d,date2.y);
    end
end
fprintf('\r')

if dtOpt==1
    totalCost = full(dot(c,X));
elseif dtOpt==2
    totalCost = full(dot(c./sqrt(dtVector),X));
end

fprintf('Total cost: %2.4f\r', totalCost);%/sum(sqrt(Xt2-Xt1)) );
fprintf('\r')

set(messageHandle,'Enable','on')

% animate mission sequence
animateMission(Xn1, Xn2, Xt1, Xt2, startTime, maxDuration, axHandle);
fprintf('\r')

format(orig_form)

end