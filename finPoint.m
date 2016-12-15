classdef finPoint
    % FINPOINT
    %
    % Classe responsavel por gerar objetos FINPOINT. Um objeto FINPOINT tem
    % por finalidade armazenar um instante do mercado financeiro. Para tal
    % fim, ele possui informacoes a respeito de data e hora de sua coleta,
    % alem das informacoes financeiras padrao: open, close, high e low
    % prices, volume e quantidade de negocios.
    %
    % Ver tambem: FINDATA
    
    % by: Dyego Soares de Araujo
    % Last Edited: 29/10/2013
    properties
%% Time Properties
        date;
        time;
%% Price Properties
        open;
        high;
        low;
        close;
%% Volume Properties
        volume;
        quantity;
    end
    
    methods
%% Create Method
        function obj = finPoint(date, time, open, high, low, close, volume,...
                quantity)
            obj.date     = date;
            obj.time     = time;
            obj.open     = open;
            obj.close    = close;
            obj.high     = high;
            obj.low      = low;
            obj.volume   = volume;
            obj.quantity = quantity;
        end
%% Get Date/Time Methods
        % Get Date
        function str = getDate(obj)
            str = datestr(obj.date, 1);
        end
        % Get Time
        function str = getTime(obj)
            str = datestr(obj.time, 13);
        end
%% Get Price Methods
        % Get High
        function flt = getHigh(obj)
            flt = obj.high;
        end
        % Get Low
        function flt = getLow(obj)
            flt = obj.low;
        end
        % Get Open
        function flt = getOpen(obj)
            flt = obj.open;
        end
        % Get Close
        function flt = getClose(obj)
            flt = obj.close;
        end
%% Get Volume Methods
        % Get Volume
        function flt = getVolume(obj)
            flt = obj.volume;
        end
        % Get Quantity
        function flt = getQuantity(obj)
            flt = obj.quantity;
        end
        
    end
end