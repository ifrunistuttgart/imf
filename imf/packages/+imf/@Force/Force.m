classdef Force
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        force@imf.Vector
        forceApplicationPoint@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Force(force, forceApplicationPoint, coordinateSystem)
            if isvector(force)
                obj.force = imf.Vector(force);
            elseif isa(force, 'imf.Vector')
                obj.force = force;
            else
                error('The force must be either an numeric vector or an imf.Vector');
            end
            
            
            if isvector(forceApplicationPoint)
                obj.forceApplicationPoint = imf.Vector(forceApplicationPoint);
            elseif isa(forceApplicationPoint, 'imf.Vector')
                obj.forceApplicationPoint = forceApplicationPoint;
            else
                error('The forceApplicationPoint must be either an numeric vector or an imf.Vector');
            end
            
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
    end
    
end

