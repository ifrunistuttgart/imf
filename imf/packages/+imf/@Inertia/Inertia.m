classdef Inertia < imf.Matrix
    
    properties(SetAccess = 'public')
        body@imf.Body
    end
    
    methods
        function obj = Inertia(val, coordinateSystem)            
            obj = obj@imf.Matrix(val, coordinateSystem);
        end
        
        function out = In(obj, coordinateSystem)
            if obj.coordinateSystem ~= coordinateSystem
                for i=1:length(obj.representation)
                    if obj.representation{i}.coordinateSystem == coordinateSystem
                        out = obj.representation{i}.obj;
                        return;
                    end
                end
            end            
            
            if obj.coordinateSystem ~= coordinateSystem
                T = getTransformation(obj.coordinateSystem, coordinateSystem);
                a = obj.body.positionVector.In(coordinateSystem).items;
                at = [0 -a(3) a(2); a(3) 0 -a(1); -a(2) a(1) 0];
                items = T.rotation.expr * obj.items' + obj.body.mass*at'*at;
                out = imf.Inertia(items, coordinateSystem);
                obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
            else
                out = obj;
            end
        end
    end
    
end

