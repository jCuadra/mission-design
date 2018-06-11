% travellingSpacecraft.m

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function  [N1, N2, T1, T2, totalCost] = travellingSpacecraft(startDate, maxDuration, timeStep, planetIndices, startPlanet, endPlanet, userSettings)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function optimizes a mission with the given parameters and animates it.

INPUTS:
    startDate       - Structure containting date with y, m, d, and UT fields
    maxDuration     - Maximum duration for the mission
    timeStep        - Time step used to generate variables
    planetIndices   - Vector of indices for planets in mission
    startPlanet     - Starting planet for mission
    endPlanet       - End planet for mission
    userSettings    - Struct containing additional settings for mission

OUTPUTS:
    N1              - Sequence of departure planets
    N2              - Sequence of arrival planets
    T1              - Sequence of departure times
    T2              - Sequence of arrival times
    totalCost       - Total cost for the optimization

REQUIRES:
    animateMission
    centuriesPastJ2000
    defineEqualityConstraints
    defineInequalityConstraints
    displayProgress
    getIndex
    gregorianDate
    iterationFunction
    Planet

%}
% ----------------------------------------------

if nargin == 0

    startDate = struct('y', 2018, 'm', 1, 'd', 1, 'UT', 0);
    maxDuration = 3*360;
    timeStep = 30;
    planetIndices = [3 4];
    startPlanet = 3;
    endPlanet = 3;

    parallelOpt = 1;
    noIntOrbitOpt = 0;
    maxTransitOpt = 1e8;
    dtOption = 1;
    maxCost = 1e8;
    c3Option = 0;

else

    parallelOpt = userSettings.parallelOpt;
    noIntOrbitOpt = userSettings.noIntOrbitOpt;
    maxTransitOpt = userSettings.maxTransitOpt;
    dtOption = userSettings.dtOption;
    maxCost = userSettings.maxCost;
    c3Option = userSettings.c3Option;

end


minDT = 0;
maxDT = 1e8;
minPlanetOrbitDuration = 0;

disp('~~~~~~~~Travelling Spacecraft Problem~~~~~~~~')
fprintf('\n')
fprintf('Start:\t\t%s\n', Planet(startPlanet).name)
fprintf('End:\t\t%s\n', Planet(endPlanet).name)
if ~(length(planetIndices) == 2 && startPlanet ~= endPlanet)
    fprintf('Visiting:')
    for planet = planetIndices
        if planet ~= startPlanet && planet ~= endPlanet
            fprintf('\t%s', Planet(planet).name)
        end
    end
    fprintf('\n')
end
fprintf('\n')
fprintf('Start Date:\t%d/%d/%d\n', startDate.m, startDate.d ,startDate.y)
fprintf('Duration:\t%d days (%.2f years)\n', maxDuration, maxDuration/365.25)
fprintf('Time Step:\t%d days\n', timeStep)
fprintf('\n')
disp(userSettings)
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

% Store current format, and set to short
orig_form = get(0, 'format');
format short

% Start and End Planet Indices
startPlanetIndex = find(planetIndices == startPlanet);
endPlanetIndex   = find(planetIndices == endPlanet);

nonReturn = startPlanet ~= endPlanet;

% Define Start Date
startTime = centuriesPastJ2000(startDate);

% Various time vectors
departTimeVector = 0 : timeStep:maxDuration - timeStep;
arriveTimeVector = timeStep : timeStep : maxDuration;
arriveTimeIndex  = maxDuration / timeStep : -1 : 0;

% Number of Planets
numPlanets = length(planetIndices);

% Number of time permutations
timePermutations = sum(arriveTimeIndex);

% Define total number of variables and effective variables
totalNumVars = (numPlanets ^ 2 - 1) * timePermutations + sum(arriveTimeIndex);

%% Initialize Constraints

% Number of rows for inequality constraints
mi(1) = 1;                          % 1 Minimum number of transits
mi(2) = numPlanets;                 % 2 Depart from each planet
mi(3) = numPlanets;                 % 3 Arrive at each planet
mi(4) = length(departTimeVector);   % 4 Only one event can begin at each time
mi(5) = length(departTimeVector);   % 5 Only one event can end at each time

% Number of rows for equality constraints
me(1) = 1;                                            % 1 Home planet first
me(2) = 1;                                            % 2 Target planet last
me(3) = numPlanets * (length(departTimeVector) - 1);  % 3 Time pairs must match

validIneqConstraints = 1:5;
validEqConstraints = 1:3;

% Initialize A and b cells
AiCell = cell(max(validIneqConstraints), 1);
biCell = cell(max(validIneqConstraints), 1);
for loop = validIneqConstraints
    AiCell{loop} = zeros(mi(loop), totalNumVars);
    biCell{loop} = zeros(mi(loop), 1);
end
AeCell = cell(max(validEqConstraints), 1);
beCell = cell(max(validEqConstraints), 1);
for loop = validEqConstraints
    AeCell{loop} = zeros(me(loop), totalNumVars);
    beCell{loop} = zeros(me(loop), 1);
end

% Define inequality b matrix
if ~nonReturn
    biCell{1} = -numPlanets;
else
    biCell{1} = -numPlanets + 1;
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
c = zeros(totalNumVars, 1);
n1IndexVector = zeros(totalNumVars, 1);
n2IndexVector = zeros(totalNumVars, 1);
t1IndexVector = zeros(totalNumVars, 1);
t2IndexVector = zeros(totalNumVars, 1);
dtVector = zeros(totalNumVars, 1);

disp(' ')
fprintf('Total number of variables: %d\n', totalNumVars);
effNumOfVars = totalNumVars * (1 - 1 / numPlanets);
% Upper bound
fprintf('Estimated number of deltaV calculations: %d\n', int32(effNumOfVars));
% Warn if intprog might fail
if effNumOfVars >= 65535
    disp('Warning: It is unlikely that the current solver can solve the system.');
elseif totalNumVars >= 65535
    disp('Warning: The current solver may not be able to solve the system.');
end

%%  Cost Vector Calculation

disp('Calculating cost vector...')

if parallelOpt

    tic
    parfor j = 1:totalNumVars

        [n1Index, n2Index, t1Index, t2Index] = getIndex(j, numPlanets, timePermutations, arriveTimeIndex);
        n1IndexVector(j) = n1Index;
        n2IndexVector(j) = n2Index;
        t1IndexVector(j) = t1Index;
        t2IndexVector(j) = t2Index;

        % Define departure time
        t1 = departTimeVector(t1Index);

        % Define Arrival Time
        t2 = t1+arriveTimeVector(t2Index);

        dt = t2 - t1;
        dtVector(j) = dt;

        % Find Cost
        if n1Index ~= n2Index
            if dt < minDT || dt > maxDT
                c(j) = 1e8;
            elseif ~(nonReturn && (n1Index == endPlanetIndex || n2Index == startPlanetIndex))
                planetDepart = Planet(planetIndices(n1Index), startTime + t1 / 36525);
                planetArrive = Planet(planetIndices(n2Index), startTime + t2 / 36525);
                [~, ~, deltaV] = Orbit.transferOrbit(planetDepart, planetArrive, dt, dtOption, c3Option);
                c(j) = deltaV;
            end
        end

    end % parfor

else

    progressTracker = zeros(1, totalNumVars);
    prevDisp = -1;

    for j = 1:totalNumVars

        tic

        [n1Index, n2Index, t1Index, t2Index, c_j] = iterateCostVector(j, ...
            numPlanets, timePermutations, arriveTimeIndex, ...
            arriveTimeVector, departTimeVector, minDT, maxDT, nonReturn, ...
            planetIndices, startTime, dtOption, c3Option, endPlanetIndex, startPlanetIndex);

        n1IndexVector(j) = n1Index;
        n2IndexVector(j) = n2Index;
        t1IndexVector(j) = t1Index;
        t2IndexVector(j) = t2Index;

        c(j) = c_j;

        progressTracker(j) = toc;

        if fix(100 * j / totalNumVars) ~= prevDisp
            prevDisp = fix(100 * j / totalNumVars);
            displayProgress(progressTracker, j, totalNumVars)
            pause(0.01)
        end

    end

end

%% Creating Constraint Matrices

for j = 1:totalNumVars

    [n1Index, n2Index, t1Index, t2Index] = getIndex(j, numPlanets, timePermutations, arriveTimeIndex);

    % Define departure time
    t1 = departTimeVector(t1Index);

    % Define Arrival Time
    t2 = t1 + arriveTimeVector(t2Index);

    AiCell = defineInequalityConstraints(AiCell, j, validIneqConstraints, t2, ...
        n1Index, n2Index, t1Index, arriveTimeVector);

    AeCell = defineEqualityConstraints(AeCell, j, validEqConstraints, t1, t2,...
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

% Add forced orbit constraint
%
% if minPlanetOrbitDuration
%     for i = 1:numPlanets
%         if planetIndices(i)~=startPlanet && planetIndices(i)~=endPlanet
%             Ae(end+1,n1IndexVector==i & n2IndexVector==i) = 1;
%             be(end+1) = 1;
%         end
%     end
% end

% Reduce number of variables
varsToDelete = false(size(c));

% Remove invalid orbits from start & end planet(s)
if nonReturn
    invalidOrbit = n1IndexVector == n2IndexVector & ...
        ~((n1IndexVector == startPlanetIndex & t1IndexVector == 1) | ...
        (n2IndexVector == endPlanetIndex & t2IndexVector==1) | ...
        (n1IndexVector ~= startPlanetIndex) | ...
        (n2IndexVector ~= endPlanetIndex));
    varsToDelete = invalidOrbit | varsToDelete;
else
    invalidOrbit = n1IndexVector == n2IndexVector & ...
        n1IndexVector == startPlanetIndex & ...
        ~(t1IndexVector == 1 |...
        t2IndexVector == 1);
    varsToDelete = invalidOrbit | varsToDelete;
end

% No intermediate orbits
if noIntOrbitOpt
    intOrbit = n1IndexVector == n2IndexVector & ...
        ~((n1IndexVector == startPlanetIndex & t1IndexVector == 1) | ...
        (n2IndexVector == endPlanetIndex & t2IndexVector == 1));
    varsToDelete = intOrbit | varsToDelete;
end

% Deltav too high
% Maybe find a way to adjust for c3 option?
switch dtOption
    case 2
        cTemp = c ./ sqrt(dtVector);
    otherwise
        cTemp = c;
end
if maxCost
    tooHigh = cTemp > maxCost;
else
    tooHigh = cTemp > 1e7;
end
varsToDelete = tooHigh | varsToDelete;

% Non return mission simplifications
if nonReturn
    noDepart = n1IndexVector == endPlanetIndex & n1IndexVector ~= n2IndexVector;
    noArrival = n2IndexVector == startPlanetIndex & n1IndexVector ~= n2IndexVector;
    varsToDelete = noArrival | noDepart | varsToDelete;
end

% Transit time limit (may remove sqrt(dt) factor if needed)
if maxTransitOpt
    tooLongTransit = (n2IndexVector - n1IndexVector) > maxTransitOpt & n1IndexVector ~= n2IndexVector;
    varsToDelete = tooLongTransit | varsToDelete;
end

% Set min orbit time (only if specified)
orbitTooShort = (n1IndexVector == n2IndexVector) & (dtVector < minPlanetOrbitDuration);
varsToDelete = orbitTooShort | varsToDelete;

% Delete variables
c(varsToDelete) = [];
n1IndexVector(varsToDelete) = [];
n2IndexVector(varsToDelete) = [];
t1IndexVector(varsToDelete) = [];
t2IndexVector(varsToDelete) = [];
dtVector(varsToDelete) = [];
Ai(:, varsToDelete) = [];
Ae(:, varsToDelete) = [];

disp('Calculations finished.')
toc
fprintf('Reduced number of variables: %d\n', int32(length(c)))

%% Optimization

disp(' ')
disp('Optimization started.')

% Time MATLAB bintprog function
tic
%X = bintprog(c, Ai, bi, Ae, be);
x = intlinprog(c, 1:length(c), Ai, bi, Ae, be, zeros(size(c)), ones(size(c)));
toc

% Find nonzero indices
xIndices = find(logical(round(x)));

% Get number nonzero indices
numIndex = length(xIndices);

% Initialize outputs
N1 = zeros(1, numIndex);
N2 = zeros(1, numIndex);
T1 = zeros(1, numIndex);
T2 = zeros(1, numIndex);

% Convert from indices to usable values
for indexLoop = 1:numIndex
    N1(indexLoop) = planetIndices(n1IndexVector(xIndices(indexLoop)));
    N2(indexLoop) = planetIndices(n2IndexVector(xIndices(indexLoop)));
    T1(indexLoop) = departTimeVector(t1IndexVector(xIndices(indexLoop)));
    T2(indexLoop) = T1(indexLoop) + arriveTimeVector(t2IndexVector(xIndices(indexLoop)));
end

[T1, indexOrder] = sort(T1);
T2 = T2(indexOrder);
N1 = N1(indexOrder);
N2 = N2(indexOrder);

% Concatenate consecutive orbits
indexLoop = 2;
while indexLoop < numIndex + 1
    if N1(indexLoop) == N1(indexLoop - 1) && N1(indexLoop) == N2(indexLoop) && N2(indexLoop - 1) == N2(indexLoop - 1)
        T2(indexLoop-1) = T2(indexLoop);
        N1(indexLoop) = [];
        N2(indexLoop) = [];
        T1(indexLoop) = [];
        T2(indexLoop) = [];
        numIndex = numIndex - 1;
    else
        indexLoop = indexLoop + 1;
    end
end

% Natural language ouput
fprintf('\n')
for line = 1:numIndex
    p1 = Planet(N1(line));
    date1 = gregorianDate(startTime + T1(line) / 36525);
    date2 = gregorianDate(startTime + T2(line) / 36525);
    if N1(line) == N2(line)
        fprintf('Orbit %s ', p1.name);
    else
        p2 = Planet(N2(line));
        fprintf('Transit from %s ', p1.name);
        fprintf('to %s ', p2.name);
    end
    fprintf('from %d/%d/%d ', date1.m, date1.d ,date1.y);
    fprintf('until %d/%d/%d.', date2.m, date2.d ,date2.y);
    fprintf('\n')
end
fprintf('\n')

% Calculate total cost and adjust for dtOption
if dtOption == 1
    totalCost = full(dot(c, x));
elseif dtOption == 2
    totalCost = full(dot(c ./ sqrt(dtVector), x));
end
fprintf('Total cost: %2.4f\n', totalCost);
fprintf('\n\n')

% Restore original format
format(orig_form)

end

%%% BUG
% fix hyperbolic orbits
% saturn trajectories don't seem to be working
% fix bug in serial processing (default parameters, venus to mars)
% fix issue with screen going blank after optimizations

%%% TODO
% Forced Orbit Duration (need a way to force orbit between transits, and remove orbit variables that don't meet duration)
% update test input for non-gui calls
% initial version forces orbit duration for all planets (except start, end)
% add forced orbit constraint in or after loop?
% stop sending full vectors to constraint functions
% dynamically switch between consolidated orbit constraint, and forced orbit constraint
% when allowing planet specific forced orbit duration, allow "no int orbits" option to force other planets to have no orbits
% force intermediate orbits and forced orbits to be exclusive
% show previously calculated results in session in dropdown menu, and reanimate from there
% flyby, two sets of variables, mag only dv that must string together
% add maximum orbit duration in addition to minimum orbit duration
% add TOF^-1/2 factor
% gui re-animate button
% implement minDT as input
% make parfor and for loops the same.  shared function?
% visit specified planets multiple times
% simplify/rewrite getIndex (is it still necessary?)
% Parking Orbits cost estimation
% Specific Planet @ Date
% Specific Launch/Return date
% Specified Order
% create database of deltaV that persists between function calls
% create numberOfTimeSteps option, instead of explicit timeStep
% create CUDA mex files
% re-write entirely/portions in C (or even Python)
% allow inputs to be strings instead of planet indices
% flyby capability (limit by deflection angle) (needs many complicated constraints, especially if a burn is involved)
% use second set of variables to calculate for flybys (calculate change in mag of deltav only).
%   may not be able to restrict deflection angle
%   flyby can't have orbit on either side
%   will still need to match planet dv
% flyby approximation option (only check mag difference, not vector difference)
% allow quiver to show dv instead of actual trajectories in plots
% add option to set end date instead of duration
% error handling
% reset gui window
% animation timestep gui option
% swap timeStep & duration in gui
% adaptive time steps
% planet specific c3, dv minimization
% min orbit time (eliminate very short flights)
% gui instant display of number of variables
% display realistic deltaV using parking orbits & calculating flybys ad hoc
% make it easier to see planet during orbits / reduce number of orbit points
% re-implement orbit constraints
% try to run on "enter"
% move start/end auto-tick checkbox logic to individual radio callbacks
% remove c3 option when doing no intermittent orbits
% add option to only optimize arrival or departure planet (mainly for fun if no intermediate orbits)
% display error if duration is not multiple of time step (or fix if possible)
% use actual warning messages
% when re-implementing lower dt limit, remove variables based on dt rather than high cost
% arriveTimeVector should be transitTimeVector?
% don't calculate max transit dt cost values
% fill in max cost in gui with default value
% throw out extreme elliptical orbits (i.e. don't fly through the sun!)
% use userSettings throughout missionGUI, not just right before function call
% add option to use multiple passes (re-adjust time steps and feasible solutions based on previous solution)
% don't calculate dv from start to end planet when there are other target planets
% store time indices in lookup table using 'days after J2000'
% move animate mission out of travellingSpacecraft
% echo input arguments
% deal with minDT, maxDT, and minPlanetOrbitDuration
% use continuous slider
