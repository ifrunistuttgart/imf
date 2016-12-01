classdef Variable < imf.Expression
    properties(SetAccess='private')
        value;
    end
    
    methods
        function obj = Variable(name)
            
            obj.singleTerm = 1;
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
        
    end
    
end

