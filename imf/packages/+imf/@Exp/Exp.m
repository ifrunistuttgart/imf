classdef Exp < imf.UnaryOperator
    properties(SetAccess='private')

    end
    
    methods
        function obj = Exp(obj1)
            if nargin > 0
                if (isa(obj1, 'numeric'))
                    obj1 = imf.DoubleConstant(obj1);
                end
                obj1 = obj1.getExpression;
                obj.obj1 = obj1;
                
                if obj1.zero
                   obj.one = 1; 
                end
            end
        end
        
        function out = copy(obj)
            out = imf.Exp(copy(obj.obj1));
        end
        
        function s = toString(obj)
            global IMF_;
            
            if obj.one
                s = '1';
            else
                s = sprintf('exp(%s)', obj.obj1.toString); 
            end
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            for i = 1:length(obj)
                if obj(i).obj1.zero || obj(i).obj1.one || isa(obj(i).obj1, 'imf.DoubleConstant')
                    jac(i,:) = zeros(1,length(var));
                else
                    jac(i,:) = jacobian(obj(i).obj1,var)*obj;
                end
            end
        end
    end
    
end
