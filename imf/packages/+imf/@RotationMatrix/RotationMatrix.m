classdef RotationMatrix < handle
    %RotationMatrix defines a rotation matrix
    
    properties
        expr@imf.Expression
        axis@double
        generalizedCoordinate@imf.GeneralizedCoordinate
    end
    
    methods(Static)
        function T = T1(gc)
            fun = [1        0        0;
                0        cos(gc)  sin(gc);
                0        -sin(gc) cos(gc)];
            T = imf.RotationMatrix(fun, 1, gc);
        end
        function T = T2(gc)
            fun = [cos(gc)   0      -sin(gc);
                0         1      0;
                sin(gc)   0      cos(gc)];
            T = imf.RotationMatrix(fun, 2, gc);
        end
        function T = T3(gc)
            fun = [cos(gc)   sin(gc) 0;
                -sin(gc)  cos(gc) 0;
                0         0       1];
            T = imf.RotationMatrix(fun, 3, gc);
        end
    end
    
    methods
        function obj = RotationMatrix(in, varargin)
            if isa(in, 'imf.Expression')
                obj.expr = in;
            else
                obj.expr = imf.Expression(in);
            end
            
            if nargin > 1
                if isnumeric(varargin{1})
                    obj.axis = varargin{1};
                else
                    error('The second argument need to be an numeric value selecting the axis to turn');
                end
            end
            
            if nargin > 2
                if isa(varargin{2}, 'imf.GeneralizedCoordinate')
                    obj.generalizedCoordinate = varargin{2};
                else
                    error('The third argument need to be an imf.GeneralizedCoordinate');
                end
            end
        end
        
        function r = mtimes(a,b)
            r = imf.RotationMatrix(a.expr * b.expr);
        end
        
        function out = ctranspose(in)
            out = transpose(in);
        end
        
        function out = transpose(in)
            out = imf.RotationMatrix(transpose(in.expr), in.axis, in.generalizedCoordinate);
        end
    end
    
end