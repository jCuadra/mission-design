%%% OrbitalElements
% Created by Patrick Klein
% Last edited: 9/11/14

function [orbitSTruct] = sv2oe(orbitStruct)
%%% Input:  rv is a 3x1 position vector in km
%%%         vv is a 3x1 velocity vector in km/s
%
%%% Output: a is the semi-major axis
%%%         e is the eccentricity
%%%         i is the inclination in radians
%%%         w is the argument of perigee in radians
%%%         O is the ascending node in radians
%%%         theta is the true anomaly in radians
%%%         h is a scalar of the specific angular momentum in km^2/s
%%%         T is the orbital period in s


% Define tau
tau = 2*pi;

% Define gravitational parameter (Earth)
mu = 132712440018.9;

rVec = orbitStruct.r;
vVec = orbitStruct.v;

% Magnitude of vectors
r = norm(rVec);
v = norm(vVec);

vr = dot(rVec,vVec)/r;

% Specific angular momentum vector
hVec = cross(rVec,vVec);

% Magnitude of specific angular momentum
h = norm(hVec);

% Inclination
i = acos(hVec(3)/h);

Nv = cross([0;0;1],hVec);

N = norm(Nv);

% Ascending node
O = acos(Nv(1)/N);

% Quadrant check
if Nv(2)<0
    O = tau-O;
end

% Eccentricity vector
eVec = (1/mu)*((v^2-mu/r)*rVec-r*vr*vVec);

% Eccentricity scalar
e = norm(eVec);

% Semi-major axis
a = h^2/mu/(1-e^2);

% Argument of perigee
w = acos(dot(Nv/N,eVec/e));

% Quadrant check
if eVec(3)<0
    w = tau-w;
end

% True anomaly
nu = acos(dot(eVec/e,rVec/r));

% Quadrant check
if vr<0
    nu = tau-nu;
end

% Orbital period
T = tau/sqrt(mu)*a^(3/2);

orbitSTruct.a = a;
orbitSTruct.e = e;
orbitSTruct.i = i;
orbitSTruct.O = O;
orbitSTruct.w = w;
orbitSTruct.nu = nu;

orbitSTruct.h = h;
orbitSTruct.T = T;

end