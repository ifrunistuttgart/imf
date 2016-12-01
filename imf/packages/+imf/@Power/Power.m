classdef Power < imf.BinaryOperator
    properties(SetAccess='private')

    end
    
    methods
        function obj = Power(obj1, obj2)
            if (isa(obj1, 'numeric'))
                obj1 = imf.DoubleConstant(obj1);
            elseif (isa(obj2, 'numeric'))
                obj2 = imf.DoubleConstant(obj2);
            end
            obj1 = obj1.getExpression;
            obj2 = obj2.getExpression;
            
            if obj1.zero
               obj.zero = 1;
            elseif obj2.zero
               obj.one = 1; 
            elseif obj1.one
               obj.one = 1;
            end
            
            obj.obj1 = obj1;
            obj.obj2 = obj2;
            obj.singleTerm = obj1.singleTerm && obj2.singleTerm;
        end
        
        function out = copy(obj)
            out = imf.Power(copy(obj.obj1), copy(obj.obj2));
        end
        
        function s = toString(obj)
            global IMF_;
            
            if obj.obj1.zero
               obj.zero = 1;
            elseif obj.obj2.zero || obj.obj1.one
               obj.one = 1; 
            end
            
            if obj.zero
                s = '0';
            elseif obj.one
                s = '1';
            elseif strcmp(obj.obj2.toString, '1')
                s = sprintf('%s', obj.obj1.toString); 
            elseif isa(obj.obj2, 'imf.DoubleConstant') && obj.obj2.val == -1
                s = sprintf('1/%s', obj.obj1.toString); 
            elseif isa(obj.obj2, 'imf.DoubleConstant') && obj.obj2.val == 1/2
                s = sprintf('sqrt(%s)', obj.obj1.toString);
            elseif isa(obj.obj2, 'imf.DoubleConstant') && obj.obj2.val == -1/2
                s = sprintf('1/sqrt(%s)', obj.obj1.toString);
            else
                if obj.obj1.singleTerm && obj.obj2.singleTerm
                    s = sprintf('%s^%s', obj.obj1.toString, obj.obj2.toString); 
                elseif obj.obj1.singleTerm
                    s = sprintf('%s^(%s)', obj.obj1.toString, obj.obj2.toString); 
                elseif obj.obj2.singleTerm
                    s = sprintf('(%s)^%s', obj.obj1.toString, obj.obj2.toString); 
                else
                    s = sprintf('(%s)^(%s)', obj.obj1.toString, obj.obj2.toString); 
                end
            end
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            for i = 1:length(obj)
                if obj(i).zero
                    jac(i,:) = zeros(1,length(var));
                elseif obj(i).one
                    jac(i,:) = zeros(1,length(var));
                elseif isa(obj(i).obj2, 'imf.DoubleConstant')
                    jac(i,:) = obj(i).obj2*imf.Power(obj(i).obj1,obj(i).obj2.val-1)*jacobian(obj(i).obj1, var);
                else
                    jac(i,:) = obj(i)*(jacobian(obj(i).obj1,var)*(obj(i).obj2/obj(i).obj1) + jacobian(obj(i).obj2,var)*imf.Logarithm(obj(i).obj1));
                end
            end
        end
        
        function out = simplifyLocally(obj)
            if isa(obj.obj1, 'imf.DoubleConstant') && isa(obj.obj2, 'imf.DoubleConstant')
                out = imf.DoubleConstant(obj.obj1.val^obj.obj2.val);
            else
                out = obj;
            end
        end
    end
    
end

