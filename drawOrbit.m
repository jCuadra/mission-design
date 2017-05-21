function drawOrbit(axHandle, pIndex,T0)

tau = 2*pi;

[pStruct] = planetState(pIndex,T0);

nu = linspace(0,tau,361);
r = zeros(361,3);

for deg = 0:360
    pStruct.nu = nu(deg+1);
    pStruct = oe2sv(pStruct);
    r(deg+1,:) = pStruct.r;
end

plot3(axHandle, r(:,1), r(:,2), r(:,3),'k')
view(0,45)

end