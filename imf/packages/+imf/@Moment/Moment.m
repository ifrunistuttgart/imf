classdef Moment
    %MOMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        moment@imf.Vector
        pointOfApplication@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        
        function obj = Moment(moment, pointOfApplication, coordinateSystem)
            if isvector(moment)
                obj.moment = imf.Vector(moment);
            elseif isa(force, 'imf.Vector')
                obj.moment = moment;
            else
                error('The moment must be either an numeric or symbolic vector or an imf.Vector');
            end
            
            if isvector(pointOfApplication)
                obj.pointOfApplication = imf.Vector(pointOfApplication);
            elseif isa(force, 'imf.Vector')
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

