% animateMission.m

%%% TODO
% Change step to numberOfSteps
% Add lag to transit points instead of planets

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function animateMission(N1, N2, T1, T2, startDate, maxDuration, axHandle, dtOption, c3Option)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function draws the mission at many time steps.

INPUTS:
    N1          - Sequence of departure planets
    N2          - Sequence of arrival planets
    T1          - Sequence of departure times
    T2          - Sequence of arrival times
    startDate   - Initial date for mission (in struct)
    maxDuration - Total duration of the mission
    axHandle    - Handle for the axes to draw on

OUTPUTS:

REQUIRES:
    drawOrbit
    Orbit
    Planet

%}
% ----------------------------------------------

startTime = centuriesPastJ2000(startDate);

planetIndices = unique([N1 N2]);
numPlanets = length(planetIndices);

planets = (Planet(0));
for body = 1:numPlanets
    planets(body) = Planet(planetIndices(body), startTime);
end

phase = 0;

% Animation step in days -- must evenly divide maxDuration
step = 5;

lag = 0 * step;

h = zeros((maxDuration / step) + 1, numPlanets);

hold on
cla(axHandle)
axes(axHandle)
axis equal off

% Plot sun and orbits
plot3(axHandle, 0, 0, 0, 'yo')
for body = 1:max(planetIndices)
    drawOrbit(axHandle, body, startTime);
end
drawnow

prevTransitStep = -1;
numTransitSteps = 100;

for day = 0:step:maxDuration

    % Check phase
    if phase == 0 || day > T2(phase)
        phase = phase + 1;
        prevTransitStep = -1;

        % Initialize transit orbit
        if N1(phase) ~= N2(phase)
            planetDepart = Planet(N1(phase), startTime + T1(phase) / 36525);
            planetArrive = Planet(N2(phase), startTime + T2(phase) / 36525);
            [transfer, ~, ~] = Orbit.transferOrbit(planetDepart, planetArrive, T2(phase) - T1(phase), dtOption, c3Option);
        end
    end

    % Plot planets
    for body = 1:numPlanets
        planet = planets(body);
        if planetIndices(body) == N1(phase) && planetIndices(body) == N2(phase)
            plot3(axHandle, planet.r(1), planet.r(2), planet.r(3), 'ro');
        else
            h(day / step + 1, body) = plot3(axHandle, planet.r(1), planet.r(2), planet.r(3), 'ko');
        end
        if day > lag
            if h((day - lag) / step, body)
                delete(h((day - lag) / step, body));
            end
        end
        planet.propagateState(step);
    end

    % Plot transit
    phaseDay = day - T1(phase);
    phaseLength = T2(phase) - T1(phase);
    phaseComplete = phaseDay / phaseLength;
    if N1(phase) ~= N2(phase) && fix(numTransitSteps * phaseComplete) > prevTransitStep
        prevTransitStep = fix(numTransitSteps * phaseComplete);
        transfer = transfer.propagateState(step);
        plot3(axHandle, transfer.r(1), transfer.r(2), transfer.r(3), 'bo');
    end

    drawnow
end

end
