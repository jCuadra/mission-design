% drawOrbit.m

%%% TODO
% Consider removing T0, 0 should be fine

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function drawOrbit(axHandle, planetIndex, T0)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function draws the orbit of a planet.

INPUTS:
    axHandle    - Handle of axes to draw orbit in
    planetIndex - Index of planet to draw
    T0          - Epoch at which to draw orbit (in centuries after J2000)

OUTPUTS:

REQUIRES:
    Planet

%}
% ----------------------------------------------

tau = 2 * pi;

planet = Planet(planetIndex, T0);

nu = linspace(0, tau, 361);
r = zeros(361, 3);

for deg = 0:360
    planet.nu = nu(deg + 1);
    r(deg + 1, :) = planet.r;
end

plot3(axHandle, r(:, 1), r(:, 2), r(:, 3), 'k')

end
