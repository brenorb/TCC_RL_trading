%% papeis 1m
tic
bvmf3 = finData('../IBOV/BVMF3.1m','1m');
bvmf32 = finData('../IBOV/BVMF32.1m','1m');
petr4 = finData('../IBOV/PETR4.1m','1m');
petr42 = finData('../IBOV/PETR42.1m','1m');
ibov = finData('../IBOV/IBOV.1m','1m');
ibov2 = finData('../IBOV/IBOV2','1m');
winfut = finData('../IBOV/WINFUT.1m','1m');
winfut2 = finData('../IBOV/WINFUT2.1m','1m');
dolfut = finData('../IBOV/DOLFUT.1m','1m');
dolfut2 = finData('../IBOV/DOLFUT2.1m','1m');
vale5 = finData('../IBOV/VALE5.1m','1m');
vale52 = finData('../IBOV/VALE52.1m','1m');
dji = finData('../IBOV/DJI.1m','1m');
dji2 = finData('../IBOV/DJI2.1m','1m');
toc
%% Bruno 
bruno2 = backTestC(ibov_2, @backTestC.buyStratB,@backTestC.sellStratB);
runStrategy(bruno2,33000);
relatorio(bruno2)
%% HILO/STOPs Vale5 1m
bruno2 = backTestC(vale52, @backTestC.buyStratB,@backTestC.sellBpetr1m);
runStrategy(bruno2,33000);
relatorio(bruno2)

%% Bollinger
bollinger = backTestC(ibov2, @backTestC.buyBol,@backTestC.sellBol);
runStrategy(bollinger,33000);
relatorio(bollinger)

%% HiLo
hilo2 = backTestC(ibov2, @backTestC.buyHILO,@backTestC.sellHILO);
runStrategy(hilo2,33000);
relatorio(hilo2)

%% IA saida bruno
IA = backTest(ibov,@backTest.sellStratB);
runStrategy(IA,31000,1);
relatorio(IA)
%% Continuação
novoPapel(IA,ibov2);
runStrategy(IA,33000,0);
relatorio(IA)

%% IA saida hilo
IA = backTest(ibov,@backTest.sellHILO);
runStrategy(IA,31000,1);
relatorio(IA)

%% IA saida bollinger
IA = backTest(ibov,@backTest.sellBol);
runStrategy(IA,31000,1);
relatorio(IA)
%% IA
IA = backTest(petr4,@backTest.sellStratParab);
runStrategy(IA,31000,1);
% %% VALE5
% novoPapel(IA,vale5);
% a = 1
% runStrategy(IA,31000,0);
%%
IA = backTest(ibov,@backTest.sellStratParab);
runStrategy(IA,31000,1);
relatorio(IA)
%%
IA = backTest(ibov2,@backTest.sellStratParab);
runStrategy(IA,31000,1);
relatorio(IA)
%%
novoPapel(IA,ibov);
runStrategy(IA,31000,0);
relatorio(IA)
%% IBOV 2
novoPapel(IA,ibov2);
runStrategy(IA,33000,0);
relatorio(IA)
%% PETR4
novoPapel(IA,petr4);
a = 1
runStrategy(IA,29000,0);

%% DOLFUT
novoPapel(IA,dolfut);
a = a+1
runStrategy(IA,29000,0);
%% DJI
novoPapel(IA,dji);
a = a+1
runStrategy(IA,29000,0);
%%
a = a+1
novoPapel(IA,bvmf3);
runStrategy(IA,29000,0);
a = a+1
novoPapel(IA,ispfut);
runStrategy(IA,8000,0);
a = a+1
novoPapel(IA,ibov);
changeEps(IA,0);
runStrategy(IA,31000,0);
%% IBOV1
novoPapel(IA,ibov1);
runStrategy(IA,ibov1.tam-40,0);
%% Relatorio
relatorio(IA)
%%