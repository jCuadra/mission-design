% defineEqualityConstraints.m

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [Ae] = defineEqualityConstraints(Ae, j, validEqConstraints, t1, t2,...
    n1Index, n2Index, t1Index, startPlanetIndex, endPlanetIndex,...
    arriveTimeVector, departTimeVector)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function sets the rows for valid equality constraints for a single variable.

INPUTS:
    Ae                  - Cell containing equality constraint matrices to be updated
    j                   - Index of variable that constraints will be added for
    validEqConstraints  - Vector with indices that represent which equality constraints will be added
    t1                  - Departure time associated with current variable
    t2                  - Arrival time associated with current variable
    n1Index             - Index of departure planet associated with current variable
    n2Index             - Index of arrival planet associated with current variable
    t1Index             - Index of departure time associated with current variable
    startPlanetIndex    - Index representing start planet
    endPlanetIndex      - Index representing end planet
    arriveTimeVector    - Vector of all arrival times
    departTimeVector    - Vector of all departure times

OUTPUTS:
    Ae                  - Cell containing updated equality constraint matrices

REQUIRES:

%}
% ----------------------------------------------

for constraint = validEqConstraints
    switch constraint

        % Home planet must be first
        case 1
            if n1Index == startPlanetIndex && t1 == departTimeVector(1)
                Ae{1}(1, j) = 1;
            end

            % Target planet must be last
        case 2
            if n2Index == endPlanetIndex && t2 == arriveTimeVector(end)
                Ae{2}(1, j) = 1;
            end

            % Time pairs must match
        case 3
            if t1Index ~= 1
                Ae{3}((length(departTimeVector) - 1) * (n1Index - 1) + (t1Index - 1), j) = 1;
            end
            if t2 ~= arriveTimeVector(end)
                t2_c = find(arriveTimeVector == t2);
                Ae{3}((length(departTimeVector) - 1) * (n2Index - 1) + t2_c, j) = -1;
            end
    end
end

end
