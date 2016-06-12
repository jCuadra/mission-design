function animateMission(N1, N2, T1, T2, startTime, maxDuration, proceedHandle, axHandle)

planets = unique([N1 N2]);
numPlanets = length(planets);

phase = 1;

% animation step in days -- must evenly divide maxDuration
step = 5;

lag = 0*step;

h = zeros((maxDuration/step)+1,numPlanets);

%set(proceedHandle,'String','Animate')
%disp(get(proceedHandle,'Value'))
%waitfor(proceedHandle,'Value',1)
input('Press Return key to watch mission animation.');

hold on
cla(axHandle)
axes(axHandle)
axis equal off

% plot sun and orbits
plot3(axHandle, 0,0,0,'yo')
for body = 1:max(planets)
    drawOrbit(axHandle, body,startTime);
end
drawnow

% 1 day/frame
for day = 0:step:maxDuration

    % check phase
    if day>T2(phase)
        phase = phase + 1;
    end

    % plot planets
    for body = 1:numPlanets
        if planets(body) == N1(phase) && planets(body) == N2(phase)
            drawPoint_Planet(axHandle, planets(body),startTime+day/36525,'ro');
        else
            h(day/step+1,body) = drawPoint_Planet(axHandle, planets(body),startTime+day/36525,'ko');
        end
        if day>lag
            if h((day-lag)/step,body)
                delete(h((day-lag)/step,body));
            end
            %h((day-lag)/step,body) = drawPoint_Planet(planets(body),startTime+(day-lag)/36525,'k.');
        end 
    end
    
    
    % plot transit
    if N1(phase) ~= N2(phase)
        drawPoint_Transit(axHandle, N1(phase),N2(phase),startTime+T1(phase)/36525,T2(phase)-T1(phase),day-T1(phase),'b.');
    end
    
    drawnow
end

end