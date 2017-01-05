classdef Transformation < handle
    %Transformation defines a transformation of coordinate systems
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
    end
    properties(SetAccess='public')
        rotation@imf.RotationMatrix
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
            obj.offset = imf.Vector(obj.rotation.expr * -1 * a.offset.items', a.from);
        end
        
        
        function T = HomogeneousMatrix(obj)
            % transrotational transformation
            T = [obj.rotation.expr obj.offset.items';
                zeros(1, 3)          1];
        end
        
        function texternal = Transform(obj, in)
            
            if isa(in, 'imf.Force')
                name = in.name;
                force = in.value.In(obj.to);
                positionVector = in.positionVector.In(obj.to);
                
                texternal = imf.Force(name, force, positionVector(1:3));
            elseif isa(in, 'imf.Mass')
                name = in.name;
                mass = in.value;
                positionVector = in.positionVector.In(obj.to);
                
                texternal = imf.Mass(name, mass, positionVector(1:3));
            elseif isa(in, 'imf.Moment')
                error('Not yet implemented.')
            elseif isa(in, 'imf.Inertia')
                error('Not yet implemented.')
            end
        end
    end
    
end

