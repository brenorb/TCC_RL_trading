for i = 1:petr4.tam
    close(i) =  petr4.point{i}.close;
    high(i) = petr4.point{i}.high;
    low(i)= petr4.point{i}.low;
end

for i = 1:ibov.tam
    iclose(i) =  ibov.point{i}.close;
    ihigh(i) = ibov.point{i}.high;
    ilow(i)= ibov.point{i}.low;
end