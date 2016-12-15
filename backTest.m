classdef backTest < handle
    % BACKTEST
    %
    % obj = backTest(finData, sellStrategy)
    % Classe responsavel por gerar o objeto backTest. O backTest e uma
    % estrutura capaz de avaliar estrategias de mercado utilizando dados
    % financeiros a ele fornecidos. Sua finalidade e gerar um relatorio de
    % avaliacao desta estrategia, mostrando o quao bem esta se saiu neste
    % dado periodo
    %
    % Ver Tambem: FINDATA, FINPOINT, OPERATION
    
    % by: Dyego Soares de Araujo
    % Last Edited 22/11/2013
    properties
%% Informacoes Principais
        % Objeto Contendo o R-Learn
        rLearnObj;
        % Function Handle da Estrategia de Saida
        sellStrat;
        % Objeto FinData que contem a informacao da bolsa
        finData;
        % Vetor de Controle de Operaçoes
        operate;
        % Vetor de Estados
        state;
%% Variaveis de Controle
        % Variavel de controle Temporal
        time;
        initTime;
        % Operação atual
        currentOp;
        % Ponto de Mercado Atual
        finPoint;
        % Estado atual
        curState;
        % Variavel Comprado/Vendido
        byslFlag;
        transit;
        % Recompensa Passada
        reward;
    end
    
    methods
%% Create Method
        function obj = backTest(finData, sellStrategy)
            %STATE: Objeto gerador de estados
            obj.state = estado(finData);
            
            %RLEARN: Objeto que contem o sistema inteligente munido de
            %Reinforcement Learning, que sera treinado nos pontos adequados
            %de entrada do mercado.
            % Parametros:
            %%%%%%%%%%%%%% PESQUISAR VALORES ADEQUADOS %%%%%%%%%%%%%%%%%%%%
            NESTADO = obj.state.getN;
%             NNEURON = 30;
            EPSILON = 10;
            GAMMA   = .7;
            LAMBDA  = .6;
            ALPHA   = .08;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.rLearnObj = rLearn(NESTADO, EPSILON,...
                ALPHA, GAMMA, LAMBDA);
            
            %SELLSTRAT: Function Handle contendo a estrategia de Saida do
            %Mercado.
            obj.sellStrat = sellStrategy;
            
            %FINDATA: Contem todas as informacoes financeiras pertinentes,
            %alem das ferramentas de calculo de parametros
            obj.finData  = finData;
            
            %OPERATE: Cell de registro de operacoes. Cada cell contem uma
            %operation. Cada operation posteriormente sera analisada e
            %estudada separadamente
            obj.operate = cell(0);
            
            %TIME: variavel que controla passagem do tempo
            obj.time = 0;
            obj.initTime = 40;
            
            %BYSLFLAG: Variavel que indica se a estrategia esta dentro ou 
            %fora do mercado. 0 para fora do mercado, 1 para dentro do 
            %mercado
            obj.byslFlag = 0;
            obj.transit = 0;
            
        end
%% Run Strategy
        % RunStrategy: Roda um número N de steps
        function runStrategy(obj, N, init)
            if init
                initStep(obj);
            end
            for i = 1:N
                normStep(obj);
            end
            fprintf('\n');
        end
%% Steps
        % Init Step: Passo inicial de configuracao
        function initStep(obj)
            % Zera o Tempo
            obj.time = obj.initTime;
            % Coleta o Primeiro finPoint
            obj.finPoint = obj.finData.point{obj.time};
            % Gera o primeiro estado
            obj.curState = getEstado(obj.state, obj.time);
            % Toma a Primeira acao - (por padrao: Nao Comprar)
            obj.byslFlag = false;
            % Inicializa o rLearn - (Registra primeiro estado)
            initLearn(obj.rLearnObj, obj.curState, obj.byslFlag);
            % Primeira Recompensa: 0
            obj.reward = 0;
            
        end
        
        % Normal Step: Roda um passo da simulacao
        function normStep(obj)
            % Passa o tempo
            obj.time = obj.time+1;
            % Coleta um novo finPoint
            obj.finPoint = obj.finData.point{obj.time};
            % Gera um novo Estado
            obj.curState = getEstado(obj.state,obj.time);
            oldState = getEstado(obj.state,obj.time-1);
            s = [oldState, obj.curState];
            % Verifica a situacao atual da estrategia
            if obj.byslFlag
                % Se estiver Dentro do Mercado, roda a estrategia de Saida
                obj.byslFlag = obj.sellStrat(obj.finPoint, obj.currentOp,s);
                % Se a estrategia pediu para vender
                if ~obj.byslFlag
                    % Venda e Colete recompensa
                    obj.reward = sellLong(obj);
                    reward = obj.reward;
                    % Zera a Eligibilidade
                    obj.transit = 1;
 %                    resetE(obj.rLearnObj);
                end
            else
                % Se estiver fora do mercado, rode o rLearn:
                obj.byslFlag = makeChoice(obj.rLearnObj, obj.curState);
                % Registra o par Estado / Acao
                register(obj.rLearnObj, obj.curState, obj.byslFlag);
                % Atualiza Tabela E
                updateE(obj.rLearnObj);
                % Atualizar Tabela Q
                updateQ(obj.rLearnObj, obj.reward);
                % Se acabou de vender, zera a eligibilidade
                if obj.transit
                    obj.transit = 0;
                    resetE(obj.rLearnObj);
                end
                % Recebe a Recompensa Passada 
                obj.reward = 1;
                % Registra a compra
                if obj.byslFlag
                    buyLong(obj);
                end
            end
        end
        %%
        % Change Epsilon
        function changeEps(obj,newEps)
            obj.rLearnObj.epsilon = newEps;
        end
        % Novo Papel para operar
        function novoPapel(obj,newFinData)
            % reseta o tempo e outros parâmetros
            obj.time = obj.initTime;
            obj.operate = cell(0);
            obj.byslFlag = 0;
            obj.transit = 0;
            % novo papel
            obj.finData = newFinData;
            % novos estados
            obj.state = estado(newFinData);
            % Coleta o Primeiro finPoint
            obj.finPoint = obj.finData.point{obj.time};
            % Gera o primeiro estado
            obj.curState = getEstado(obj.state, obj.time);
            
        end
%% Operations
        % Buy
        function buyLong(obj)
            % Cria uma nova operação
            obj.currentOp = operation(true);
            % Limite StopLoss
            lim = 0.999;
            % Efetua a compra
            buy(obj.currentOp, obj.finPoint, obj.time,lim);
        end
        % Sell
        function reward = sellLong(obj)
            % Efetua a Venda
            reward = sell(obj.currentOp, obj.finPoint, obj.time);
            % Registra a compra
            obj.operate = [obj.operate obj.currentOp];
        end
        %% Relatorio
    function [profits, profitsPerc, holdTime,NOT] = getProfit(obj)
        profits = zeros(1,length(obj.operate));
        profitsPerc = zeros(1,length(obj.operate));
        holdTime = zeros(1,length(obj.operate));
        for i = 1:length(obj.operate)
            profits(i) = obj.operate(i).profit;
            holdTime(i) = obj.operate(i).holdTime;
            profitsPerc(i) = obj.operate(i).profitPerc;
        end
        NOT = length(obj.operate);
    end
    
    function [evolperc, evol2] = moneyEvol(obj)
        [profits, profitsPerc, ~,NOT] = getProfit(obj);
        evolperc = zeros(1,NOT+1);
        evol2 = zeros(1,NOT+1);
        evolperc(1) = 100;
        for i = 1:NOT
            evolperc(i+1) = evolperc(i) * (1 + profitsPerc(i)/100); 
        end
        for i = 1:NOT
            evol2(i+1) = evol2(i) + (profits(i)); 
        end
        papel = obj.finData.name{1};
        if (exist(papel, 'dir')~=7)
            mkdir(papel);
        end
        % Salva as figuras
        figure(1);
        plot(evol2)
        title(papel)
        xlabel('Número de Operações')
        ylabel('Valor Monetário')
        nome = [papel '/' obj.finData.gran 'MonEvoIA.png'];
        saveas(1, nome, 'png');
        
        figure(2);
        plot(evolperc)
        title([papel,' percentual'])
        xlabel('Número de Operações')
        ylabel('Valor Percentual')
        nome = [papel '/' obj.finData.gran 'MonPerIA.png'];
        saveas(2, nome, 'png');
        
        figure(3);
        hist(profitsPerc,100)
        title([papel,' Ocorrencias'])
        ylabel('Ocorrências')
        xlabel('Valor do Trade')
        nome = [papel '/' obj.finData.gran 'OcorrIA.png'];
        saveas(3, nome, 'png');
        
        figure(4)
        Q = obj.rLearnObj.Q;
        % hilo baixo manutencao
        subplot(2,2,1)
        image(Q(:,:,1,1)*50)
        title('HiLo Baixo - Ação Espera')
        xlabel('Bandas de Bollinger normalizadas')
        ylabel('ADX normalizado')
        colorbar
        % hilo baixo compra
        subplot(2,2,2)
        image(Q(:,:,1,2)*50)
        title('HiLo Baixo - Ação Compra')
        xlabel('Bandas de Bollinger normalizadas')
        ylabel('ADX normalizado')
        colorbar
        % hilo alto manutencao
        subplot(2,2,3)
        image(Q(:,:,2,1)*50)
        title('HiLo Alto - Ação Espera')
        xlabel('Bandas de Bollinger normalizadas')
        ylabel('ADX normalizado')
        colorbar
        % Hilo alto compra
        subplot(2,2,4)
        image(Q(:,:,2,2)*50)
        title('HiLo Alto - Ação Compra')
        xlabel('Bandas de Bollinger normalizadas')
        ylabel('ADX normalizado')
        colorbar
        nome = [papel '/' obj.finData.gran 'TabelaQ.png'];
        saveas(4, nome, 'png');
        close all    
    end
    
    function BH = buyHold(obj)
        BH = obj.operate(end).sellPoint.close - obj.finData.point{40}.close;
    end
    % Total Net Profit
    % Evaluate Gross Profit
    % Evaluate Gross Loss
    function [NP, GP, GL] = netGrossProfitLoss(obj)
        [profits, ~, ~,~] = getProfit(obj);
        NP = sum(profits);
        GP = sum(profits .*(profits > 0));
        GL = sum(profits .*(profits < 0));
    end
    
    % Evaluate Profit Factor
    function PF = profitFactor(obj)
        [~, GP, GL] = netGrossProfitLoss(obj);
        PF = abs(GP/GL);
    end

    % Evaluate Total Number of trades
    function NOT = numOfTrades(obj)
        [~,~,~,NOT] = getProfit(obj);
    end
    
    % Percent Profitable
    function PP = percProfitable(obj)
        [profits, ~,~,~] = getProfit(obj);
        PP = 100 * mean(profits>0);
    end
    
    % Winning trades
    % Losing trades
    function [WT, LT] = winLostTrades(obj)
        [profits, ~,~,~] = getProfit(obj);
        WT = sum(profits > 0);
        LT = sum(profits < 0);
    end
    
    % Avg. trade net profit
    % Avg. Win
    % Avg. Loss
    % Ratio avgWIN/avgLOSS
    function [avgNET, avgWIN, avgLOSS, ratio] = avgNetWinLossTrades(obj)
        [profits, ~,~,~] = getProfit(obj);
        avgNET = mean(profits);
        [~, GP, GL] = netGrossProfitLoss(obj);
        noWIN = sum(profits>0);
        avgWIN = GP/noWIN;
        noLOSS = sum(profits<0);
        avgLOSS = GL/noLOSS;
        ratio = abs(avgWIN/avgLOSS);
    end
    
    % Largest winning trade
    % Largest Losing trade
    function [LW, LL] = largestWinLoss(obj)
        [profits, ~,~,~] = getProfit(obj);
        LW = max(profits);
        LL = min(profits);
    end
    
    % Maximum consecutive winning trades
    % Maximum consecutive losing trades
    function [MW, ML] = consecWLTrades(obj)
        [profits, ~, ~, ~] = getProfit(obj);
        win = profits > 0;
        lose = ~win;
        nwin = 0;
        MW = 0;
        ML = 0;
        nlose = 0;
        for i = 1:length(win)
            if win(i)
                nwin = nwin + win(i);
            else
                nwin = 0;
            end
            
            if MW < nwin
                MW = nwin;
            end
            
            if lose(i)
                nlose = nlose + lose(i);
            else
                nlose = 0;
            end
            
            if ML < nlose
                ML = nlose;
            end
        end
    end

    % Avg bars in total trades
    % Avg bars in Winning trades
    % Avg bars in Losing trades
    function [avgTotT, avgWT, avgLT] = avgBars(obj)
        [profits, ~, holdTime,~] = getProfit(obj);
        avgTotT = mean(holdTime);
        win = profits > 0;
        lose = ~win;
        avgWT = sum(holdTime.*win)/sum(win);
        avgLT = sum(holdTime.*lose)/sum(lose);
    end
    
    % Max Drawdown
    function [maxDD, data] = maxDrawdown(obj)
        maxUp = zeros(1,length(obj.operate));
        maxDown = zeros(1,length(obj.operate));
        for i = 1:length(obj.operate)
            maxUp(i) = obj.operate(i).maxUp;
            maxDown(i) = obj.operate(i).maxDown;
        end
        drawdowns = maxUp - maxDown;
        [maxDD, ind] = max(drawdowns);
        data = obj.operate(ind).buyTime;
    end
    
%     function esp = esperanca(obj)
%         PP = percProfitable(obj);
%         pw = PP/100;
%         pl = 1-pw;
%         [~, avgWIN, avgLOSS, ~] = avgNetWinLossTrades(obj);
%         esp = pw * avgWIN - pl* abs(avgLOSS);
%     end
    
    function sr = sharpeRatio(obj)
%         esp = esperanca(obj);
        [profits, ~, ~,~] = getProfit(obj);
        sr = mean(profits)/std(profits);
    end
        

    % Evaluate Profit Percentual%
    function relatorio(obj)
        papel = obj.finData.name{1};
        fprintf('Papel usado: \t\t\t%s\n',papel)
        gran = obj.finData.gran;
        fprintf('Granularidade: \t\t\t%s\n',gran)
        date1 = datestr(obj.finData.point{obj.initTime}.date);
        date2 = datestr(obj.finData.point{obj.time}.date);
        fprintf('Data de inicio: \t\t%s\nData de termino: \t\t%s\n',date1,date2)
        [NP, GP, GL] = netGrossProfitLoss(obj);
        fprintf('Total Net Profit: \t\t%f \nGross Profit: \t\t\t%f \nGross Loss: \t\t\t%f\n',...
            NP,GP,GL)
            % Evaluate Profit Factor
            
        PF = profitFactor(obj);
        % Total Number of trades
        NOT = numOfTrades(obj);
        fprintf('Profit Factor: \t\t\t%f\nTotal Number of trades: \t%f\n',...
            PF,NOT)
        % Percent Profitable
    	PP = percProfitable(obj);
        % Winning trades
        % Losing trades
        [WT, LT] = winLostTrades(obj);
        fprintf('Percent Profitable: \t\t%f\nWinning trades: \t\t\t%f\n',...
            PP,WT)
        [avgNET, avgWIN, avgLOSS, ratio] = avgNetWinLossTrades(obj);
        fprintf('Losing trades: \t\t\t%f\nAvg. Trade Net Profit: \t\t\t%f\n',...
            LT,avgNET)
        fprintf('Avg. Winning Trade: \t\t%f\nAvg. Losing Trade: \t\t%f\n',...
            avgWIN,avgLOSS)
        % Largest winning trade
        % Largest Losing trade
        [LW, LL] = largestWinLoss(obj);
        fprintf('Ratio Avg. Win/Avg. Loss: \t\t%f\nLargest winning trade: \t\t%f\n',...
            ratio,LW)
        % Maximum consecutive winning trades
        % Maximum consecutive losing trades
        [MW, ML] = consecWLTrades(obj);
        fprintf('Largest Losing trade: \t\t%f\nMax. consecutive winning trades: \t\t%d\n',...
            LL,MW)
        % Avg bars in total trades
        % Avg bars in Winning trades
        % Avg bars in Losing trades
        [avgTotT, avgWT, avgLT] = avgBars(obj);
        fprintf('Max. consecutive losing trades: \t\t%f\nAvg. bars in total trades: \t\t%f\n',...
            ML,avgTotT)
        fprintf('Avg. bars in Winning trades: \t\t%f\nAvg. bars in Losing trades: \t\t%f\n',...
            avgWT,avgLT)
        % Max Drawdown
%     	[maxDD, data] = maxDrawdown(obj);
%         fprintf('Max Drawdown: \t\t%f\n Date of Max Drawdown: \t\t%f\n',...
%             maxDD,data)
%         relatorio = 0;
        % Sharpe Ratio
        sharpe = sharpeRatio(obj);
        fprintf('Sharpe Ratio: \t\t%f\n',sharpe)
        BH = buyHold(obj);
        fprintf('Estrategia Buy and Hold no mesmo periodo: \t\t%f\n',BH)
        [~] = moneyEvol(obj);
    end
    
    function vec = relatorio1(obj)
        vec = cell(25, 1);
        vec{1} = obj.finData.name{1};
        vec{2} = obj.finData.gran;
        vec{3} = datestr(obj.finData.point{obj.initTime}.date);
        vec{4} = datestr(obj.finData.point{obj.time}.date);
        [vec{5}, vec{6}, vec{7}] = netGrossProfitLoss(obj);    
        vec{8} = profitFactor(obj);
        % Total Number of trades
        vec{9} = numOfTrades(obj);
    	vec{10} = percProfitable(obj);
        % Winning trades
        % Losing trades
        [vec{11}, vec{12}] = winLostTrades(obj);
        [vec{13}, vec{14}, vec{15}, vec{16}] = avgNetWinLossTrades(obj);
        % Largest winning trade
        % Largest Losing trade
        [vec{17}, vec{18}] = largestWinLoss(obj);
        % Maximum consecutive winning trades
        % Maximum consecutive losing trades
        [vec{19}, vec{20}] = consecWLTrades(obj);
        % Avg bars in total trades
        % Avg bars in Winning trades
        % Avg bars in Losing trades
        [vec{21}, vec{22}, vec{23}] = avgBars(obj);
        % Max Drawdown
%     	[maxDD, data] = maxDrawdown(obj);
%         fprintf('Max Drawdown: \t\t%f\n Date of Max Drawdown: \t\t%f\n',...
%             maxDD,data)
%         relatorio = 0;
        % Sharpe Ratio
        vec{24} = sharpeRatio(obj);
        vec{25} = buyHold(obj);
    end
%% Plots
    % Plot Final
    function plotBack(obj)
        plot(obj.finData);
        hold on
        for i = 1:length(obj.operate)
            plot(obj.operate(i).buyTime, obj.operate(i).buyPoint.close, 'b^');
            plot(obj.operate(i).sellTime, obj.operate(i).sellPoint.close, 'rv');
        end
        hold off
    end
    end
    
    methods (Static)
        function flag = sellStratParab(finP, oper,~)
            % Parametros:
            % Stop Loss
            flag = ~(finP.low < oper.stopLoss);
            if flag
                if finP.high*oper.lim > oper.stopLoss
                    oper.stopLoss = finP.high*oper.lim;
                end
                if finP.close < oper.stopLoss
                    flag = 0;        
                end        
            end
        end
        
        function flag = sellStratB(finP, oper,~)
            % Parametros:
            % Stop Loss
            LOSS = 165;
            % Stop Gain
            GAIN = 25;
            % Estrategia de Venda:
            % Caso close ultrapasse o stopLoss, venda
            flag1 = oper.buyPoint.close > finP.low + LOSS;
            % Caso close ultrapasse o stopGain, venda
            flag2 = oper.buyPoint.close < finP.high - GAIN;
            % Venda apenas se ocorrer uma das duas hipoteses
            flag = ~(flag1||flag2);
        end
    
        function flag = buyStratB(~, ~, s)
            % Parametros:
            % -
            % Estrategia de Compra:
%             [trend, ~, ~] = hilo(finData, N);
            % Caso o ocorra uma tendencia de subida, compra.
            if s(3,2) > s(3,1)
                flag = 1;
            else
                flag = 0;
            end
        end
        
        function flag = sellBvale1m(finP, oper, ~)
            % Parametros:
            % Stop Loss
            LOSS = 0.0077;
            % Stop Gain
            GAIN = 35e-4;
            % Estrategia de Venda:
            % Caso close ultrapasse o stopLoss, venda
            flag1 = oper.buyPoint.close > finP.low + finP.low*LOSS;
            % Caso close ultrapasse o stopGain, venda
            flag2 = oper.buyPoint.close < finP.high - finP.low*GAIN;
            % Venda apenas se ocorrer uma das duas hipoteses
            flag = ~(flag1||flag2);
        end
        
        function flag = sellHILO(~, ~, s)
            % Estrategia de Compra:
%             [trend, ~, ~] = hilo(finData, N);
            % Caso o ocorra uma tendencia de subida, compra.
            if s(3,2) < s(3,1)
                flag = 0;
            else
                flag = 1;
            end
        end
        
        function flag = buyHILO(~, ~, s)
            % Parametros:
            % -
            % Estrategia de Compra:
%             [trend, ~, ~] = hilo(finData, N);
            % Caso o ocorra uma tendencia de subida, compra.
            if s(3,2) > s(3,1)
                flag = 1;
            else
                flag = 0;
            end
        end
                
        function flag = sellBol(~, ~, s)
            % 
%             [~, ~, ~, norm] = bollingerb(finData, N);
            if s(1,2) > 11;
                flag = 0;
            else
                flag = 1;
            end
        end
        
        function flag = buyBol(~, ~, s)
            % 
%             [~, ~, ~, norm] = bollingerb(finData, N);
            if s(1,2) < 7;
                flag = 1;
            else
                flag = 0;
            end
        end
    end
end