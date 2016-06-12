function dateStruct = gregDate(T)

JD = T*36525+2451545;

z = fix(JD + 0.5);
f = JD + 0.5 - z;
alpha = fix((z - 1867216.25) / 36524.25);
a = z + 1 + alpha - fix(alpha / 4);
b = a + 1524;
c = fix((b - 122.1) / 365.25);
d = fix(365.25 * c);
e = fix((b - d) / 30.6001);
day = b - d - fix(30.6001 * e) + f;
d = fix(day);
d_frac = day - d;
if e<14
    m=e-1;
else
    m=e-13;
end
if m>2
    y=c-4716;
else
    y=c-4715;
end

dateStruct.y = y;
dateStruct.m = m;
dateStruct.d = d;
dateStruct.UT = d_frac*24;


end