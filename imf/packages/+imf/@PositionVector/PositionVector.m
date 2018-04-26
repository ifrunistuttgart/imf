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

classdef PositionVector < imf.Vector
        
    properties(GetAccess = 'private')
        cache@imf.Cache;
    end
    
    methods
        function obj = PositionVector(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);
            obj.cache = imf.Cache();
        end
        
        function out = In(obj, coordinateSystem)
            
            out = obj;
            
            if obj.coordinateSystem ~= coordinateSystem
                
                for i=1:length(obj.representation)
                    if obj.representation{i}.coordinateSystem == coordinateSystem
                        out = obj.representation{i}.obj;
                        return;
                    end
                end
                
                if obj.coordinateSystem ~= coordinateSystem
                    T = getTransformation(obj.coordinateSystem, coordinateSystem);
                    R = T.HomogeneousMatrix;
                    items = R * [obj.items; 1];
                    items = items.simplify;
                    out = imf.PositionVector(items(1:3), coordinateSystem);
                    obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
                end
                
            end
        end
        
        function out = Acceleration(obj)            
            if obj.cache.contains('Acceleration')
                out = obj.cache.get('Acceleration');
            else
                gc = genCoordinates;
                dr = functionalDerivative(obj, gc);
                out = functionalDerivative(dr, gc);
                obj.cache.insertOrUpdate('Acceleration', out);
            end
        end
        
        function out = Jacobian(obj)            
            if obj.cache.contains('Jacobian')
                out = obj.cache.get('Jacobian');
            else
                gc = genCoordinates;
                out = jacobian(obj, gc);
                obj.cache.insertOrUpdate('Jacobian', out);
            end
        end
    end
    
end