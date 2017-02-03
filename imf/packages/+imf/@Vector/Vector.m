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
                
                if (isa(value, 'numeric') || isa(value, 'imf.Expression'))
                    IMF_.count_vector = IMF_.count_vector+1;
                    obj.name = strcat('imfdata_v', num2str(IMF_.count_vector));
                    
                    if isa(value, 'numeric')
                        value = imf.Expression(value);
                    end
                    
                    [m n] = size(value);
                    
                    if (m == 1)
                        obj.dim = n;
                        obj.items = value;
                    elseif (n == 1)
                        obj.dim = m;
                        obj.items = value';
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
                        return;
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