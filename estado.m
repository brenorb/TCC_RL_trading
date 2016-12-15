classdef estado < handle
    properties
        varEstado;
        nEstado;
        discr;      % Número da discretização
    end
    
    methods
        function obj = estado(finData)
            obj.discr = 22;
            %% Coleta Informacoes
            %%% IMPORTANTE: range de ~ 0-100
            [~, ~, ~, norm] = bollingerb(finData, 20);
%            [kv, dv, slow]  = stochastic(finData, 12, 3);
%            [~, ~, ~]    = adx(finData);
%            obvVec  = obv(finData);
%            nhnlVec = nhnl(finData);
            [adx,~,~] = calcDMI(finData);
            [trend,~,~] = hilo(finData,7);
            %% Gera Vetor de Estado (Com Normalizacao)
            obj.varEstado(1,:) = norm;
            obj.varEstado(2,:) = adx;
            obj.varEstado(3,:) = trend;
            
            obj.nEstado = 3;
            discrete(obj);
        end

        function obj = discrete(obj)
            % Pega o range das entradas
            range = [0 100];
            % é o espaço de discretização dentro do range
            delta = range(2)/(obj.discr-2);
            % Cria o vetor para guardar os estados discretizados
            s = zeros(size(obj.varEstado));
            for k = 1:size(s,2) % tempo
                for i = 1:size(s,1)-1 % entrada
                    % Será 1 tudo que ficar abaixo do Range(1)
                    limite = range(1);
                    for j = 1:obj.discr
                        % se o valor é menor que um limite ou é maior que
                        % todos
                        if (obj.varEstado(i,k) <= limite) || (j == obj.discr)
                            s(i,k) = j;
                            % encontrou o número do estado, passa pro prox
                            break
                        end
                        % Não encontrou o n. do estado, soma delta
                        limite = limite+delta;
                    end
                end
                i=3;
                s(i,k) = (obj.varEstado(i,k) > 0)+1;
            end
            % Atribui o vetor discretizado ao varEstado
            obj.varEstado = s;
        end

        function vec = getEstado(obj, N)
            vec = obj.varEstado(:, N);
        end
        
        function N = getN(obj)
            N = [obj.nEstado obj.discr];
        end
    end
    methods(Static)
    end
end