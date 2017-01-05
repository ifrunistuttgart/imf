classdef RotationMatrix < handle
    %RotationMatrix defines a rotation matrix
    
    properties
        expr@imf.Expression
    end
    
    methods(Static)
        function T = T1(gc)
            fun = [1        0        0;
                0        cos(gc)  sin(gc);
                0        -sin(gc) cos(gc)];
            T = imf.RotationMatrix(fun);
        end
        function T = T2(gc)
            fun = [cos(gc)   0      -sin(gc);
                0         1      0;
                sin(gc)   0      cos(gc)];
            T = imf.RotationMatrix(fun);
        end
        function T = T3(gc)
            fun = [cos(gc)   sin(gc) 0;
                -sin(gc)  cos(gc) 0;
                0         0       1];
            T = imf.RotationMatrix(fun);
        end
    end
    
    methods
        function obj = RotationMatrix(in)
            if isa(in, 'imf.Expression')
                obj.expr = in;
            else
                obj.expr = imf.Expression(in);
            end
        end
        
        function r = mtimes(a,b)
            r = a.expr * a.expr;
        end
        
        function out = ctranspose(in)
            out = transpose(in);
        end
        
        function out = transpose(in)
            out = imf.RotationMatrix(transpose(in.expr));
        end
    end
    
end