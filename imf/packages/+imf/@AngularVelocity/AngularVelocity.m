classdef AngularVelocity < imf.Vector
    
    methods
        function obj = AngularVelocity(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);
        end
        
        function out = In(obj, coordinateSystem)
            
            out = obj;
            
            if obj.coordinateSystem ~= coordinateSystem
                
                for i=1:length(obj.representation)
                    if obj.representation{i}.coordinateSystem == coordinateSystem
                        out = obj.representation{i}.obj;
                        return;
                    end
                end
                
                if obj.coordinateSystem ~= coordinateSystem
                    T = getTransformation(obj.coordinateSystem, coordinateSystem);
                    
                    w = obj.items';
                    for i=1:length(T.rotations)
                        w = T.rotations(i).expr * w;
                    end
                    
                    for i=1:length(T.rotations)
                        v = imf.Expression([0;0;0]);
                        v(T.rotations(i).axis) = dot(T.rotations(i).generalizedCoordinate);
                        if i < length(T.rotations)
                            R = T.rotations(i+1:end);
                            for j=1:length(R)
                                v = R(j).expr * v;
                            end
                        end
                        w = w + v;
                    end
                    out = imf.AngularVelocity(w, coordinateSystem);
                    obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
                end
                
            end
        end
    end
    
end