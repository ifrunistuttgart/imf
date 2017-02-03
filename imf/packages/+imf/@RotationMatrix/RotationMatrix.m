%  Licence:
%    This file is part of iFR Modelling Framework  - (http://www.ifr.uni-stuttgart.de)
%
%    IMF -- A framework for modelling dynamic mechanical systems in MATLAB.
%    Copyright (C) 2016-2017 by Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>.
%    Developed within the Flight Mechanics and Controls Lab of the
%    University of Stuttgart. All rights reserved.
%
%    IMF is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    IMF is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

classdef RotationMatrix < handle
    
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