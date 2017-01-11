classdef Transformation < handle
    %Transformation defines a transformation of coordinate systems
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
        rotation@imf.RotationMatrix
        translation@imf.Vector
    end
    
    methods
        function obj = Transformation(from, to, rotation, translation)
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
                
                if ~isa(translation, 'imf.Vector')
                    error('Provide a valid imf.Vector for translation.')
                end
                
                obj.from = from;
                obj.to = to;
                obj.rotation = rotation;
                
                
                if translation.coordinateSystem == from
                    obj.translation = imf.Vector(rotation.expr * -1 * translation.items', to);
                else
                    obj.translation = translation;
                end
                
                IMF_.transformations(end+1) = obj;
            end
        end
        
        function obj = ctranspose(a)
            obj = imf.Transformation(a.to, a.from, a.rotation', imf.Vector(a.rotation.expr' * -1 * a.translation.items', a.from));
        end
        
        
        function T = HomogeneousMatrix(obj)
            % transrotational transformation
            T = [obj.rotation.expr obj.translation.items';
                zeros(1, 3)          1];
        end
    end
    
end

