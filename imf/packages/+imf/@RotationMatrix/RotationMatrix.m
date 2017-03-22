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
        function T = T1(v)
            fun = [1        0        0;
                0        cos(v)  sin(v);
                0        -sin(v) cos(v)];
            if isa(v, 'imf.GeneralizedCoordinate')
                T = imf.RotationMatrix(fun, 1, v);
            else
                T = imf.RotationMatrix(fun, 1);
            end
        end
        function T = T2(v)
            fun = [cos(v)   0      -sin(v);
                0         1      0;
                sin(v)   0      cos(v)];
            if isa(v, 'imf.GeneralizedCoordinate')
                T = imf.RotationMatrix(fun, 2, v);
            else
                T = imf.RotationMatrix(fun, 2);
            end
        end
        function T = T3(v)
            fun = [cos(v)   sin(v) 0;
                -sin(v)  cos(v) 0;
                0         0       1];
            if isa(v, 'imf.GeneralizedCoordinate')
                T = imf.RotationMatrix(fun, 3, v);
            else
                T = imf.RotationMatrix(fun, 3);
            end
        end
        function T = I
            fun = eye(3);
            T = imf.RotationMatrix(fun);
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
                elseif isa(varargin{2}, 'imf.Variable')
                else
                    error('The third argument need to be an imf.Variable');
                end
            end
        end
        
        function out = getExpression(obj)
            out = obj.expr;
        end
        
        function out = length(obj)
            out = builtin('length', obj.expr);
        end
        
        function varargout = size(obj, dim)
            if nargin < 2
                [varargout{1:nargout}] = builtin('size', obj.expr);
            else
                [varargout{1:nargout}] = builtin('size', obj.expr, dim);
            end
        end
        
        function out = eq(a,b)
            out = eq(getExpression(a), getExpression(b));
        end
        
        function out = ne(a,b)
            out = ne(getExpression(a), getExpression(b));
        end
        
        function out = subsref(obj, s)
            switch s(1).type
                case '.'
                    out = builtin('subsref', obj, s);
                case '()'
                    if isa(obj, 'imf.RotationMatrix') && isvector(obj)
                        out = builtin('subsref', obj, s);
                    else
                        if length(s(1).subs) == 1
                            [m,n] = ind2sub(size(obj), s(1).subs{1});
                        else
                            m = s(1).subs{1};
                            n = s(1).subs{2};
                        end
                        
                        if builtin('length', obj) == 1
                            out = obj.expr(m,n);
                        else
                            if builtin('length', s) == 1
                                out = obj(m,n);
                            else
                                out = builtin('subsref', obj(m,n), s(2:end));
                            end
                        end
                    end
                otherwise
                    error('This indexing is not supported.');
            end
        end
        
        function out = mtimes(a,b)
            A = a.expr;
            
            if isa(b, 'imf.RotationMatrix')
                B = b.expr;
                out = imf.RotationMatrix(simplify(A * B));
            elseif isa(b, 'imf.PositionVector')
                B = b.items;
                out = imf.PositionVector(simplify(A * B), b.coordinateSystem);
            elseif isa(b, 'imf.AttitudeVector')
                B = b.items;
                out = imf.AttitudeVector(simplify(A * B), b.coordinateSystem);
            elseif isa(b, 'imf.AngularVelocity')
                B = b.items;
                out = imf.AngularVelocity(simplify(A * B), b.coordinateSystem);
            elseif isa(b, 'imf.Vector')
                B = b.items;
                out = imf.Vector(simplify(A * B), b.coordinateSystem);
            elseif isnumeric(b) && ismatrix(b)
                B = imf.Expression(b);
                out = imf.RotationMatrix(simplify(A * B));
            else
                error('This multiplication is not implemented.')
            end         
        end
        
        function out = ctranspose(in)
            out = transpose(in);
        end
        
        function out = transpose(in)
            out = imf.RotationMatrix(transpose(in.expr), in.axis, in.generalizedCoordinate);
        end
    end
    
end