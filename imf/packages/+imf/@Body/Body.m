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

classdef Body < handle
    
    properties(SetAccess = 'private')
        name
        mass
        positionVector@imf.PositionVector
        inertia@imf.Inertia
        angularVelocity@imf.AngularVelocity
    end
    
    properties(GetAccess = 'private')
        cache@imf.Cache = imf.Cache();
    end
    
    methods
        
        function obj = Body(name, mass, positionVector, inertia, angularVector)
            
            if ischar(name) && ~isempty(mass)
                obj.name = name;
            end
            
            if isnumeric(mass) && length(mass) == 1
                obj.mass = mass;
            elseif isa(mass, 'imf.Variable')
                obj.mass = mass;
            else
                error('The mass must be a numeric scalar or an imf.Parameter');
            end
            
            if isa(positionVector, 'imf.PositionVector')
                obj.positionVector = positionVector;
            else
                error('The positionVector must be an imf.PositionVector');
            end
            
            if nargin > 3
                
                if nargin < 5
                    error('An attitude vector is mendatory for inertia.');
                end
                
                if isa(inertia, 'imf.Inertia')
                    obj.inertia = inertia;
                    obj.inertia.body = obj;
                else
                    error('The inertia must be an imf.Inertia');
                end
                
                if isa(angularVector, 'imf.AttitudeVector')
                    gc = genCoordinates;
                    w = functionalDerivative(angularVector.items, gc);
                    obj.angularVelocity = imf.AngularVelocity(w, angularVector.coordinateSystem);
                elseif isa(angularVector, 'imf.AngularVelocity')
                    obj.angularVelocity = angularVector;
                else
                    error('The angularVector must be an imf.AttitudeVector or an imf.AngularVelocity');
                end
                
            end
        end
        
        function out = In(obj, coordinateSystem)
            if isempty(obj.inertia) && obj.positionVector.coordinateSystem ~= coordinateSystem
                out = imf.Body(obj.name, obj.mass, obj.positionVector.In(coordinateSystem));
            elseif ~isempty(obj.inertia) && (obj.positionVector.coordinateSystem ~= coordinateSystem || obj.inertia.coordinateSystem ~= coordinateSystem)
                out = imf.Body(obj.name, obj.mass, obj.positionVector.In(coordinateSystem), obj.inertia.In(coordinateSystem), obj.angularVelocity.In(coordinateSystem));
            else
                out = obj;
            end
        end
        
        function out = rotationalJacobian(obj)
            gc = genCoordinates;
            
            for j=1:length(gc)
                dgc(j) = d(gc(j));
            end
            
            if obj.cache.contains('RotationalJacobian')
                out = obj.cache.get('RotationalJacobian');
            else
                out = jacobian(obj.angularVelocity, dgc);
                obj.cache.insertOrUpdate('RotationalJacobian', out);
            end
        end
        
        function out = translationalJacobian(obj)
            gc = genCoordinates;
            
            if obj.cache.contains('TranslationalJacobian')
                out = obj.cache.get('TranslationalJacobian');
            else
                out = jacobian(obj.positionVector, gc);
                obj.cache.insertOrUpdate('TranslationalJacobian', out);
            end
        end
        
        function out = rotationalAcceleration(obj)
            gc = genCoordinates;
            
            if obj.cache.contains('RotationalAcceleration')
                out = obj.cache.get('RotationalAcceleration');
            else
                out = functionalDerivative(obj.angularVelocity, gc);
                obj.cache.insertOrUpdate('RotationalAcceleration', out);
            end
        end
        
        function out = translationalAcceleration(obj)
            gc = genCoordinates;
            
            if obj.cache.contains('TranslationalAcceleration')
                out = obj.cache.get('TranslationalAcceleration');
            else
                dr = functionalDerivative(obj.positionVector, gc);
                out = functionalDerivative(dr, gc);
                obj.cache.insertOrUpdate('TranslationalAcceleration', out);
            end
        end
    end
    
end