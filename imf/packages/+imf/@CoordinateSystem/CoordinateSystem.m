classdef CoordinateSystem < handle
    %COORDINATESYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess='public', SetAccess='private')
        name@char vector = ''
    end
    
    methods
        function obj = CoordinateSystem(name) 
            if nargin > 0
                global IMF_;
                
                if (isvarname(name) ~= 1)
                    error( 'ERROR: The variable name you have set is not a valid matlab variable name. A valid variable name is a character string of letters, digits, and underscores, totaling not more than namelengthmax characters and beginning with a letter.' );
                end
                
                obj.name = name;
            end
        end
        
        function r = eq(a,b)
            if a.name == b.name
                r = 1;
            else
                r = 0;
            end
        end
    end
    
end

