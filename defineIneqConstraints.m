%%% Indequalities

% 1 Minimum number of transits equal to number of planets (or 1 less if non-return)
% 2 Depart from each planet at least once (unless end planet of nonreturn mission)
% 3 Arrive at each Planet at least once (unless start planet of nonreturn mission)
% 4 Only one event can begin at each time
% 5 Only one event can end at each time

function Ai = defineIneqConstraints(Ai, j, validIneqConstraints, t2,...
    n1Index, n2Index, t1Index, arriveTimeVector)

for constraint=validIneqConstraints
    switch constraint
        
        case 1
            if n1Index ~= n2Index
                Ai{1}(1,j) = -1;
            end
            
        case 2
            if n1Index ~= n2Index
                Ai{2}(n1Index,j) = -1;
            end
            
        case 3
            if n1Index ~= n2Index
                Ai{3}(n2Index,j) = -1;
            end
            
        case 4
            Ai{4}(t1Index) = 1;
            
        case 5
            Ai{5}(arriveTimeVector==t2,j) = 1;
    end
end


end