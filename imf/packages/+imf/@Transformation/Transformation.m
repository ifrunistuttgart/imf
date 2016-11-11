classdef Transformation < handle
    %Transformation defines a transformation of coordinate systems
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
    end
    properties(SetAccess='public')
        rotation@imf.DCM
        offset@imf.Vector
    end
    
    methods
        function obj = Transformation(from, to)
            if nargin > 0
                global IMF_;
                
                obj.from = from;
                obj.to = to;
                
                IMF_.transformations(end+1) = obj;
            end
        end
        
        function obj = ctranspose(a)
            obj = imf.Transformation(a.to, a.from);
            obj.rotation = a.rotation';
            obj.offset = a.rotation*-1*a.offset;
        end
        
        function texternal = Transform(obj, external)
                % transrotational transformation
                Tt = [obj.rotation.fun -1*obj.offset.value;
                    zeros(1, 3)          1];
                
                % rotational transformation
                Tr = obj.rotation.fun;
                
            if isa(external, 'imf.Force')                
                force = Tr * external.force.value;
                pointOfApplication = Tt * [external.pointOfApplication.value; 1];
                coordinateSystem = obj.to;
                
                texternal = imf.Force(force, pointOfApplication(1:3), coordinateSystem);
            elseif isa(external, 'imf.Mass')                
                mass = external.mass;
                point = Tt * [external.point.value; 1];
                coordinateSystem = obj.to;
                
                texternal = imf.Mass(mass, point(1:3), coordinateSystem);
            end
        end
    end
    
end

