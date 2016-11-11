classdef Force
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        force@imf.Vector
        pointOfApplication@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Force(force, pointOfApplication, coordinateSystem)
            if isvector(force)
                obj.force = imf.Vector(force);
            elseif isa(force, 'imf.Vector')
                obj.force = force;
            else
                error('The force must be either an numeric or symbolic vector or an imf.Vector');
            end
            
            
            if isvector(pointOfApplication)
                obj.pointOfApplication = imf.Vector(pointOfApplication);
            elseif isa(pointOfApplication, 'imf.Vector')
                obj.pointOfApplication = pointOfApplication;
            else
                error('The pointOfApplication must be either an numeric vector or an imf.Vector');
            end
            
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
    end
    
end

