classdef rLearnDEBUG < handle
    % RLEARN
    %
    %
    %
    
    % by Breno Rodrigues Brito
    % by Dyego Soares de Araujo
    % Last Edited 22/11/2013
    properties
        %% Parametros Macro
        epsilon; % Percentual de Aleatoriedade
        param;   % parametro de multiplicação da acao
        gamma;
        lambda;
        alpha;
        nState;  % discretização
        
        %% Informacoes Transitorias
        action;  % Acao Tomada\Acao Antiga
        state;   % Estado Atual\Estado Antigo
        rede;    % Rede Neural Atual
        
        %% TESTE
        Q;  % Valor de Cada Acao em Cada Estado
        E;  % Rastros de Eligibilidade
    end
    
    methods
        %% Create Method
        function obj = rLearnDEBUG(nState, epsilon, alpha, gamma, lambda)
            % Tabelas Q, E, action e state
            obj.state   = struct('cur', [], 'old', []);
            obj.action  = struct('cur', [], 'old', []);
            
            % Parametros
            obj.epsilon = epsilon;
            obj.param = 1;
            obj.lambda = lambda;
            obj.gamma = gamma;
            obj.alpha = alpha;
            obj.nState = nState(2);
            
            
            % Gera a rede neural
%             obj.rede = neuralObject(nState + 1, N, alpha, gamma, lambda);
            
%             obj.Q = 0.01*rand(obj.nState, obj.nState, 2, 2); 
            obj.Q = zeros(obj.nState, obj.nState, 2, 2);
            resetE(obj);
        end
        
        %% Acoes
%         % Escolhe uma Acao
%         function action = makeChoice(obj, s)
%             % Toma a Acao (Aleatoria / Greedy)
%             % Gera Numero Aleatorio
%             aleat = 100*rand;
%             % Calcula Valores Q
%             qKeep = obj.Q(s(1),s(2),s(3),1);
%             qBuy  = obj.Q(s(1),s(2),s(3),2);
%             % Se aleat > epsilon
%             if (aleat > obj.epsilon)
%                 % Acao Greedy
%                 action = (qBuy >= qKeep);
%             else
%                 % Acao Aleatoria
%                 action = (randi(2)==1);    
%             end
%             
%             if action
%             end
            
        % Escolhe uma Acao
        function action = makeChoice(obj, contador)
            % Toma a Acao (Aleatoria / Greedy)
            % Gera Numero Aleatorio
            action = (sin(contador*3.14159/2) >= 0);
            
            
%             %%% TESTE
%             % Registra estados de compra
%             obj.tableQ.states = [obj.tableQ.states s];
%             obj.tableQ.actions= [obj.tableQ.actions 1];
%             obj.tableQ.Qvalue = [obj.tableQ.Qvalue qBuy];
%             % Registra estados de manter
%             obj.tableQ.states = [obj.tableQ.states s];
%             obj.tableQ.actions= [obj.tableQ.actions 0];
%             obj.tableQ.Qvalue = [obj.tableQ.Qvalue qKeep];
        end
%% Funcao de Registro
        function register(obj, state, action)
            % Registra o Estado
            obj.state.old = obj.state.cur;
            obj.state.cur = state;
            % Registra acao
            obj.action.old = obj.action.cur;
            obj.action.cur = action;
        end
%% Funcao de Inicialicazao
        % Inicializacao do rLearn
        function initLearn(obj, state, action)
            % Recebe o primeiro estado
            obj.state.cur = state;
            % Recebe a primeira acao
            obj.action.cur = action;
            % Reseta E
            resetE(obj);
            % Reseta a rede
%             reset(obj.rede);
            %%%TESTE
            % Registra os valores na tabela Q
%             obj.tableQ = struct('Qvalue', {0}, 'states', {state}, 'actions', {action}); 
        end
%% Atualizacao de Tabelas        
        % Atualizar tabela Q
        function updateQ(obj, reward)
%             % Constroi os Inputs
%             inputPast = [obj.state.old; obj.param*obj.action.old];
%             inputPres = [obj.state.cur; obj.param*obj.action.cur];
%             
%             % Requisita atualizacao da rede Neural
%             adapt(obj.rede, inputPast, inputPres, reward);
            s1 = obj.state.cur;
            a1 = obj.action.cur +1;
            s = obj.state.old;
            a = obj.action.old +1;
            
            qF = obj.Q(s1(1),s1(2),s1(3),a1);
            qP = obj.Q(s(1),s(2),s(3),a);
            
            delta = reward + obj.gamma*qF - qP;
            
            obj.Q = obj.Q + obj.alpha * delta * obj.E;
            
        end
        
        function resetE(obj)
            obj.E = zeros(obj.nState,obj.nState, 2, 2);
        end
        
        function updateE(obj)
            % decai
            obj.E = obj.gamma*obj.lambda*obj.E;
            % Encurta
            s = obj.state.old;
            a = obj.action.old +1;
            % Atualiza
            obj.E(s(1),s(2),s(3),a) = obj.E(s(1),s(2),s(3),a) + 1;
        end
    end 
end