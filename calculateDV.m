function [deltaV] = calculateDV(dt, p1Index, p2Index, T, dtOption, c3Opt)

p1Struct = planetState(p1Index,T);
p2Struct = planetState(p2Index,T+dt/36525);

% [V1, V2] = lambertSolver(p1Struct.r, p2Struct.r, dt*24*3600, 'pro');
% deltaV = norm(V1-p1Struct.v)+norm(V2-p2Struct.v);

[V1a, V2a, ~, errora] = lambert(p1Struct.r', p2Struct.r', dt, 0, 132712440018.9);
V1a = V1a';
V2a = V2a';

[V1b, V2b, ~, errorb] = lambert(p1Struct.r', p2Struct.r', -dt, 0, 132712440018.9);
V1b = V1b';
V2b=V2b';

if errora<1 || errorb<1
    disp('Error calculating deltaV.')
end

%%% deltaV cost methods

% sum of c3 and dv
if c3Opt
    deltaVa = norm(V1a-p1Struct.v)^2+norm(V2a-p2Struct.v);
    deltaVb = norm(V1b-p1Struct.v)^2+norm(V2b-p2Struct.v);
else
    % sum of individual dv
    deltaVa = norm(V1a-p1Struct.v)+norm(V2a-p2Struct.v);
    deltaVb = norm(V1b-p1Struct.v)+norm(V2b-p2Struct.v);
end

% flyby hack
%deltaVa = abs(norm(V1a)-norm(p1Struct.v))+abs(norm(V2a)-norm(p2Struct.v));
%deltaVb = abs(norm(V1b)-norm(p1Struct.v))+abs(norm(V2b)-norm(p2Struct.v));

%%% cost increases with time of flight
switch dtOption
    case 1
        dtFactor = 1;
    case 2
        dtFactor = sqrt(dt);
end
deltaV = min([deltaVa deltaVb])*dtFactor;

end