%%% Equalities

% 1 Home planet must be first
% 2 Target planet must be last
% 3 Time pairs must match

function Ae = defineEqConstraints(Ae, j, validEqConstraints, t1, t2,...
    n1Index, n2Index, t1Index, startPlanetIndex, endPlanetIndex,...
    arriveTimeVector, departTimeVector)

for constraint=validEqConstraints
    switch constraint
        
        case 1
            if n1Index == startPlanetIndex && t1 == departTimeVector(1)
                Ae{1}(1,j) = 1;
            end
            
        case 2
            if n2Index == endPlanetIndex && t2 == arriveTimeVector(end)
                Ae{2}(1,j) = 1;
            end
            
        case 3
            if t1Index ~= 1
                Ae{3}((length(departTimeVector)-1)*(n1Index-1)+(t1Index-1),j) = 1;
            end
            if t2 ~= arriveTimeVector(end)
                t2_c = find(arriveTimeVector==t2);
                Ae{3}((length(departTimeVector)-1)*(n2Index-1)+t2_c,j) = -1;
            end
    end
end

end