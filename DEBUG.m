%% Script DEBUG
%% Geral
obj.time
obj.finData.point{obj.time}
getDate(obj.finPoint)
getTime(obj.finPoint)
%% Espec�fico
obj.curState - 1
[~, ~, ~, norm] = bollingerb(obj.finData, 20);
[adx,~,~] = calcDMI(obj.finData);
[trend,~,~] = hilo(obj.finData,7);
BBol = norm(obj.time)
ADX = adx(obj.time)
HILO = trend(obj.time)