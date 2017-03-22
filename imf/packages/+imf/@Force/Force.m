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

classdef Force
    
    properties(SetAccess = 'private')
        name
        value@imf.Vector
        positionVector@imf.PositionVector
    end
    
    methods
        function obj = Force(name, value, positionVector)
            
            if ischar(name) && ~isempty(value)
                obj.name = name;
            end
            
            if isa(value, 'imf.Vector')
                obj.value = value;
            else
                error('The force must be an imf.Vector');
            end            
            
            if isa(positionVector, 'imf.PositionVector')
                obj.positionVector = positionVector;
            else
                error('The point of application must be an imf.PositionVector');
            end
            
        end
        
        function obj = In(obj, coordinateSystem)
            if obj.value.coordinateSystem ~= coordinateSystem || obj.positionVector.coordinateSystem ~= coordinateSystem
                obj = imf.Force(obj.name, obj.value.In(coordinateSystem), obj.positionVector.In(coordinateSystem));
            end
        end
    end
    
end

