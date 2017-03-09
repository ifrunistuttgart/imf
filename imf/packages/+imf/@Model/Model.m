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

classdef Model < handle
    
    properties(SetAccess = 'private')
        inertialSystem@imf.CoordinateSystem
        forces@imf.Force vector = imf.Force.empty;
        moments@imf.Moment vector = imf.Moment.empty;
        bodies@imf.Body vector = imf.Body.empty;
    end
    
    properties
        gravity@imf.Gravity
    end
    
    methods
        function obj = Model(inertialSystem)
            global IMF_;
            
            if nargin < 1
                error('Please provide the inertial coordinate system.');
            end
            
            obj.inertialSystem = inertialSystem;
            
            if isnan(IMF_.model)
                IMF_.model = obj;
            else
                error('There is already a model defined.' + ...
                    'You can only have one model at a time.');
            end
            
        end
        
        function system = Compile(obj)
            
            gc = genCoordinates;
            
            if isempty(gc)
                error('There are no generalized coordinates defined. Aborting.')
            end
            
            system = imf.Expression.empty(length(obj.bodies),0);
            
            for i=1:length(obj.bodies)
                b = obj.bodies(i);
                m = b.mass;
                jac = jacobian(b.positionVector, gc);
                dr = functionalDerivative(b.positionVector, gc);
                ddr = functionalDerivative(dr, gc);
                
                if isempty(system)
                    system = m*jac'*ddr;
                else
                    system = system + m*jac'*ddr;
                end
                
                if ~isempty(b.inertia)
                    I = b.inertia.items;
                    
                    for j=1:length(gc)
                        dgc(j) = dot(gc(j));
                    end
                    
                    jac = jacobian(b.angularVelocity, dgc);
                    w = b.angularVelocity;
                    dw = functionalDerivative(w, gc);
                    
                    if isempty(system)
                        system = jac'*(I*dw + cross(w,I*w));
                    else
                        system = system + jac'*(I*dw + cross(w,I*w));
                    end
                end
            end
            
            for i=1:length(obj.forces)
                F = obj.forces(i);
                jac = jacobian(F.positionVector, gc);
                
                if isempty(system)
                    system = -1 * jac'*F.value;
                else
                    system = system - jac'*F.value;
                end
            end
            
            for i=1:length(obj.moments)
                M = obj.moments(i);
                
                for j=1:length(gc)
                    dgc(j) = dot(gc(j));
                end
                jac = jacobian(M.angularVelocity, dgc);
                
                if isempty(system)
                    system = -1 * jac'*M.value;
                else
                    system = system - jac'*M.value;
                end
            end
        end
        
        function Add(obj, external)
            if isa(external, 'imf.Force')
                
                obj.forces(end+1) = external.In(obj.inertialSystem);
                
            elseif isa(external, 'imf.Moment')
                
                obj.moments(end+1) = external.In(obj.inertialSystem);
                
            elseif isa(external, 'imf.Body')
                
                obj.bodies(end+1) = external.In(obj.inertialSystem);
                
                if ~isempty(obj.gravity)
                    b = obj.bodies(end);
                    obj.forces(end+1) = imf.Force(['F' b.name], imf.Vector(b.mass*obj.gravity.items, obj.gravity.coordinateSystem), b.positionVector);
                end
                
            else
                error('You can only add external forces, moments or ' + ...
                    'inertias to the model.')
            end
        end
    end
    
end

