% iterateCostVector.m

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [n1Index, n2Index, t1Index, t2Index, c_j] = ...
    iterateCostVector(j, numPlanets, timePermutations, arriveTimeIndex, ...
    arriveTimeVector, departTimeVector, minDT, maxDT, nonReturn, ...
    planetIndices, startTime, dtOption, c3Option, endPlanetIndex, startPlanetIndex)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function gets the cost and values associated with an index.

INPUTS:
    j                   - Index of the current variable
    numPlanets          - Total number of planets
    timePermutations    - Total number of valid combinations for time variables
    arriveTimeIndex     - Vector of indices for all arrival times
    arriveTimeVector    - Vector of all arrival times
    departTimeVector    - Vector of all depature times
    minDT               - Minimum transit time allowed
    maxDT               - Maximum transit time allowed
    nonReturn           - Boolean indicating if start planet is same as end planet
    planetIndices       - Vector of indicies for all planets
    startTime           - Start time for mission in centures after J2000
    dtOption            - Option for TOF cost factors
    c3Option            - Option for using c3 in cost calculation
    endPlanetIndex      - Index of end planet
    startPlanetIndex    - Index of start planet

OUTPUTS:
    n1Index             - Index of departure planet associated with current variable
    n2Index             - Index of arrival planet associated with current variable
    t1Index             - Index of departure time associated with current variable
    t2Index             - Index of arrival time associated with current variable
    c_j                 - Cost associated with the index j

REQUIRES:
    getIndex
    Orbit

%}
% ----------------------------------------------

[n1Index, n2Index, t1Index, t2Index] = getIndex(j, numPlanets, timePermutations, arriveTimeIndex);

% Define departure time
t1 = departTimeVector(t1Index);

% Define Arrival Time
t2 = t1 + arriveTimeVector(t2Index);

dt = t2 - t1;

% Find Cost
if n1Index ~= n2Index
    if dt < minDT || dt > maxDT
        c_j = 1e8;
    elseif ~(nonReturn && (n1Index == endPlanetIndex || n2Index == startPlanetIndex))
        % for nonreturn, assume start isn't arrived at, and end is departed from
        planetDepart = Planet(planetIndices(n1Index), startTime + t1 / 36525);
        planetArrive = Planet(planetIndices(n2Index), startTime + t2 / 36525);
        [~, ~, deltaV] = Orbit.transferOrbit(planetDepart, planetArrive, dt, dtOption, c3Option);
        c_j = deltaV;
    end
else
    c_j = 0;
end

end
