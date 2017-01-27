classdef AttitudeVector < imf.Vector
    
    methods
        function obj = AttitudeVector(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);
        end
        
        function out = In(obj, coordinateSystem)
            error('Not implemented yet.')
        end
    end
    
end