classdef Ddot < imf.Expression
    properties(SetAccess='private')
        obj1;
    end
    
    methods
        function obj = Ddot(obj1)
            if nargin > 0
                obj.obj1 = obj1;
                global IMF_;
                if isa(obj1, 'imf.GeneralizedCoordinate')
                    IMF_.helper.addDDX(obj1);
                end
            end
        end
        
        function out = copy(obj)
            out = obj;
        end
        
        function s = toString(obj)
            s = sprintf('ddot(%s)', obj.obj1.toString);
        end
        
        function jac = jacobian(obj, var)
            error('Jacobian feature not supported for expressions with state derivatives.')
        end
    end
    
end
