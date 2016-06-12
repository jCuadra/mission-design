function [pStruct] = planetState(pIndex,T)

tau = 2*pi;

pStruct = planetIndex(pIndex);

a = pStruct.a0+pStruct.ad*T;
e = pStruct.e0+pStruct.ed*T;
i = mod(pStruct.i0+pStruct.id*T, tau);
O = mod(pStruct.O0+pStruct.Od*T, tau);
w = mod(pStruct.w0+pStruct.wd*T, tau);
L = mod(pStruct.L0+pStruct.Ld*T, tau);

wa = mod(w-O, tau);
Me  = mod(L-w, tau);

nu = ma2ta(Me,e);

pStruct.a = a;
pStruct.e = e;
pStruct.i = i;
pStruct.O = O;
pStruct.w = wa;
pStruct.nu = nu;

pStruct = oe2sv(pStruct);

end