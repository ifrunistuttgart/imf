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

%    This File contains modified source code from the ACADO Toolkit.

%  Licence:
%    This file is part of ACADO Toolkit  - (http://www.acadotoolkit.org/)
%
%    ACADO Toolkit -- A Toolkit for Automatic Control and Dynamic Optimization.
%    Copyright (C) 2008-2009 by Boris Houska and Hans Joachim Ferreau, K.U.Leuven.
%    Developed within the Optimization in Engineering Center (OPTEC) under
%    supervision of Moritz Diehl. All rights reserved.
%
%    ACADO Toolkit is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    ACADO Toolkit is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
%
%    Author: David Ariens, Rien Quirynen
%    Date: 2012
%
classdef Vector < imf.VectorspaceElement
    properties
        dim = 0;
        coordinateSystem@imf.CoordinateSystem
    end
    
    properties(SetAccess = 'protected')
        representation = []
    end
    
    methods
        function obj = Vector(value, coordinateSystem)
            if nargin > 0
                global IMF_;
                
                if isa(value, 'imf.Vector')
                    obj = value;
                    
                    if isa(coordinateSystem, 'imf.CoordinateSystem')
                        obj.coordinateSystem = coordinateSystem;
                    end
                elseif (isa(value, 'numeric') || isa(value, 'imf.Expression'))
                    IMF_.count_vector = IMF_.count_vector+1;
                    obj.name = strcat('imfdata_v', num2str(IMF_.count_vector));
                    
                    if isa(value, 'numeric')
                        value = imf.Expression(value);
                    end
                    
                    [m n] = size(value);
                    
                    if (m == 1) || (n == 1)
                        obj.dim = max(m, n);
                        obj.items = value;
                    else
                        error('Input should be a vector');
                    end
                    
                    if isa(coordinateSystem, 'imf.CoordinateSystem')
                        obj.coordinateSystem = coordinateSystem;
                    else
                        error('The coordinateSystem must be an imf.CoordinateSystem');
                    end
                else
                    error('Vector expects a numeric value or an imf.Expression');
                end
            end
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
                items = T.rotation.expr * obj.items;
                items = items.simplify;
                out = imf.Vector(items, coordinateSystem);
                obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
            else
                out = obj;
            end
        end
        
        function s = toString(obj)
            s = getExpression(obj);
        end
        
        function out = mtimes(a,b)
            A = a.items;
            
            if isa(b, 'imf.Vector')
                if a.coordinateSystem ~= b.coordinateSystem
                    error('The factors must be in the same coordinate system.');
                end
                
                B = b.items;
                out = imf.Vector(simplify(A * B), b.coordinateSystem);
            elseif isnumeric(b) && isvector(b)
                B = imf.Expression(b);
                out = imf.Vector(simplify(A * B), a.coordinateSystem);
            else
                error('This multiplication is not implemented.')
            end
            
            if length(out) == 1
                out = getExpression(out);
            end
        end
        
        function out = eq(a,b)
            out = eq(getExpression(a), getExpression(b));
        end
        
        function out = ne(a,b)
            out = ne(getExpression(a), getExpression(b));
        end
        
        function out = jacobian(obj, gc)
            out = jacobian(obj.items, gc);
        end
        
        function out = functionalDerivative(obj, gc)
            out = imf.Vector(functionalDerivative(obj.items, gc), obj.coordinateSystem);
        end
        
        function out = getExpression(obj)
            m = size(obj, 1);
            n = size(obj, 2);
            if m > n
                out = imf.Expression.empty(m, 0);
            else
                out = imf.Expression.empty(0, n);
            end
            
            for i=1:m
                for j=1:n
                    out(i,j) = getExpression(obj.items(i,j));
                end
            end
        end
        
        function out = length(obj)
            out = obj.dim;
        end
        
        function out = size(obj, dim)
            if nargin < 2
                out = builtin('size', obj.items);
            else
                out = builtin('size', obj.items, dim);
            end
        end
        
        
        function out = ctranspose(in)
            out = transpose(in);
        end
        
        function out = transpose(in)
            out = imf.Vector(in.items, in.coordinateSystem);
            out.items = out.items';
        end
        
        function out = subsref(obj, s)
            switch s(1).type
                case '.'
                    if length(s) == 1
                        prop = s(1).subs;
                        out = obj.(prop);
                    elseif length(s) == 2 && strcmp(s(2).type,'()')
                        method = s(1).subs;
                        args = s(2).subs;
                        out = obj.(method)(args{:});
                    else
                        out = builtin('subsref', obj, s);
                    end
                case '()'
                    if length(s(1).subs) == 1
                        [m,n] = ind2sub(size(obj), s(1).subs{1});
                    else
                        m = s(1).subs{1};
                        n = s(1).subs{2};
                    end
                    out = obj.items(m,n);
                otherwise
                    error('This indexing is not supported.');
            end
        end
        
        function out = plus(a,b)
            if size(a,1) ~= size(b,1) || size(a,2) ~= size(b,2)
                error('ERROR: Invalid addition. Check your dimensions.');
            end
            
            if isa(b, 'imf.Vector') && a.coordinateSystem ~= b.coordinateSystem
                error('ERROR: Invalid addition. Check your coordinate systems.')
            end
            
            if ~strcmp(class(a), class(b))
                error('ERROR: Invalid addition. Check your types.')
            end
            
            if isa(b, 'imf.PositionVector')
                out = imf.PositionVector(getExpression(a) + getExpression(b), a.coordinateSystem);
            elseif isa(b, 'imf.AttitudeVector')
                out = imf.AttitudeVector(getExpression(a) + getExpression(b), a.coordinateSystem);
            elseif isa(b, 'imf.AngularVelocity')
                out = imf.AngularVelocity(getExpression(a) + getExpression(b), a.coordinateSystem);
            else
                out = imf.Vector(getExpression(a) + getExpression(b), a.coordinateSystem);
            end
        end
        
        function out = minus(a,b)
            if size(a,1) ~= size(b,1) || size(a,2) ~= size(b,2)
                error('ERROR: Invalid subtraction. Check your dimensions.');
            end
            
            if isa(b, 'imf.Vector') && a.coordinateSystem ~= b.coordinateSystem
                error('ERROR: Invalid subtraction. Check your coordinate systems.')
            end
            
            if ~strcmp(class(a), class(b))
                error('ERROR: Invalid subtraction. Check your types.')
            end
            
            if isa(b, 'imf.PositionVector')
                out = imf.PositionVector(getExpression(a) - getExpression(b), a.coordinateSystem);
            elseif isa(b, 'imf.AttitudeVector')
                out = imf.AttitudeVector(getExpression(a) - getExpression(b), a.coordinateSystem);
            elseif isa(b, 'imf.AngularVelocity')
                out = imf.AngularVelocity(getExpression(a) - getExpression(b), a.coordinateSystem);
            else
                out = imf.Vector(getExpression(a) - getExpression(b), a.coordinateSystem);
            end
        end
        
    end
    
end