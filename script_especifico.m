% script para debug no metatrader
%% Papeis 1m
tic
% bvmf3 = finData('../IBOV/BVMF3.1m','1m');
% bvmf32 = finData('../IBOV/BVMF32.1m','1m');
% petr4 = finData('../IBOV/PETR4.1m','1m');
% petr42 = finData('../IBOV/PETR42.1m','1m');
petr4 = finData('../IBOV/PETR4M1.1m.debug','1m');
petr42 = finData('../IBOV/PETR4M2.1m','1m');
% wdon = finData('../IBOV/WDON.1m','1m');
% wdon2 = finData('../IBOV/WDON.1m2','1m');
% wdon5 = finData('../IBOV/WDON.5m','5m');
% wdon52 = finData('../IBOV/WDON.5m2','5m');
% ibov = finData('../IBOV/IBOV.1m','1m');
% ibov2 = finData('../IBOV/IBOV2','1m');
% winfut = finData('../IBOV/WINFUT.1m','1m');
% winfut2 = finData('../IBOV/WINFUT2.1m','1m');
% dolfut = finData('../IBOV/DOLFUT.1m','1m');
% dolfut2 = finData('../IBOV/DOLFUT2.1m','1m');
% vale5 = finData('../IBOV/VALE5.1m','1m');
% vale52 = finData('../IBOV/VALE52.1m','1m');
% dji = finData('../IBOV/DJI.1m','1m');
% dji2 = finData('../IBOV/DJI2.1m','1m');
toc
%% IA 
IA = backTest(petr4,@backTest.sellHILO);
runStrategy(IA,31400,1);
relatorio(IA)
%% Continuação
novoPapel(IA,petr42);
runStrategy(IA,33700,0);
relatorio(IA)
%% IA saida bruno
% IA = backTest(wdon5,@backTest.sellHILO);
% runStrategy(IA,9900,1);
% relatorio(IA)
% %% Continuação
% novoPapel(IA,wdon52);
% runStrategy(IA,9000,0);
% relatorio(IA)
% %% DEBUG IA
% IA = backTestDEBUG(wdon5,@backTestDEBUG.sellHILO);
% runStrategy(IA,9900,1);
% relatorio(IA)
% %% Continuação
% novoPapel(IA,wdon52);
% runStrategy(IA,9000,0);
% relatorio(IA)