% getIndex.m

%%% TODO
% Calculate arriveTimeIndex earlier

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [n1Index, n2Index, t1Index, t2Index] = getIndex(j, numPlanets, timePermutations, arriveTimeIndex)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function gets the values associated with the variable for the given index

INPUTS:
    j                   - index of the variable
    numPlanets          - Total number of planets
    timePermutations    - Total number of valid combinations for time variables
    arriveTimeIndex     - Vector of indices for all arrival times

OUTPUTS:
    n1Index             - Index of departure planet associated with current variable
    n2Index             - Index of arrival planet associated with current variable
    t1Index             - Index of departure time associated with current variable
    t2Index             - Index of arrival time associated with current variable

REQUIRES:

%}
% ----------------------------------------------

% Define time vector used for getIndex
t2_sum = zeros(size(arriveTimeIndex));
for sum_c = 1:length(arriveTimeIndex)
    t2_sum(sum_c) = sum(arriveTimeIndex(1:sum_c));
end

x_ind1 = numPlanets * timePermutations;
n1Index = fix((j - 1) / x_ind1);
j = j - n1Index * x_ind1;

x_ind2 = timePermutations;
n2Index = fix((j - 1) / x_ind2);
j = j - n2Index * x_ind2;

t1Index = find(j > t2_sum, 1, 'last');
if isempty(t1Index)
    t1Index = 0;
else
    j = j - t2_sum(t1Index);
end

n1Index = n1Index + 1;
n2Index = n2Index + 1;
t1Index = t1Index + 1;
t2Index = j;

end
