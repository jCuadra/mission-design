function [n1Index,n2Index,t1Index,t2Index,dt,c]=...
    iterationFunction(j,numPlanets,timePermutations,arriveTimeIndex,...
    arriveTimeVector,departTimeVector,minDT,maxDT,nonReturn)

[n1Index,n2Index,t1Index,t2Index] = getIndex(j, numPlanets,...
    timePermutations, arriveTimeIndex);

% Define departure time
t1 = departTimeVector(t1Index);

% Define Arrival Time
t2 = t1+arriveTimeVector(t2Index);

dt = t2-t1;

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