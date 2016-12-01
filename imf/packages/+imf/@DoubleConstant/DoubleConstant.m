classdef DoubleConstant < imf.Operator
    properties(SetAccess='private')
        val;
        callByValue = 0;
    end
    
    methods
        function obj = DoubleConstant(val)
            if nargin > 0
                global IMF_;
                
                if (isa(val, 'numeric'))
                    
                    obj.callByValue = 1;
                    obj.val = val;
                    if val == 0
                        obj.zero = 1;
                    elseif val == 1
                        obj.one = 1;
                    end
                    obj.name = num2str(val);
                    
                else
                    error('DoubleConstant expects a numeric value');
                end
                obj.singleTerm = 1;
            end
        end
        
        function out = copy(obj)
            out = imf.DoubleConstant(obj.val);
        end
        
        
        getInstructions(obj, cppobj, get)
        
        
        function s = toString(obj)
            % toString is used in epxressions (eg 2 + x -> DoubleConstant +
            % DifferentialState)
            global IMF_;
            
            if obj.callByValue
                if obj.val < 0
                    s = ['(' num2str(obj.val) ')'];
                else
                    s = num2str(obj.val);
                end
            else
                s = obj.name;
            end
            
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            jac = zeros(length(obj), length(var));
        end
        
        function setToAbsoluteValue(obj)
            obj.val = abs(obj.val);
            obj.name = num2str(obj.val);
            if obj.val == 1
                obj.one = 1;
            end
        end
    end
end

