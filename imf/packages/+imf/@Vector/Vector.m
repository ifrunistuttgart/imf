classdef Vector
    %VECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        value
    end
    
    methods
        function obj = Vector(value)
            obj.value = value;
        end
    end
    
end

