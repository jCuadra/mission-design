



function  travellingSpacecraft(startDate, maxDuration, timeStep,...
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
    
end

minDT = 3*30;
maxDT = 1000000*30;

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

% parallel option

%%
%%%%%   CONSIDERATIONS
% no int orbits setting is backwards
% draw hyperbolic orbits
% stop sending full vectors to constraint functions
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
numPlanets = length(allPlanets);

% Number of time permutations
timePermutations = sum(arriveTimeIndex);

% Final Indices
n1EndIndex = numPlanets;
n2EndIndex = numPlanets;
t1EndIndex = maxDuration/timeStep;
t2EndIndex = 1;

% Define total number of variables and effective variables
totalNumVars = getIndex(n1EndIndex, n2EndIndex, t1EndIndex, t2EndIndex,...
    numPlanets, timePermutations, arriveTimeIndex);

% Define time vector used for GetIndex
transitTimeSum = zeros(size(arriveTimeIndex));
for timeLoop = 1:length(arriveTimeIndex)
    transitTimeSum(timeLoop) = sum(arriveTimeIndex(1:timeLoop));
end

%% Initialize Constraints

%%% Number of rows for inequality constraints
mi(1) = 1;                          % 1 Minimum number of transits
mi(2) = numPlanets;                 % 2 Depart from each planet
mi(3) = numPlanets;                 % 3 Arrive at each planet
mi(4) = length(departTimeVector);   % 4 Only one event can begin at each time
mi(5) = length(departTimeVector);   % 5 Only one event can end at each time

% Number of rows for equality constraints
me(1) = 1;                                          % 1 Home planet first
me(2) = 1;                                          % 2 Target planet last
me(3) = numPlanets*(length(departTimeVector)-1);    % 3 Time pairs must match

validIneqConstraints = [1:5];
validEqConstraints = [1:3];

% Initialize A and b cells
AiCell = cell(max(validIneqConstraints),1);
biCell = cell(max(validIneqConstraints),1);
for loop = validIneqConstraints
    AiCell{loop} = zeros(mi(loop), totalNumVars);
    biCell{loop} = zeros(mi(loop), 1);
end
AeCell = cell(max(validEqConstraints),1);
beCell = cell(max(validEqConstraints),1);
for loop = validEqConstraints
    AeCell{loop} = zeros(me(loop), totalNumVars);
    beCell{loop} = zeros(me(loop), 1);
end

% Define inequality b matrix
if ~nonReturn
    biCell{1} = -numPlanets;
else
    biCell{1} = 1-numPlanets;
end
biCell{2}(:) = -1;
biCell{3}(:) = -1;
if nonReturn
    biCell{2}(endPlanetIndex) = 0;
    biCell{3}(startPlanetIndex) = 0;
end
biCell{4}(:) = 1;
biCell{5}(:) = 1;

% Define nonzero elements of equality b matrix
beCell{1} = 1;
beCell{2} = 1;

%%

% Initialize values
c = zeros(totalNumVars,1);
n1IndexVector = zeros(totalNumVars,1);
n2IndexVector = zeros(totalNumVars,1);
t1IndexVector = zeros(totalNumVars,1);
t2IndexVector = zeros(totalNumVars,1);
dtVector = zeros(totalNumVars,1);

disp(' ')
fprintf('Total number of variables: %d\n',totalNumVars);
effNumOfVars = totalNumVars*(1-1/numPlanets);
% upper bound
fprintf('Estimated number of deltaV calculations: %d\n', int32(effNumOfVars));
% warn if bintprog might fail
if effNumOfVars >= 65535
    disp('Warning: It is unlikely that the current solver can solve the system.');
elseif totalNumVars >= 65535
    disp('Warning: The current solver may not be able to solve the system.');
end

%%  Cost Vector Calculation

disp('Calculating cost vetor...')

if parallelOpt
    
    tic
    parfor j = 1:totalNumVars
        
        tic
        
        [n1Index,n2Index,t1Index,t2Index] = getIndex(j, numPlanets,...
            timePermutations, arriveTimeIndex);
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
            if dt<minDT || dt>maxDT
                c(j) = 1e8;
            elseif ~(nonReturn && (n1Index==endPlanetIndex || n2Index==startPlanetIndex))
                % for nonreturn, assume start isn't arrived at, and end is departed from
                c(j) = calculateDV(dt, allPlanets(n1Index), allPlanets(n2Index),...
                    startTime+t1/36525, dtOpt, c3Opt);
                %if ~isreal(c(j))
                %    c(j) = 1e8;
                %end
            end
        end
        
        
        
    end
    
else
    
    progressTracker = zeros(1,totalNumVars);
    prevDisp = -1;
    
    for j = 1:totalNumVars
        
        tic
        
        [n1Index,n2Index,t1Index,t2Index,c_j]=...
            iterationFunction(j,numPlanets,timePermutations,arriveTimeIndex,...
            arriveTimeVector,departTimeVector,minDT,maxDT,nonReturn,...
            allPlanets,startTime,dtOpt, c3Opt);
        
        n1IndexVector(j) = n1Index;
        n2IndexVector(j) = n2Index;
        t1IndexVector(j) = t1Index;
        t2IndexVector(j) = t2Index;
        
        c(j) = c_j;
        
        progressTracker(j) = toc;
        
        if fix(100*j/totalNumVars)~=prevDisp
            prevDisp=fix(100*j/totalNumVars);
            displayProgress(progressTracker,j,totalNumVars)
            pause(0.01)
        end
        
    end
    
end

%% Creating Constraint Matrices

for j = 1:totalNumVars
    
    [n1Index,n2Index,t1Index,t2Index] = getIndex(j, numPlanets,...
        timePermutations, arriveTimeIndex);
    
    % Define departure time
    t1 = departTimeVector(t1Index);
    
    % Define Arrival Time
    t2 = t1+arriveTimeVector(t2Index);
    
    AiCell = defineIneqConstraints(AiCell, j, validIneqConstraints, t2, ...
        n1Index, n2Index, t1Index, arriveTimeVector);
    
    AeCell = defineEqConstraints(AeCell, j, validEqConstraints, t1, t2,...
        n1Index, n2Index, t1Index, startPlanetIndex, endPlanetIndex,...
        arriveTimeVector, departTimeVector);

end



%% Constraint Pruning

Ai = [];
bi = [];
for constraint = validIneqConstraints
    Ai = [Ai; AiCell{constraint}];
    bi = [bi; biCell{constraint}];
end

Ae = [];
be = [];
for constraint = validEqConstraints
    Ae = [Ae; AeCell{constraint}];
    be = [be; beCell{constraint}];
end

%%% add forced orbit constraint
%
% if minPlanetOrbitDuration
%     for i = 1:numPlanets
%         if allPlanets(i)~=startPlanet && allPlanets(i)~=endPlanet
%             Ae(end+1,n1IndexVector==i & n2IndexVector==i) = 1;
%             be(end+1) = 1;
%         end
%     end
% end

%%% reduce number of variables
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
% maybe find a way to adjust for c3 option?
switch dtOpt
    case 2
        cTemp = c./sqrt(dtVector);
    otherwise
        cTemp = c;
end
if maxCost
    tooHigh = cTemp>maxCost;
else
    tooHigh = cTemp>1e7;
end
varsToDelete = tooHigh | varsToDelete;

% non return mission simplifications
if nonReturn
    noDepart = n1IndexVector==endPlanetIndex & n1IndexVector~=n2IndexVector;
    noArrival = n2IndexVector==startPlanetIndex & n1IndexVector~=n2IndexVector;
    varsToDelete = noArrival | noDepart | varsToDelete;
end

% transit time limit (may remove sqrt(dt) factor if needed)
if maxTransitOpt
    tooLongTransit = (n2IndexVector-n1IndexVector)>maxTransitOpt &...
        n1IndexVector~=n2IndexVector;
    varsToDelete = tooLongTransit | varsToDelete;
end

% set min orbit time (only if specified)
orbitTooShort = (n1IndexVector==n2IndexVector) & (dtVector<minPlanetOrbitDuration);
varsToDelete = orbitTooShort | varsToDelete;

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
%X = bintprog(c,Ai,bi,Ae,be);
X = intlinprog(c,1:length(c),Ai,bi,Ae,be,zeros(size(c)),ones(size(c)));
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
while indexLoop<numIndex+1
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

set(messageHandle,'Enable','on');

% animate mission sequence
animateMission(Xn1, Xn2, Xt1, Xt2, startTime, maxDuration, axHandle);
fprintf('\r')

format(orig_form)

end