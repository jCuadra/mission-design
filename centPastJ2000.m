function T = centPastJ2000(date)

J0 = 367*date.y - fix(7*(date.y+fix((date.m+9)/12))/4) + fix(275*date.m/9) + date.d + 1721013.5;
JD = J0 + date.UT/24;
T = (JD-2451545)/36525;

end