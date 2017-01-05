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

classdef Vector < imf.VectorspaceElement
    properties
        dim = 0;
        coordinateSystem@imf.CoordinateSystem
    end
    
    properties(SetAccess = 'protected')
        representation = []
    end
    
    methods
        function obj = Vector(val, coordinateSystem)
            if nargin > 0
                global IMF_;
                
                if (isa(val, 'numeric') || isa(val, 'imf.Expression'))
                    IMF_.count_vector = IMF_.count_vector+1;
                    obj.name = strcat('imfdata_v', num2str(IMF_.count_vector));
                    
                    [m n] = size(val);
                    
                    if (m == 1)
                        obj.dim = n;
                        obj.items = val;
                    elseif (n == 1)
                        obj.dim = m;
                        obj.items = val';
                    else
                        error('Input should be a vector');
                    end
                    
                    if isa(coordinateSystem, 'imf.CoordinateSystem')
                        obj.coordinateSystem = coordinateSystem;
                    else
                        error('The coordinateSystem must be an imf.CoordinateSystem');
                    end
                else
                    error('Vector expects a numeric value');
                end
            end
        end
        
        function out = In(obj, coordinateSystem)
            if obj.coordinateSystem ~= coordinateSystem
                for i=1:length(obj.representation)
                    if obj.representation{i}.coordinateSystem == coordinateSystem
                        out = obj.representation{i}.obj;
                    end
                end
            end            
            
            if obj.coordinateSystem ~= coordinateSystem
                T = getTransformation(obj.coordinateSystem, coordinateSystem);
                items = T.rotation.expr * obj.items';
                out = imf.Vector(items, coordinateSystem);
                obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
            else
                out = obj;
            end
        end
        
    end
    
end