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
            obj.offset = a.rotation* -1 * a.offset;
        end
        
        
        function T = HomogeneousMatrix(obj)
                % transrotational transformation
                T = [obj.rotation.fun obj.offset.items';
                    zeros(1, 3)          1];
        end
        
        function texternal = Transform(obj, external)
                % homogeneous matrix
                Th = obj.HomogeneousMatrix;
                
                % rotational transformation
                Tr = obj.rotation.fun;
                
            if isa(external, 'imf.Vector')
                vector = Th * [external.items'; 1];
                
                texternal = imf.Vector(vector(1:3));
            elseif isa(external, 'imf.Force')
                name = external.name;
                force = Tr * external.value;
                positionVector = Th * [external.positionVector.items'; 1];
                coordinateSystem = obj.to;
                
                texternal = imf.Force(name, force, positionVector(1:3), coordinateSystem);
            elseif isa(external, 'imf.Mass')
                name = external.name;
                mass = external.value;
                positionVector = Th * [external.positionVector.items'; 1];
                coordinateSystem = obj.to;
                
                texternal = imf.Mass(name, mass, positionVector(1:3), coordinateSystem);
            elseif isa(external, 'imf.Moment')
                error('Not yet implemented.')
            elseif isa(external, 'imf.Inertia')
                error('Not yet implemented.')
            end
        end
    end
    
end

