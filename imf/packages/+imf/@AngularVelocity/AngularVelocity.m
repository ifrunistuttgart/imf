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

classdef AngularVelocity < imf.Vector
    
    methods
        function obj = AngularVelocity(val, coordinateSystem)
            obj = obj@imf.Vector(val, coordinateSystem);
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
                    
                    w = obj.items';
                    for i=1:length(T.rotations)
                        w = T.rotations(i).expr * w;
                    end
                    
                    for i=1:length(T.rotations)
                        v = imf.Expression([0;0;0]);
                        v(T.rotations(i).axis) = dot(T.rotations(i).generalizedCoordinate);
                        if i < length(T.rotations)
                            R = T.rotations(i+1:end);
                            for j=1:length(R)
                                v = R(j).expr * v;
                            end
                        end
                        w = w + v;
                    end
                    out = imf.AngularVelocity(w, coordinateSystem);
                    obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
                end
                
            end
        end
    end
    
end