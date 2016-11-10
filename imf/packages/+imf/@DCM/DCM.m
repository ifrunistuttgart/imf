classdef DCM < handle
    %DCM defines a direct cosine matrix
    %   Detailed explanation goes here
    
    properties(SetAccess=private)
        fun@sym
    end
    
    methods(Static)
        function T = T1(gc)
            a = sym(gc.name);
            fun = [1         0       0;
                   0         cos(a)  sin(a);
                   0         -sin(a) cos(a)];
            T = imf.DCM(fun);
        end
        function T = T2(gc)
            a = sym(gc.name);
            fun = [cos(a)    0       -sin(a);
                   0         1       0;
                   sin(a)    0       cos(a)];
            T = imf.DCM(fun);
        end
        function T = T3(gc)
            a = sym(gc.name);
            fun = [cos(a)    sin(a)  0;
                   -sin(a)   cos(a)  0;
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

