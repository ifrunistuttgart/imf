classdef Gravity < imf.Vector
    %GRAVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = Gravity(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);            
        end
    end
end

