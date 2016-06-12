function h = drawPoint_Planet(axHandle, pIndex,T,form)

pStruct = planetState(pIndex,T);

h = plot3(axHandle, pStruct.r(1),pStruct.r(2),pStruct.r(3),form);

end