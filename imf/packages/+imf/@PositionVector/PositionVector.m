classdef PositionVector < imf.Vector
    
    methods
        function obj = PositionVector(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);
        end
        
        function out = In(obj, coordinateSystem)
            
            out = obj;
            
            if obj.coordinateSystem ~= coordinateSystem
                
                for i=1:length(obj.representation)
                    if obj.representation{i}.coordinateSystem == coordinateSystem
                        out = obj.representation{i}.obj;
                    end
                end
                
                if obj.coordinateSystem ~= coordinateSystem
                    T = getTransformation(obj.coordinateSystem, coordinateSystem);
                    R = T.HomogeneousMatrix;
                    items = R * [obj.items'; 1];
                    out = imf.PositionVector(items(1:3), coordinateSystem);
                    obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
                end
                
            end
        end
    end
    
end