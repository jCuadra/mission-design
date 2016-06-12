function drawTransit(p1Index,p2Index,T,dt,form)
%dt in days

tau = 2*pi;

p1Struct = planetState(p1Index,T);
p2Struct = planetState(p2Index,T+dt/36525);

[v1, v2] = lambertSolver(p1Struct.r, p2Struct.r, dt*24*3600, 'pro');
p1Struct.v = v1;
p2Struct.v = v2;

p1Struct = sv2oe(p1Struct);
p2Struct = sv2oe(p2Struct);

if p1Struct.nu > p2Struct.nu
    p1Struct.nu = p1Struct.nu-tau;
end

nu = linspace(p1Struct.nu,p2Struct.nu,180);
r = zeros(180,3);

for div = 1:180
    p1Struct.nu = nu(div);
    p1Struct = oe2sv(p1Struct);
    r(div,:) = p1Struct.r;
end

hold on; axis equal off
plot3(r(:,1), r(:,2), r(:,3),form)

end