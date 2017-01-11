classdef Transformation < handle
    %Transformation defines a transformation of coordinate systems
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
        rotation@imf.RotationMatrix
        offset@imf.Vector
    end
    
    methods
        function obj = Transformation(from, to, rotation, offset)
            if nargin > 0
                global IMF_;
                
                if ~isa(from, 'imf.CoordinateSystem')
                    error('Provide a valid imf.CoordinateSystem for the source system.')
                end
                
                if ~isa(to, 'imf.CoordinateSystem')
                    error('Provide a valid imf.CoordinateSystem for the target system.')
                end
                
                if ~isa(rotation, 'imf.RotationMatrix')
                    error('Provide a valid imf.RotationMatrix for rotation.')
                end
                
                if ~isa(offset, 'imf.Vector')
                    error('Provide a valid imf.Vector for offset.')
                end
                
                obj.from = from;
                obj.to = to;
                obj.rotation = rotation;
                
                
                if offset.coordinateSystem == from
                    obj.offset = imf.Vector(rotation.expr * -1 * offset.items', to);
                else
                    obj.offset = offset;
                end
                
                IMF_.transformations(end+1) = obj;
            end
        end
        
        function obj = ctranspose(a)
            obj = imf.Transformation(a.to, a.from, a.rotation', imf.Vector(a.rotation.expr' * -1 * a.offset.items', a.from));
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

