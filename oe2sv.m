function [orbitStruct] = oe2sv(orbitStruct)

mu = 132712440018.9;

a = orbitStruct.a;
e = orbitStruct.e;
i = orbitStruct.i;
O = orbitStruct.O;
w = orbitStruct.w;
nu = orbitStruct.nu;

h = sqrt(mu*a*(1-e^2));
p = h^2/mu;

r = a*(1-e^2)/(1+e*cos(nu));
ri = cos(nu+w)*cos(O)-sin(nu+w)*sin(O)*cos(i);
rj = cos(nu+w)*sin(O)+sin(nu+w)*cos(O)*cos(i);
rk = sin(nu+w)*sin(i);
rh = [ri;rj;rk];
rVec = r*rh;
orbitStruct.r = rVec;

v = (mu/p*(1+2*e*cos(nu)+e^2)).^.5;
g = atan(e*sin(nu)/(1+e*cos(nu)));
vi = -(sin(nu+w-g)*cos(O)+cos(nu+w-g)*sin(O)*cos(i));
vj = -(sin(nu+w-g)*sin(O)-cos(nu+w-g)*cos(O)*cos(i));
vk = cos(nu+w-g)*sin(i);
vh = [vi;vj;vk];
vVec = v*vh;
orbitStruct.v = vVec;

end