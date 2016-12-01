classdef Dot < imf.Expression
    properties(SetAccess='private')
        obj1;
    end
    
    methods
        function obj = Dot(obj1)
            if nargin > 0
                obj.obj1 = obj1;
                global IMF_;
            end
        end
        
        function out = copy(obj)
            out = obj;
        end
        
        function s = toString(obj)
            s = sprintf('dot(%s)', obj.obj1.toString);
        end
        
        function jac = jacobian(obj, var)
            error('Jacobian feature not supported for expressions with state derivatives.')
        end
    end
    
end
