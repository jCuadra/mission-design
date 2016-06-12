function m = ta2ma(nu,e)

% define tau
tau = 2*pi;

% calculate mean anomaly
m = 2*atan(sqrt((1-e)/(1+e))*tan(nu/2))...
    -(e*sqrt(1-e^2)*sin(nu))/(1+e*cos(nu));

% constrain value of Me between 0 and 2*pi
m = mod(m,tau);

end