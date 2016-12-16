classdef Variable < imf.Expression
    properties(SetAccess='private')
        value;
    end
    
    methods
        function obj = Variable(name)
            
            obj.singleTerm = 1;
            
            if nargin > 0
                global IMF_;
                if (isvarname(name) ~= 1)
                    error( 'ERROR: The variable name you have set is not a valid matlab variable name. A valid variable name is a character string of letters, digits, and underscores, totaling not more than namelengthmax characters and beginning with a letter.' );
                end
                
                obj.name = name;
                
                IMF_.helper.addVar(obj);
            end
            
        end
        
        function out = copy(obj)
            out = obj;
        end
        
        function s = toString(obj)
            if isempty(obj.value)
                s = obj.name;
            else
                s = num2str(obj.value);
            end
        end
        
        function setValue(obj, set)
            if isempty(set) || isnumeric(set)
                obj.value = set;
            else
                error('A value needs to be numeric.');
            end
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            
            for i = 1:length(obj)
                jac(i,:) = zeros(1,length(var));
            end
            
        end
    end    
end