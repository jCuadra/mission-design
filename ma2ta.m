function nu = ma2ta(m,e)

tau = 2*pi;

if m > tau/2
   m = m-tau;
end

f = @(theta) 2*atan(sqrt((1-e)/(1+e))*tan(theta/2))...
    -(e*sqrt(1-e^2)*sin(theta))/(1+e*cos(theta))-m;

nu = fsolve(f,m,optimset('Display','off'));

nu = mod(nu,tau);

end