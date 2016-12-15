%% Carrega os papeis
tic
% %% Diario
% bvmf3_1 = finData('bvmf3-1', 'daily');
% bvmf3_2 = finData('bvmf3-2', 'daily');
%% 60 min
cmig4_1 = finData('cmig4-1', '60m');
cmig4_2 = finData('cmig4-2', '60m');
%% 30 min
dolfut_1 = finData('dolfut-1', '30m');
dolfut_2 = finData('dolfut-2', '30m');
%% 15 min
vale5_1 = finData('vale5-1', '15m');
vale5_2 = finData('vale5-2', '15m');
%% 10 min
petr4_1 = finData('petr4-1', '10m');
petr4_2 = finData('petr4-2', '10m');
%% 5 min
dji_1 = finData('dji-1', '5m');
dji_2 = finData('dji-2', '5m');
%% 1 min
ibov_1 = finData('ibov-1', '1m');
ibov_2 = finData('ibov-2', '1m');
%% Cria as estrategias
%% Diario
% % Estrategia Classica
% BT_d = backTestC(bvmf3_2, @backTestC.buyBol, @backTest.sellBol);
% % Estrategia Inteligente
% IA_d = backTest(bvmf3_1, @backTest.sellBol);
% % Treina a estrategia inteligente
% runStrategy(IA_d, bvmf3_1.tam-40, 1);
% % Troca o Papel
% novoPapel(IA_d, bvmf3_2);
%% 60 min
% Estrategia Classica
BT_60 = backTestC(cmig4_2, @backTestC.buyBol, @backTestC.sellBol);
% Estrategia Inteligente
IA_60 = backTest(cmig4_1, @backTest.sellBol);
% Treina a estrategia inteligente
runStrategy(IA_60, cmig4_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_60, cmig4_2);
%% 30 min
% Estrategia Classica
BT_30 = backTestC(dolfut_2, @backTestC.buyBol, @backTestC.sellBol);
% Estrategia Inteligente
IA_30 = backTest(dolfut_1, @backTest.sellBol);
% Treina a estrategia inteligente
runStrategy(IA_30, dolfut_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_30, dolfut_2);
%% 15 min
% Estrategia Classica
BT_15 = backTestC(vale5_2, @backTestC.buyHILO, @backTestC.sellHILO);
% Estrategia Inteligente
IA_15 = backTest(vale5_1, @backTest.sellHILO);
% Treina a estrategia inteligente
runStrategy(IA_15, vale5_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_15, vale5_2);
%% 10 min
% Estrategia Classica
BT_10 = backTestC(petr4_2, @backTestC.buyBol, @backTestC.sellBol);
% Estrategia Inteligente
IA_10 = backTest(petr4_1, @backTest.sellBol);
% Treina a estrategia inteligente
runStrategy(IA_10, petr4_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_10, petr4_2);
%% 5 min
% Estrategia Classica
BT_5 = backTestC(dji_2, @backTestC.buyHILO, @backTestC.sellHILO);
% Estrategia Inteligente
IA_5 = backTest(dji_1, @backTest.sellHILO);
% Treina a estrategia inteligente
runStrategy(IA_5, dji_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_5, dji_2)
%% 1 min
% Estrategia Classica
BT_1 = backTestC(ibov_2, @backTestC.buyStratB, @backTestC.sellStratB);
% Estrategia Inteligente
IA_1 = backTest(ibov_1, @backTest.sellStratB);
% Treina a estrategia inteligente
runStrategy(IA_1, ibov_1.tam-40, 1);
% Troca o Papel
novoPapel(IA_1, ibov_2)

%% Roda as estrategias
% %% Diário
% runStrategy(IA_d, bvmf3_2.tam-40, 0);
% runStrategy(BT_d, bvmf3_2.tam-40);
%% 60m
runStrategy(IA_60, cmig4_2.tam - 80, 0);
runStrategy(BT_60, cmig4_2.tam - 80);
%% 30m
runStrategy(IA_30, dolfut_2.tam-40, 0);
runStrategy(BT_30, dolfut_2.tam-40);
%% 15m
runStrategy(IA_15, vale5_2.tam-40, 0);
runStrategy(BT_15, vale5_2.tam-40);
%% 10m
runStrategy(IA_10, petr4_2.tam-40, 0);
runStrategy(BT_10, petr4_2.tam-40);
%% 5m
runStrategy(IA_5, dji_2.tam-40, 0);
runStrategy(BT_5, dji_2.tam-40);
%% 1m
runStrategy(IA_1, ibov_2.tam-40, 0);
runStrategy(BT_1, ibov_2.tam-40);
%% Coleta os Resultados de maneira coerente
% %% Diário
% moneyEvol(IA_d);
% moneyEvol(BT_d);
% file_d = fopen('bvmf3/tabela.txt', 'w');
% V1_d = relatorio1(IA_d);
% V2_d = relatorio1(BT_d);
% tabelaLatex(V1_d, V2_d, file_d);

%% 60m
[IAevo,~] = moneyEvol(IA_60);
[BTevo,~] = moneyEvol(BT_60);
file_60 = fopen('cmig4/tabela.txt', 'w');
V1_60 = relatorio1(IA_60);
V2_60 = relatorio1(BT_60);
tabelaLatex(V1_60, V2_60, file_60);
figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'cmig4/compara', 'png');
    figure(6);
    plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'cmig4/match', 'png');

    close all;
%% 30m
[IAevo,~] = moneyEvol(IA_30);
[BTevo,~] = moneyEvol(BT_30);
file_30 = fopen('dolfut/tabela.txt', 'w');
V1_30 = relatorio1(IA_30);
V2_30 = relatorio1(BT_30);
tabelaLatex(V1_30, V2_30, file_30);
figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'dolfut/compara', 'png');
        figure(6);
    plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'dolfut/match', 'png');
    close all;
%% 15m
[IAevo,~] = moneyEvol(IA_15);
[BTevo,~] =moneyEvol(BT_15);
file_15 = fopen('vale5/tabela.txt', 'w');
V1_15 = relatorio1(IA_15);
V2_15 = relatorio1(BT_15);
tabelaLatex(V1_15, V2_15, file_15);
figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'vale5/compara', 'png');
        figure(6);
    plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'vale5/match', 'png');
close all;
%% 10m
[IAevo,~] = moneyEvol(IA_10);
[BTevo,~] = moneyEvol(BT_10);
file_10 = fopen('petr4/tabela.txt', 'w');
V1_10 = relatorio1(IA_10);
V2_10 = relatorio1(BT_10);
tabelaLatex(V1_10, V2_10, file_10);
figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'petr4/compara', 'png');
        figure(6);
    plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'petr4/match', 'png');
        close all;
%% 5m
[IAevo,~] = moneyEvol(IA_5);
[BTevo,~] = moneyEvol(BT_5);
file_5 = fopen('dji/tabela.txt', 'w');
V1_5 = relatorio1(IA_5);
V2_5 = relatorio1(BT_5);
tabelaLatex(V1_5, V2_5, file_5);
figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'dji/compara', 'png');
        figure(6);
    plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'dji/match', 'png');
        close all;
%% 1m
[IAevo,~] = moneyEvol(IA_1);
[BTevo,~] = moneyEvol(BT_1);
file_1 = fopen('ibov/tabela.txt', 'w');
V1_1 = relatorio1(IA_1);
V2_1 = relatorio1(BT_1);
tabelaLatex(V1_1, V2_1, file_1);
	figure(5);
[AX,~,~] = plotyy(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	set(get(AX(1),'Ylabel'),'String','Retorno do Algoritmo Inteligente em %') 
	set(get(AX(2),'Ylabel'),'String','Retorno do Algoritmo Clássico em %') 
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    saveas(5, 'ibov/compara', 'png');
figure(6);
plot(1:length(IAevo),IAevo,linspace(1,length(IAevo),length(BTevo)),BTevo);
	xlabel('Número de Operações do Algoritmo Clássico') 
	title('Retorno Clássico e Inteligente ')
    ylabel('Retorno em %')
    legend('Algoritmo Inteligente','Algoritmo Clássico','LOCATION','BEST')
    saveas(6,'ibov/match', 'png');
        close all;
%%
fclose all;
toc