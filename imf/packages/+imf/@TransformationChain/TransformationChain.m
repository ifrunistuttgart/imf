classdef TransformationChain < handle
    %Transformation defines a transformation of coordinate systems
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
    end
    properties(SetAccess='public')
        transformations@imf.Transformation vector = imf.Transformation.empty
    end
    
    methods
        function obj = TransformationChain(from, to)
            if nargin > 0
                global IMF_;
                
                obj.from = from;
                obj.to = to;
                
                IMF_.transformationChains(end+1) = obj;
            end
        end
        
        function obj = ctranspose(a)
            obj = imf.TransformationChain(a.to, a.from);
            obj.transformations = obj.transformations';
        end
        
        function R = HomogeneousMatrix(obj)
                        
            R = eye(4);
            for i=length(obj.transformations):-1:1
                R = R * obj.transformations(i).HomogeneousMatrix;
            end
            
        end
        
        function T = rotation(obj)
            
            T = eye(3);
            for i=length(obj.transformations):-1:1
                T = T * obj.transformations(i).rotation.expr;
            end
            T = imf.RotationMatrix(T);
        end
    end
    
end

