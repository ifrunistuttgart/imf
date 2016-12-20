classdef DCM < handle
    %DCM defines a direct cosine matrix
    %   Detailed explanation goes here
    
    properties(SetAccess=private)
        fun@imf.Expression
    end
    
    methods(Static)
        function T = T1(gc)
            fun = [1        0        0;
                   0        cos(gc)  sin(gc);
                   0        -sin(gc) cos(gc)];
            T = imf.DCM(fun);
        end
        function T = T2(gc)
            fun = [cos(gc)   0      -sin(gc);
                   0         1      0;
                   sin(gc)   0      cos(gc)];
            T = imf.DCM(fun);
        end
        function T = T3(gc)
            fun = [cos(gc)   sin(gc) 0;
                   -sin(gc)  cos(gc) 0;
                   0         0       1];
            T = imf.DCM(fun);
        end
    end
    
    methods
        function r = mtimes(a,b)
            r = imf.DCM(a.fun * b.fun);
        end
        
        function obj = DCM(fun)
            obj.fun = fun;
        end
                
        function obj = ctranspose(a)
            obj = imf.DCM(a.fun');
        end
    end
    
end

