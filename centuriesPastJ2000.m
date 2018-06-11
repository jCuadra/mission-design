% centuriesPastJ2000.m

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [T] = centuriesPastJ2000(date)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
This function converts a date into centuries after J2000, used for propagating planetary ephemertides.

INPUTS:
    date    - Structure containting date with y, m, d, and UT fields

OUTPUTS:
    T       - Scalar double with output value

REQUIRES:

%}
% ----------------------------------------------

J0 = 367 * date.y - fix(7 * (date.y + fix((date.m + 9) / 12)) / 4) + fix(275 * date.m / 9) + date.d + 1721013.5;
JD = J0 + date.UT / 24;
T = (JD - 2451545) / 36525;

end
