% defineInequalityConstraints.m

%%% TODO
% re-add consecutive orbit constraint, but only for non-start/end planets

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [Ai] = defineInequalityConstraints(Ai, j, validIneqConstraints, t2, ...
    n1Index, n2Index, t1Index, arriveTimeVector)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function sets the rows for valid inequality constraints for a single variable.

INPUTS:
    Ai                      - Cell containing inequality constraint matrices to be updated
    j                       - Index of variable that constraints will be added for
    validIneqConstraints    - Vector with indices that represent which inequality constraints will be added
    t2                      - Arrival time associated with current variable
    n1Index                 - Index of departure planet associated with current variable
    n2Index                 - Index of arrival planet associated with current variable
    t1Index                 - Index of departure time associated with current variable
    arriveTimeVector        - Vector of all arrival times

OUTPUTS:
    Ai                      - Cell containing inequality constraint matrices to be updated

REQUIRES:

%}
% ----------------------------------------------

for constraint = validIneqConstraints

    switch constraint

        % Minimum number of transits equal to number of planets (or 1 less if non-return)
        case 1
            if n1Index ~= n2Index
                Ai{1}(1, j) = -1;
            end

            % Depart from each planet at least once (unless end planet of nonreturn mission)
        case 2
            if n1Index ~= n2Index
                Ai{2}(n1Index, j) = -1;
            end

            % Arrive at each Planet at least once (unless start planet of nonreturn mission)
        case 3
            if n1Index ~= n2Index
                Ai{3}(n2Index, j) = -1;
            end

            % Only one event can begin at each time
        case 4
            Ai{4}(t1Index) = 1;

            % Only one event can end at each time
        case 5
            Ai{5}(arriveTimeVector == t2, j) = 1;

    end % switch

end % for

end
