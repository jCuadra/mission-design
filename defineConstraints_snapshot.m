
%%% Indequalities

%%% 1 Minimum number of Transits equal to number of planets
%%% 2  Depart from each Planet at least once
%%% 3 Arrive at each Planet at least once
%%% 4 Only One Event Can Begin at Each Time
%%% 5 Only One Event Can End at Each Time
%%% 6 Limit Orbit Time to Zero or One



%%% Equalities

%%% 1 Home Planet Must Be First
%%% 2 Target Planet Must Be Last
%%% 3 Time Pairs Must Match

function [Ai_x, Ae_x] = defineConstraints(mi,me,t1,t2,n1_index,n2_index,t1_index,startPlanetIndex,endPlanetIndex,arriveTimeVector,departTimeVector,numberOfPlanets)

Ai_x = zeros(sum(mi),1);
Ae_x = zeros(sum(me),1);
t2_c = find(arriveTimeVector==t2);

%%% Indequalities

%%% 1. Minimum number of Transits equal to number of planets (or 1 less if
%%% non-return)
% Greater than or Equal to

if n1_index ~= n2_index
    Ai_x(1) = -1;
end



%%%2.  Depart from each Planet at least once (unless end planet of
%%%nonreturn mission)
% Greater than or Equal to
if n1_index ~= n2_index
    Ai_x(mi(1)+n1_index) = -1;
end



%%% 3. Arrive at each Planet at least once (unless start planet of
%%% nonreturn mission)
% Greater than or Equal to

if n1_index ~= n2_index
    Ai_x(sum(mi(1:2))+n2_index) = -1;
end



%%% 4. Only One Event Can Begin at Each Time
% Less than or Equal to
Ai_x(sum(mi(1:3))+t1_index) = 1;



%%% 5. Only One Event Can End at Each Time
% Less than or Equal to
Ai_x(sum(mi(1:4))+t2_c) = 1;



%%% 6. Limit Orbit Time to Zero or One
% Less than or Equal to

%if n1_index == n2_index
    %if ~nonReturn && t2~=arriveTimeVector(end)
    %    Ai_x(sum(mi(1:5))+numberOfPlanets) = 1;
%elseif  ~nonReturn && t2~=arriveTimeVector(end)
    %else
%        Ai_x(sum(mi(1:5))+n1_index) = 1;
    %end
%end




%%% Equalities


%%% 1 Home Planet Must Be First
if n1_index == startPlanetIndex && t1 == departTimeVector(1)
    Ae_x(1) = 1;
end

%%% 2 Target Planet Must Be Last
if n2_index == endPlanetIndex && t2 == arriveTimeVector(end)
    Ae_x(2) = 1;
end

%%% 3 Time Pairs Must Match
if t1_index ~= 1
    Ae_x(me(1)+(length(departTimeVector)-1)*(n1_index-1)+(t1_index-1)) = 1;
end

if t2~=arriveTimeVector(end)
    Ae_x(me(1)+(length(departTimeVector)-1)*(n2_index-1)+t2_c) = -1;
end


end