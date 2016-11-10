classdef GeneralizedCoordinate < handle
    %GeneralizedCoordinate defines a generialized coordinate
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        name
    end
    
    methods
        function obj = GeneralizedCoordinate(name) 
            if nargin > 0
                global IMF_;
                
                if (isvarname(name) ~= 1)
                    error( 'ERROR: The variable name you have set is not a valid matlab variable name. A valid variable name is a character string of letters, digits, and underscores, totaling not more than namelengthmax characters and beginning with a letter.' );
                end
                
                obj.name = name;
            end
        end
    end
    
end

