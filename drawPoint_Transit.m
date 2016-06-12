function h = drawPoint_Transit(axHandle, p1Index,p2Index,T0,dt,t,form)
%dt     transit duration
%t      days into transit

tau = 2*pi;

p1Struct = planetState(p1Index,T0);
p2Struct = planetState(p2Index,T0+dt/36525);

[V1, ~] = lambertSolver(p1Struct.r, p2Struct.r, dt*24*3600, 'pro');

% [V1, ~, ~, ~] = lambert(p1Struct.r', p2Struct.r', dt, 0, 132712440018.9);
% V1 = V1';
% [V1b, ~, ~, ~] = lambert(p1Struct.r', p2Struct.r', dt, 0, 132712440018.9);
% V1b = V1b';

tStruct = p1Struct;
tStruct.v = V1;

tStruct = sv2oe(tStruct);

% calculate mean anomaly from true anomaly
m = ta2ma(tStruct.nu,tStruct.e);

% increment mean anomaly by t days
m = mod(m+tau/tStruct.T*t*24*3600, tau);

% convert new mean anomaly back into true anomaly
tStruct.nu = ma2ta(m,tStruct.e);

% recalculate state vector
tStruct = oe2sv(tStruct);

% plot r vector
h = plot3(axHandle, tStruct.r(1), tStruct.r(2), tStruct.r(3),form);

end