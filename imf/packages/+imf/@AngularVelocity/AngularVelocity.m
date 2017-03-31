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
        function obj = AngularVelocity(value, coordinateSystem)
            obj = obj@imf.Vector(value, coordinateSystem);
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
                    
                    for i=1:length(T.rotations)
                        out = T.rotations{i} * out;
                    end
                    
                    for i=1:length(T.rotations)
                        v = imf.AngularVelocity([0;0;0], out.coordinateSystem);
                        % TODO: should be accessible via v(idx) but is not
                        v.items(T.rotations{i}.axis) = dot(T.rotations{i}.generalizedCoordinate);
                        if i < length(T.rotations)
                            rots = T.rotations;
                            R = rots(i+1:end);
                            if length(R) > 1
                                for j=1:length(R)
                                    v = R{j} * v;
                                end
                            else
                                v = R{1} * v;
                            end
                        end
                        out = out + v;
                    end
                    out.items = out.items.simplify;
                    obj.representation{end+1} = struct('coordinateSystem', coordinateSystem, 'obj', out);
                end                
            end
        end

    end    
end