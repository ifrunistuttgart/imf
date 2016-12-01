classdef DifferentialState < imf.Variable
    properties(SetAccess='private')
        
    end
    
    methods
        function obj = DifferentialState(name)
            if nargin > 0
                global IMF_;
                
                if (isvarname(name) ~= 1)
                    error( 'ERROR: The variable name you have set is not a valid matlab variable name. A valid variable name is a character string of letters, digits, and underscores, totaling not more than namelengthmax characters and beginning with a letter.' );
                end
                
                obj.name = name;                
            end
        end
        
        getInstructions(obj, cppobj, get)
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            for j = 1:length(obj)
                for i = 1:length(var)
                    var(i) = getExpression(var(i));
                    if isa(var(i), 'imf.Variable')
                        jac(j,i) = imf.DoubleConstant(double(isa(var(i), 'imf.DifferentialState') && strcmp(obj(j).name, var(i).name)));
                    else
                        error('A jacobian can only be computed with respect to a variable.');
                    end
                end
            end
        end
    end
    
end

