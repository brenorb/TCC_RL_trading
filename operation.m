classdef operation < handle
    % OPERATION
    %
    % Classe responsavel por gerar objetos operation. Cada operation
    % representa uma operacao no mercado. Ele e criado e armazenado pela
    % classe backTest. Ele armazena os finPoints dos instantes de compra e
    % venda, e posteriormente na analise de backTest ele calcula as
    % estatisticas pertinentes aquela operacao
    %
    % Ver Tambem: FINPOINT, BACKTEST
    
    % by: Dyego Soares de Araujo
    % Last Edited 01/11/2013
    properties
%% Informacoes de Compra
        % Ponto de Compra
        buyPoint;
        % Tempo de compra
        buyTime;
        % Ponto de Venda
        sellPoint;
        % Tempo de Venda
        sellTime;
        % Bandeira de Short\Long
        slFlag;
        %
        stopLoss;
        lim;
%% Estatisticas da Compra
        % Lucro\Prejuizo Obtido
        profit;
        % Lucro/Prejuizo Percentual
        profitPerc
        % Tempo em que possuiu a açao 
        holdTime;
        % Menor valor da ação no periodo
        maxDown;
        % Maior valor da ação no periodo
        maxUp;
        % Recompensa
        reward;
    end
    
    methods
%% Create Method
        function obj = operation(slFlag)
            %SLFLAG: Bandeira de Short/Long. True para Long, False para
            %Short
            obj.slFlag = slFlag; %(Influi apenas no calculo de Profit e Reward)
        end
%% Buy\Sell Functions
        % Buy
        function buy(obj, finPoint, time, lim)
            obj.buyPoint = finPoint;
            obj.buyTime = time;
            obj.stopLoss = lim*finPoint.close;
            obj.lim = lim;
        end
        % Sell
        function reward = sell(obj, finPoint, time, finData)
            obj.sellPoint = finPoint;
            reward = evaluateReward(obj);
            obj.sellTime = time;
            
            evalProfit(obj);
            evalProfitPerc(obj)
            evalHoldTime(obj);
%             maxUpDown(obj, finData)
        end 
%% Statistic Functions
        % MaxDrowDown / MaxUp
        function maxUpDown(obj, finData)
            startDate = obj.buyPoint.date;
            endDate   = obj.sellPoint.date;
            info = getInfo(finData, startDate, endDate);
            obj.maxUp = max(info.high);
            obj.maxDown = min(info.low);
        end
        
        % Evaluate Profit
        function evalProfit(obj)
            obj.profit = obj.sellPoint.close - obj.buyPoint.close;
        end
        
        % Eval Hold Time
        function evalHoldTime(obj)
            obj.holdTime = obj.sellTime - obj.buyTime;
        end
        
        % EvaluateReward
        function reward = evaluateReward(obj)
            obj.reward = 5000*(obj.sellPoint.close - obj.buyPoint.close)...
                /obj.buyPoint.close * ...
                abs((obj.sellPoint.close - obj.buyPoint.close)...
                /obj.buyPoint.close);
            reward = obj.reward;
        end

        % Evaluate Profit Percentual%
        function evalProfitPerc(obj)
            obj.profitPerc = 100*(obj.sellPoint.close - obj.buyPoint.close)...
                /obj.buyPoint.close;            
        end
        
  
    end
end