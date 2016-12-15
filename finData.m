classdef finData < handle
    % FINDATA
    %
    % Classe responsavel por gerar objetos finData. Um objeto finData
    % contem informacoes pertinentes a um determinado papel ou acao. Alem
    % disso, finData possui todas as funcoes responsaveis pelo calculo dos
    % indicadores mais comuns utilizados no mercado
    %
    % Ver tambem: FINPOINT
    
    % by: Dyego Soares de Araújo
    % by: Breno Rodrigues Brito
    % Last Edited: 20/11/2013
    properties
        % Name of the Paper
        name;
        % Granularity of Paper
        gran;
        % Number of Known Points
        tam;
        % Cell of finPoints
        point;
    end
    
    methods
%% Create method
        function obj = finData(path, gran)
            %% Imports finance data from .csv File
            info = finData.importFinance(path, gran);
            %% Put data into object
            obj.gran = gran;
            obj.name = info{1}(1);
            obj.tam = length(info{1});
            %% Make data point vector
            obj.point = cell(obj.tam, 1);
            for i=1:obj.tam
                if strcmp(gran, 'daily')
                    obj.point{obj.tam - i + 1} = finPoint(info{2}(i), NaN, info{3}(i), ...
                        info{4}(i), info{5}(i), info{6}(i), info{7}(i), ...
                        info{8}(i));
                else
                    obj.point{obj.tam - i + 1} = finPoint(info{2}(i), info{3}(i), ...
                        info{4}(i), info{5}(i), info{6}(i), info{7}(i), ...
                        info{8}(i), info{9}(i));
                end
            end
        end
            
%% Indicators: 
        %% Volume Based
        % On Balance Volume [-inf,inf]
        function obvVec = obv(obj)
            % Inicializa o obvVec
            obvVec = zeros(obj.tam, 1);
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % OBV: Primeiro valor nulo:
            obvVec(1) = 0;
            % Cada valor subsequente
            for i = 2:obj.tam
                % Checa se houve crescimento ou decrescimento
                if info.close(i) > info.close(i-1)
                    % Em caso de Crescimento: Acrescente volume ao OBV
                    obvVec(i) = obvVec(i-1) + info.volume(i);
                else
                    % Em caso de Decrescimento: subtraia volume do OBV
                    obvVec(i) = obvVec(i-1) - info.volume(i);
                end    
            end
        end
        % A/D Line
        function adVec = adline(obj)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % A/D LINE:
            adVec = (info.close - info.open)./(info.high - info.low).*info.volume; 
        end
        % A/D Line Cummulative
        function adcumVec = adlinecum(obj)
            % Calcula o A/D Line
            info = adline(obj);
            % Efetua Soma Cumulativa
            adcumVec(1) = 0;
            adcumVec(2:end) = cumsum(info);
        end
        %% Oscilators
        % New High / New Low
        function nhnlVec = nhnl(obj)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % NEW HIGH / NEW LOW
            % Subtrai o high do low de hoje
            nhnlVec = info.high - info.low;
        end
        % Highest High / Lowest Low
        function [hhVec, llVec] = hhll(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % Completa os vetores de High e de Low
            highVec = zeros(obj.tam + N - 1, 1);
            lowVec = ones(obj.tam + N - 1, 1)*max(info.high);
            
            % Coloca as informações nos vetores highVec e lowVec
            highVec(N:end) = info.high;
            lowVec(N:end) = info.low;
            
            % Inicializa os vetores
            hhVec = zeros(obj.tam, 1);
            llVec = ones(obj.tam, 1);
            
            % Roda o vetor pesquisando o maximo dos N dias passados
            for i = 1:obj.tam
                hhVec(i) = max(highVec(i:i+N-1));
                llVec(i) = min(lowVec(i:i+N-1));
            end
        end
        % Williams [0-100]
        function wilVec = williams(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            % Extrai os sinais Highest High e o Lowest Low
            [hhVec, llVec] = hhll(obj, N);
            
            % Calcula o williams
            wilVec = 100*(hhVec - info.close')./(hhVec - llVec);
        end
        % Stochastic [0-100]
        function [kVec, dVec, slwVec]  = stochastic(obj, N, smthPar)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            % Extrai os sinais Highest High e o Lowest Low
            [hhVec, llVec] = hhll(obj, N);
            
            % Calcula o raw Stochastic
            kVec = 100*(info.close' - llVec)./(hhVec - llVec);
            
            % Suaviza kVec com smthPar
            dVec = movAvg(kVec, 'smp',  smthPar);
            
            % Suaviza dVec c om smthPar
            slwVec = movAvg(kVec, 'smp', smthPar);
        end
        % Bollinger
        function [mid, up, down, norm] = bollingerb(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % Calcula as Bollinger Bands
            [mid, up, down] = bollinger(info.close, N);
            % Calcula o normalizado
            norm = 100*(info.close' - down)./(up-down);
        end
        %% Trend Following
        function [trend, hi, lo] = hilo(obj,N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            % Inicializa os vetores de High e de Low
            hi = zeros(obj.tam, 1);
            lo = zeros(obj.tam, 1);
            % inicializa o trend
            trend = zeros(obj.tam,1);
            % Roda o vetor pesquisando o maximo dos N dias passados
            for i = N:obj.tam
                % se esta antes TOURO E fecha abaixo da média dos minimos
                % OU se está antes URSO E fecha abaixo da média dos maximos
                if (trend(i-1) && (info.close(i-1) < lo(i-1))) ||...
                        ((~trend(i-1)) && (info.close(i-1) > hi(i-1)))
                    % inverte a tendencia
                    trend(i) = ~trend(i-1);
                else
                    % senao, mantem constante
                    trend(i) = trend(i-1);
                end
                % calcula o hilo do passo seguinte
                hi(i) = mean(info.high(i-N+1:i));
                lo(i) = mean(info.low(i-N+1:i));
            end
        end      
        %% Momentum and Rate of Change
        % Momentum
        function momVec = momentum(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % Extrai a diferença entre os preços de hoje e de N dias atras
            momVec = finData.movAvg(info.close, 'diff', N);
        end
        % Rate of Change
        function rocVec = roc(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % Divide o preço de hoje pelo de N dias atras:
            % Tome o logaritmo dos preços
            vec = log(info.close);
            % Subtraia o preço de hoje pelo de N dias atras
            vec = finData.movAvg(vec, 'diff', N);
            % Tome a exponencial
            rocVec = exp(vec);
        end
        % Smoothed Rate of Change
        function srocVec = sroc(obj, N)
            % Coleta informacoes do objeto
            info = getInfo(obj); 
            
            % Calcula a media movel de 13 dias
            ema13 = finData.movAvg(info.close, 'exp', 13);
            
            % Calcula o RoC sobre a media movel:
            % Divide o preço de hoje pelo de N dias atras:
            % Tome o logaritmo dos preços
            vec = log(ema13);
            % Subtraia o preço de hoje pelo de N dias atras
            vec = finData.movAvg(vec, 'diff', N);
            % Tome a exponencial
            srocVec = exp(vec);
        end
        %% MACD System
        % MACD
        function [macdLine, signal] = macd(obj)
            % Coleta informacoes do objeto
            info = getInfo(obj);
            
            % MACD
            % Media Movel exponencial de 12 dias (closing)
            ema12 = finData.movAvg(info.close, 'exp', 12);
            % Media Movel exponencial de 26 dias (closing)
            ema26 = finData.movAvg(info.close, 'exp', 26');
            % Subtrair as duas
            macdLine = ema26 - ema12;
            % Suavizar com Media Movel Exponencial de 9 dias
            signal = finData.movAvg(macdLine, 'exp', 9);
        end
        % MACD Histogram
        function macdVec = macdhistogram(obj)
            % Calculate MACD
            [macdLine, signal] = macd(obj);
            % Subtract MACD from Signal Line
            macdVec = macdLine - signal;
        end
        %% Directional System
%         % Directional Movement
%         function [dmP, dmN] = dmov(obj)
%             % Coleta informacoes do objeto
%             info = getInfo(obj);
%             
%             % Calcula high de hoje - high de ontem
%             dmP = finData.movAvg(info.high, 'diff', 2);
%             % Calcula low de hoje - low de ontem
%             dmN = -finData.movAvg(info.low, 'diff', 2);
%             
%             % Valores negativos são zerados
%             dmP(dmP<0) = 0;
%             dmN(dmN<0) = 0;
%             
%         end
%         % True Range
%         function trVec = truerange(obj)
%             % Coleta informacoes do objeto
%             info = getInfo(obj);
%             
%             % Calcule 3 Valores:
%             % Distancia entre High e Low de hoje
%             dHiLo = info.high - info.low;
%             % Distancia entre High de hoje e Close de Ontem
%             dHiCl        = zeros(obj.tam, 1);
%             dHiCl(2:end) = abs(info.high(2:end) - info.close(1:end-1));
%             % Distancia entre o Low de hoje e Close de Ontem
%             dLoCl        = zeros(obj.tam, 1);
%             dLoCl(2:end) = abs(info.low(2:end) - info.close(1:end-1));
%             
%             % Coleta em cada dia o Maximo das 3
%             % Transforma em Colunas
%             if ~iscolumn(dHiLo)
%                 dHiLo = dHiLo';
%             end
%             if ~iscolumn(dHiCl)
%                 dHiCl = dHiCl';
%             end
%             if ~iscolumn(dLoCl)
%                 dLoCl = dLoCl';
%             end
%             % Coloca em matriz N x 3
%             trMatrix = [dHiLo, dHiCl, dLoCl];
%             % Pega o maximo dentre os 3 vetores
%             trVec = max(trMatrix, [], 2);
%         end
%         % Directional Index
%         function [diP, diN] = dind(obj)
%             % Calcula o Directional Movement
%             [dmP, dmN] = dmov(obj);
%             % Calcula o True Range
%             trVec = truerange(obj);
%             trVec = movAvg(trVec, 'exp', 14);
%             % Divide DM por TR
%             diP = dmP./trVec';
%             diN = dmN./trVec';
%         end
%         % ADX
%         function [adxV, diP13, diN13]= adx(obj)
%             % Calcule o Directional Index
%             [diP, diN] = dind(obj);
%             % Suavize ambas as curvas
%             diP13 = 100*finData.movAvg(diP, 'exp', 13);
%             diN13 = 100*finData.movAvg(diN, 'exp', 13);
%             
%             % Calcule o Directional Indicator
%             dxVec = (diP13 - diN13)./(diP13 + diN13)*100;
%             
%             % Suavize com media movel exponencial de 13 dias
%             adxV = finData.movAvg(dxVec, 'exp', 13);
%         end

        function [ ADX, ADXR, PDI, MDI] = calcDMI( obj, M, N)
        % CALCDMI - calculate Directional Movement Index (DMI) for a given
        % stock given high, low, close
        %
        % [ ADX, ADXR, PDI, MDI] = calcDMI( high, low, close, M, N),
        % INPUT: 
        % high - data vector of high prices
        % low - data vector of low prices
        % close - data vector of close prices
        % M - days to avreage, optional
        % N- days to sum +DI and -DI, optional
        %
        % OUTPUT:
        % ADX - Directional Movement Index
        % ADXR -  Directional movement rating
        % PDI - +DM, plus Directional Indicator
        % MDI - -DM, minus Directional Indicator
        %
        % EXAMPLES:
        % % read JNJ stock from yahoo URL
        % url2Read ='http://ichart.finance.yahoo.com/table.csv?s=JNJ&a=0&b=12&c=2010&d=9&e=23&f=2012&g=d&ignore=.csv';
        % s=urlread( url2Read);
        % 
        % % reshape response
        % s=strread(s,'%s','delimiter',',');
        % s=reshape(s,[],length(s)/7)';
        % disp(s);
        % 
        % % read data from s
        % high =  str2double(s(2:end,3));
        % low = str2double(s(2:end,4));
        % close = str2double(s(2:end,5));
        % 
        % % call function
        % [ ADX, ADXR, PDI, MDI] = calcDMI( high, low, close);

        % information from http://www.trade10.com/Directional_Movement.html
        % Directional movement is a system for providing trading signals to be used for price breaks from a trading range. 
        % The system involves 5 indicators which are the Directional Movement Index (DX), the plus Directional Indicator (+DI), 
        % the minus Directional Indicator (-DI), the average Directional Movement (ADX) and the Directional movement rating (ADXR). 
        % The system was developed J. Welles Wilder and is explained thoroughly in his book, New Concepts in Technical Trading Systems .
        % The basic Directional Movement Trading system involves plotting the 14day +DI and the 14 day -DI on top of each other. 
        % When the +DI rises above the -DI, it is a bullish signal. 
        % A bearish signal occurs when the +DI falls below the -DI. 
        % To avoid whipsaws, Wilder identifies a trigger point to be the extreme price on the day the lines cross. 
        % If you have received a buy signal, you would wait for the security to rise above the extreme price (the high price on the day the lines crossed). 
        % If you are waiting for a sell signal the extreme point is then defined as the low price on the day's the line cross.

        % 
        % $License: BSD (use/copy/change/redistribute on own risk, mention the
        % author) $
        % History:
        % 001:  Natanel Eizenberg: 14-May-2006 21:52, First version.
        % 002:  Natanel Eizenberg: 04-Nov-2012 21:52, Edit for file exchange.
            info  = getInfo(obj);
            high  = info.high;
            low   = info.low;
            close = info.close;
        
            % all values should be lined
            if size(high,1)~=1; high=high'; end;
            if size(low,1)~=1; low=low'; end;
            if size(close,1)~=1; close=close'; end;
            % defults M,N   
            if nargin==1 
                N=14;
                M=6;
            end;
            % max,min values
            if N>100,
                N=100;
            elseif N<2,
                N=2;
            end;

            if M>100,
                M=100;
            elseif M<1,
                M=1;
            end;

            %  true range calculation (TR)
            tmpTR=max( [high-low;...
                    abs(high - [ high(1) close(1:end-1)]);...
                    abs(low - [ low(1) close(1:end-1)])  ]);
            win=ones(1,N);
            TR=conv(tmpTR,win);
            TR=TR(1:end-N+1);

            % high and low Directional
            HD = high-[ high(1) high(1:end-1)]; 
            LD = [ low(1) low(1:end-1)]-low;

            % init 
            tmpDMP=zeros(size(HD));
            tmpDMM=zeros(size(LD));

            % find data for +DM
            index=HD>0 & HD>LD;
            tmpDMP(index)= HD(index); 
            win=ones(1,N);
            DMP=conv(tmpDMP,win);
            DMP=DMP(1:end-N+1);

            % find data for -DM
            index=LD>0 & LD>HD;
            tmpDMM(index)= LD(index);
            win=ones(1,N);
            DMM=conv(tmpDMM,win);
            DMM=DMM(1:end-N+1);

            % calc +DM and -DM
            PDI= (DMP*100)./TR;
            MDI= (DMM*100)./TR;
            PDI(1) = 0;
            MDI(1) = 0;

            % calc Directional Movement Index
            win=ones(1,M);
            tmpADX=(abs(MDI-PDI)./(MDI+PDI))*100;
            tmpADX(1)=tmpADX(2); %remove inf
            ADX= conv(tmpADX,win)/M;
            ADX= ADX(1:end-M+1);

            % calc Directional movement rating
            ADXR=circshift(ADX',M)';
            ADXR(1:M)=ADX(1:M);
            ADXR=(ADX+ADXR)/2;
        end
        %% Get Functions
        function info = getInfo(obj)
            % Pegue o pointVec
            pointVec = obj.point;
            % Create empty Matrix
            empty = zeros(1, length(pointVec));
            % Create struct with high, low, open and close
            info = struct('high', empty, 'low', empty, 'open', empty, 'close', empty);
            % Get info
            for i = 1:obj.tam
                info.high(i)   = pointVec{i}.high;
                info.low(i)    = pointVec{i}.low;
                info.open(i)   = pointVec{i}.open;
                info.close(i)  = pointVec{i}.close;
                info.volume(i) = pointVec{i}.volume;
                info.quantity(i) = pointVec{i}.quantity;
            end
        end
        %% Plot Function
        function plot(obj)
            % Get Info
            info = getInfo(obj);
            % Plot, Candle
            candle(info.high', info.low', info.close', info.open', 'k')
        end
    end
    
    methods(Static)
        function dataArray = importFinance(name,gran)
            %IMPORTFINANCE Import .csv financial data into a structured format
            %   IMPORTFINANCE('FILENAME', GRAN) reads financial data contained into
            %   'FILENAME'.csv and imports it assuming the granularity expressed in
            %   GRAN.
            %
            %   The possible Granularities are:
            %   '1m'    '5m'    '10m'   '15m'
            %   '20m'   '30m'   '60m'   'daily'
            %
            % Example:
            %   gran = 'daily';
            %   importFinance('IBOV.d.csv', gran);
            %
            %    See also TEXTSCAN.

            % By Dyego Soares de Araujo
            % Last edited: 26/10/2013
            %% Inicialize Variables
            delimiter = ';';
            startRow = 1;
            endRow = inf;
            %% Check if FILENAME has '.csv' ending
            if ~(strcmp(name(end-3:end),'.csv'))
                name = strcat(name, '.csv');
            end

            %% Specify the format
            switch gran
                case 'daily'
                    % 'daily' granularity has different data format
                    formatSpec = '%s%s%f%f%f%f%f%f%[^\n\r]';
                otherwise
                    % other granularities have the same data format
                    formatSpec = '%s%s%s%f%f%f%f%f%f%[^\n\r]';
            end

            %% Open file and replace comma by point
            data = fileread(name);
            data = strrep(data, ',', '.');
            %% Import file
            dataArray = textscan(data, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);

            %% Edit Times and Dates
            dataArray{2} = datenum(dataArray{2}, 'dd/mm/yyyy'); % date/time format #1

            if ~strcmp(gran, 'daily')
                    dataArray{3} = datenum(dataArray{3}, 'hh:mm:ss'); % date/time format #13
            end
        end
        
        function output = movStd(sinal, tam)
            % Funcao que calcula o desvio padrao movel em cada amostra

            % Tamanho do sinal
            N = length(sinal);

            % Prealocacao
            output = zeros(1, N);
            for i = 1:N
                low = max([1 i-tam]);
                output(i) = std(sinal(low:i));
            end
        end
        
        function vector = movAvg(input, type, tam)
        % VECTOR = MOVAVG(INPUT, TYPE, tam)
        %
        % Smooths vector with a moving average. It has 2 types of moving averages:
        % simple (TYPE = 'smp'), and exponential (TYPE = 'exp'). There is also a
        % differential type of filter, represented by (TYPE = 'diff'). The length
        % of each filter is determined by tam.
        %
        % See Also: FILTER

        % Last edited: 27/10/2013
        % by Dyego Soares de Araújo

            % Efetua selecao do tipo de media movel
            switch type
                case 'smp'
                    A = 1;
                    B = 1/tam*ones(tam, 1);
                case 'exp'
                    A = [1 -(tam - 1)/(tam + 1)];
                    B = 2/(tam + 1);
                case 'diff'
                    A = 1;
                    B = zeros(tam, 1);
                    B(1) = 1;
                    B(end) = -1;
            end
            % Filtra o vetor com o tipo selecionado
            vector = filter(B, A, input);
       end
    end
end